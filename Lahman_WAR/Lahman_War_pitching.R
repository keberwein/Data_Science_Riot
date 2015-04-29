library(DBI)
library(RPostgreSQL)
library(dplyr)

#Get the data from Baseball Reference
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "http://www.baseball-reference.com/data/war_daily_pitch.txt"
download.file(fileUrl, destfile="war_daily_pitch.csv", method="curl")

#Write the download to a data frame
df <- read.csv("war_daily_ptich.csv", header=TRUE)

#Connect to your Lahman instance so we can grab some data from the master table
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host= "localhost", dbname = "Lahman", 
                 user="YOUR USERNAME", password="YOUR PASSWORD")

#SQL the database for playerid on the master table "bbrefid" are the Baseball Reference ids
master <- dbSendQuery(con, "SELECT playerID, bbrefID FROM master")
m <- fetch(master, n = -1)

#SQL on the teams table to match Baseball Ref team_ID
teams <- dbSendQuery(con, "SELECT yearID, teamID, teamIDBR FROM teams")
t <- fetch(teams, n = -1)

#Join master and war data frames
df2 <- left_join(df, m, by = c("player_ID" = "bbrefID"))

# Convert and rename a few things in the teams dataframe to make the join smooth
t$teamidbr <- as.factor(t$teamidbr)
names(t)[names(t)=="teamIDBR"] <- "team_ID"
names(t)[names(t)=="yearID"] <- "year_ID"

#Now we index the teams
df3 <- left_join(df2, t)

#Reorder data frame
final <- subset(df3, select = c(playerid,  year_ID, age, teamid,  stint_ID, lg_ID, G, GS, IPouts, IPouts_start, 
                                IPouts_relief, RA, xRA, xRA_sprp_adj, xRA_def_pitcher, PPF, PPF_custom, xRA_final, 
                                BIP, BIP_perc, RS_def_total, runs_above_avg, runs_above_avg_adj, runs_above_rep, 
                                RpO_replacement, GR_leverage_index_avg, WAR, salary, teamRpG, oppRpG, pyth_exponent, 
                                waa_win_perc, WAA, WAA_adj, oppRpG_rep, pyth_exponent_rep, waa_win_perc_rep, WAR_rep))

#Rename a couple of columns in our new tidy data set to fit to Lahman standards
names(final)[names(final)=="stint_ID"] <- "stint"
names(final)[names(final)=="lg_ID"] <- "lgID"
names(final)[names(final)=="year_ID"] <- "yearID"
names(final)[names(final)=="team_ID"] <- "teamID"

# At this point you can do a write.csv() and load that into your Lahman instance
# OR
# Use the database connection that you established earlier to wirte a new table directly to Lahman
#Write your data frame back to the dbase. I like to write it as a test table first.
dbWriteTable(con, name='war_batting', value=final, row.names = FALSE)

##Now go to the Baseball Reference WAR tables and admire your work!
