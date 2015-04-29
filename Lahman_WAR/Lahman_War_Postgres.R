library(DBI)
library(RPostgreSQL)
library(dplyr)

#Get the data from Baseball Reference
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "http://www.baseball-reference.com/data/war_daily_bat.txt"
download.file(fileUrl, destfile="war_daily_bat.csv", method="curl")

#Write the download to a data frame
df <- read.csv("war_daily_bat.csv", header=TRUE)

#Connect to your Lahman instance so we can grab some data from the master table
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host= "localhost", dbname = "kriseberwein", 
                 user="kriseberwein", password="pissoff")

#SQL the database for playerid on the master table "bbrefid" are the Baseball Reference ids
master <- dbSendQuery(con, "SELECT playerid, bbrefid FROM master")
m <- fetch(master, n = -1)

#SQL on the teams table to match Baseball Ref team_ID
teams <- dbSendQuery(con, "SELECT yearid, teamid, teamidbr FROM teams")
t <- fetch(teams, n = -1)

#Join master and war data frames
df2 <- left_join(df, m, by = c("player_ID" = "bbrefid"))

# Convert and rename a few things in the teams dataframe to make the join smooth
t$teamidbr <- as.factor(t$teamidbr)
names(t)[names(t)=="teamidbr"] <- "team_ID"
names(t)[names(t)=="yearid"] <- "year_ID"

#Now we index the teams
df3 <- left_join(df2, t)

#Reorder data frame
final <- subset(df3, select = c(playerid, year_ID, age, teamid, stint_ID, lg_ID, PA, G, 
                                Inn, runs_bat, runs_br, runs_dp, runs_field, runs_infield, 
                                runs_outfield, runs_catcher, runs_good_plays, runs_defense, 
                                runs_position, runs_position_p, runs_replacement, runs_above_rep, 
                                runs_above_avg, runs_above_avg_off, runs_above_avg_def, WAA, WAA_off, 
                                WAA_def, WAR, WAR_def, WAR_off, WAR_rep, salary, pitcher, teamRpG, 
                                oppRpG, oppRpPA_rep, oppRpG_rep, pyth_exponent, pyth_exponent_rep, 
                                waa_win_perc, waa_win_perc_off, waa_win_perc_def, waa_win_perc_rep))

#Rename a couple of columns in our new tidy data set to fit to Lahman standards
names(final)[names(final)=="stint_ID"] <- "stint"
names(final)[names(final)=="lg_ID"] <- "lgID"
names(final)[names(final)=="year_ID"] <- "yearID"

# At this point you can do a write.csv() and load that into your Lahman instance
# OR
# Use the database connection that you established earlier to wirte a new table directly to Lahman
#Write your data frame back to the dbase. I like to write it as a test table first.
dbWriteTable(con, name='war_batting', value=final, row.names = FALSE)

##Now go to the Baseball Reference WAR tables and admire your work!
