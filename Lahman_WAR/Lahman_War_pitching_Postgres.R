#Load packages and install if you don't have them
if("DBI" %in% rownames(installed.packages()) == FALSE) {install.packages("DBI")}
if("RPostgreSQL" %in% rownames(installed.packages()) == FALSE) {install.packages("RPostreSQL")}
if("dplyr" %in% rownames(installed.packages()) == FALSE) {install.packages("dplyr")}
library(DBI)
library(RMySQL)
library(dplyr)

#Get the data from Baseball Reference
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "http://www.baseball-reference.com/data/war_daily_pitch.txt"
download.file(fileUrl, destfile="war_daily_pitch.csv", method="curl")

#Write the download to a data frame
df <- read.csv("war_daily_pitch.csv", header=TRUE)

#Connect to your Lahman instance so we can grab some data from the master table
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host= "localhost", dbname = "lahman", 
                 user="YOUR USERNAME", password="YOUR PASSWORD")

#SQL the database for playerid on the master table "bbrefid" are the Baseball Reference ids
master <- dbSendQuery(con, "SELECT playerid, bbrefid FROM master")
m <- fetch(master, n = -1)

#SQL on the teams table to match Baseball Ref team_ID
teams <- dbSendQuery(con, "SELECT yearid, teamid, teamidbr FROM teams")
t <- fetch(teams, n = -1)

#Join master and war data frames
#Joins may throw warnings about vectors and factors... Don't worry just move on.
df2 <- left_join(df, m, by = c("player_ID" = "bbrefid"))

# Convert and rename a few things in the teams dataframe to make the join smooth
t$teamidbr <- as.factor(t$teamidbr)
names(t)[names(t)=="teamidbr"] <- "team_ID"
names(t)[names(t)=="yearid"] <- "year_ID"

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
names(final)[names(final)=="lg_ID"] <- "lgid"
names(final)[names(final)=="year_ID"] <- "yearid"
names(final)[names(final)=="team_ID"] <- "teamid"

#IMPORTANT: Postgres users:
#Postgres WILL yell at you if you don't format these properly! Convert all colnames to lowercase!
names(final)[-1:-3] <- tolower(names(final)[-1:-3])


# At this point you can do a write.csv() and load that into your Lahman instance
# OR
# Use the database connection that you established earlier to wirte a new table directly to Lahman
#Write your data frame back to the dbase. I like to write it as a test table first.
if(dbExistsTable(con, "war_pitching")) {
  dbRemoveTable(con, "war_pitching")
  dbWriteTable(con, name='war_pitching', value=final, row.names = FALSE)}

##Now go to the Baseball Reference WAR tables and admire your work!
