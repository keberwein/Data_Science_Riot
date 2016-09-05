##This code snippet is written to be used with a MySQL database connection using the RmySQL package and Lahman database.
##Aternatley, if you have an SQL database, the RODBC package should work also.
##I've included the raw data in csv. If you use this you can skip the data collection piece entirely.

library(RMySQL)

##Connect to your MySQL database wiht the RMySQL package
drv <- dbDriver("MySQL")
con <- dbConnect(dbDriver("MySQL"), user = "root", password = "password", dbname = "lahman")

#SQL for Batting table
batting <- dbSendQuery(con,
                        "SELECT *
                        FROM Batting")
#Fetch batting into data frame
b <- fetch(batting, n = -1)

#SQL for Pitching table
pitching <- dbSendQuery(con,
                         "SELECT *
                        FROM Pitching")
#Fetch pitching into data frame
p <- fetch(pitching, n = -1)

#SQL for fielding table
fielding <- dbSendQuery(con,
                       "SELECT *
                        FROM Fielding
                        WHERE yearID = 1901")

#Fetch fielding into data frame
f <- fetch(fielding, n = -1)


##Batting: Calculate stats and add them to data frame.

b$PA <- (b$AB + b$BB+ b$HBP + b$SF + b$SH) #Plate Appearences

b$OBP <- round(((b$H+b$BB+b$HBP)/(b$AB+b$BB+b$HBP+b$SF)), 3) #On base %

b$SLG <- round(((b$H+b$'2B'+2*b$'3B'+3*b$HR)/b$AB), 3) #Slugging

b$ISO <- round((((b$'2B') + (2*b$'3B') + (3*b$'HR')) / b$AB), 3) #Isolated Power

b$OPS <- round(((b$H + b$BB + b$HBP) / (b$AB + b$BB + b$HBP + b$SF)) + (((b$H-b$'2B'-b$'3B'-b$HR) 
        + (2 * b$'2B') + (3 * b$'3B') + (4 * b$HR))/b$AB), 3) #On Base Plus Slugging

b$BABIP <- round(((b$H-b$HR)/(b$PA-b$SO-b$BB-b$HR)), 3) #Batting Average on Balls in Play

b$ContactRate <- round(((b$AB-b$SO)/b$AB), 3) #Batter contact rate

b$Kpct <- round((b$SO/b$PA), 3) #Strikeout Rate 

b$BBpct <- round((b$BB/b$PA), 3) #Base on Balls rate


##Pitching Calculate stats and add them to data frame.

p$IP <- round((p$IPouts)/3), 3) #Innings Pitched

p$WHIP <- round(((p$BB + p$H) / (p$IPouts/3)), 3)

p$k_9 <- round((p$SO*9)/p$IP, 3) #Strikeouts per 9

p$BB_9 <- round((p$BB*9)/p$IP, 3) #Walks allowed per 9

p$HR_9 <- round((p$HR*9)/p$IP, 3) #Homeruns allowed per 9

p$Kpct <- round((p$SO/p$BFP), 3)

p$BBpct <- round((p$BB/p$BFP), 3)

p$pBABIP <- round(((p$H-p$HR)/(p$BFP-p$SO-p$BB-p$HR)), 3) #Batting Average on Balls in Play


##Fielding Calculate stats and add them to data frame.

f$FldPct <- round((f$PO+f$A)/(f$PO+f$A+f$E), 3) #Fielding Percentage


##Optionally you can export these data frames to csv or write them directly to you database with the following:
##Note, I'm creating a table called "testbatting" for safty reasons
##Once the table is loaded correctly you can drop the old "batting" table and rename "testbatting."

dbWriteTable(con, name='testbatting', value=b)
dbWriteTable(con, name='testpitching', value=p)
dbWriteTable(con, name='testfielding', value=f) 
