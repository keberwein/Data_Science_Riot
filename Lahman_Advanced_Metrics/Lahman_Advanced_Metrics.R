##This code snippet is written to be used with a MySQL database connection using the RmySQL package and Lahman database.
##Aternatley, if you have an SQL database, the RODBC package should work also.
##I've included the raw data in csv. If you use this you can skip the data collection piece entirely.

library(RMySQL)

##Connect to your MySQL database wiht the RMySQL package
drv = dbDriver("MySQL")
con = dbConnect(dbDriver("MySQL"), user = "root", password = "password", dbname = "lahman")

#SQL for Batting table
batting = dbSendQuery(con,
                        "SELECT *
                        FROM Batting")
#Fetch batting into data frame
b = fetch(batting, n = -1)

#SQL for Pitching table
pitching = dbSendQuery(con,
                         "SELECT *
                        FROM Pitching")
#Fetch pitching into data frame
p = fetch(pitching, n = -1)

#SQL for fielding table
fielding = dbSendQuery(con,
                       "SELECT *
                        FROM Fielding
                        WHERE yearID = 1901")

#Fetch fielding into data frame
f = fetch(fielding, n = -1)


##Batting: Calculate stats and add them to data frame.

b$PA = (b$AB + b$BB+ b$HBP + b$SF + b$SH) #Plate Appearences

b$OBP = ((b$H+b$BB+b$HBP)/(b$AB+b$BB+b$HBP+b$SF)) #On base %

b$SLG = ((b$H+b$'2B'+2*b$'3B'+3*b$HR)/b$AB) #Slugging

b$ISO = (((b$'2B') + (2*b$'3B') + (3*b$'HR')) / b$AB) #Isolated Power

b$OPS = ((b$H + b$BB + b$HBP) / (b$AB + b$BB + b$HBP + b$SF)) + (((b$H-b$'2B'-b$'3B'-b$HR) 
        + (2 * b$'2B') + (3 * b$'3B') + (4 * b$HR))/b$AB) #On Base Plus Slugging

b$RC = ((b$H+b$BB)*(b$H+b$2B+2*b$3B+3*b$HR))/(b$AB+b$BB) #Runs Created

b$BABIP = ((b$H-b$HR)/(b$PA-b$SO-b$BB-b$HR)) #Batting Average on Balls in Play

b$ContactRate = ((b$AB-b$SO)/b$AB) #Batter contact rate

b$Kpct = (b$SO/b$PA) #Strikeout Rate 

b$BBpct = (b$BB/b$PA) #Base on Balls rate


##Pitching Calculate stats and add them to data frame.

p$IP = ((p$IPouts)/3) #Innings Pitched

p$WHIP = ((p$BB + p$H) / (p$IPouts/3))

p$k_9 = (p$SO*9)/p$IP #Strikeouts per 9

p$BB_9 = (p$BB*9)/p$IP #Walks allowed per 9

p$HR_9 = (p$HR*9)/p$IP #Homeruns allowed per 9

p$Kpct = (p$SO/p$BFP)

p$BBpct = (p$BB/p$BFP)

p$pBABIP = ((p$H-p$HR)/(p$BFP-p$SO-p$BB-p$HR)) #Batting Average on Balls in Play


##Fielding Calculate stats and add them to data frame.

f$FldPct = (f$PO+f$A)/(f$PO+f$A+f$E) #Fielding Percentage


##Optionally you can export these data frames to csv or write them directly to you database with the following:
##Note, I'm creating a table called "testbatting" for safty reasons
##Once the table is loaded correctly you can drop the old "batting" table and rename "testbatting."

dbWriteTable(con, name='testbatting', value=b)
dbWriteTable(con, name='testpitching', value=p)
dbWriteTable(con, name='testfielding', value=f) 