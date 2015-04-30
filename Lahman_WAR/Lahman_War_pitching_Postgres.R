#Load packages and install if you don't have them
require(DBI)
require(RPostgreSQL)
require(dplyr)

#Get the data from Baseball Reference
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "http://www.baseball-reference.com/data/war_daily_pitch.txt"
download.file(fileUrl, destfile="war_daily_pitch.csv", method="curl")

#Write the download to a data frame
df <- read.csv("war_daily_pitch.csv", header=TRUE, stringsAsFactors=FALSE)

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

# Clean up the data types before loading into Lahman
# This part is nausiating but necessary...
final$age <- as.integer(as.character(final$age))
final$stint <- as.integer(as.character(final$stint))
final$g <- as.integer(as.character(final$g))
final$gs <- as.integer(as.character(final$gs))
final$ipouts <- as.integer(as.character(final$ipouts))
final$salary <- as.integer(as.character(final$salary))
final$ipouts_start <- as.integer(as.character(final$ipouts_start))
final$ipouts_relief <- as.integer(as.character(final$ipouts_relief))
final$ra <- as.integer(as.character(final$ra))
final$xra_sprp_adj <- as.double(as.character(final$xra_sprp_adj))
final$xra_def_pitcher <- as.double(as.character(final$xra_def_pitcher))
final$ppf <- as.integer(as.character(final$ppf))
final$ppf_custom <- as.double(as.character(final$ppf_custom))
final$xra_final <- as.double(as.character(final$xra_final))
final$bip <- as.integer(as.character(final$bip))
final$bip_perc <- as.integer(as.character(final$bip_perc))
final$rs_def_total <- as.double(as.character(final$rs_def_total))
final$runs_above_avg <- as.double(as.character(final$runs_above_avg))
final$runs_above_avg_adj <- as.double(as.character(final$runs_above_avg_adj))
final$runs_above_rep <- as.double(as.character(final$runs_above_rep))
final$rpo_replacement <- as.double(as.character(final$rpo_replacement))
final$gr_leverage_index_avg <- as.double(as.character(final$gr_leverage_index_avg))
final$war <- as.double(as.character(final$war))
final$opprpg <- as.double(as.character(final$opprpg))
final$pyth_exponent <- as.double(as.character(final$pyth_exponent))
final$waa_win_perc <- as.double(as.character(final$waa_win_perc))
final$waa <- as.double(as.character(final$waa))
final$waa_adj <- as.double(as.character(final$waa_adj))
final$opprpg_rep <- as.double(as.character(final$opprpg_rep))
final$pyth_exponent_rep <- as.double(as.character(final$pyth_exponent_rep))
final$waa_win_perc_rep <- as.double(as.character(final$waa_win_perc_rep))
final$war_rep <- as.double(as.character(final$war_rep))

# At this point you can do a write.csv() and load that into your Lahman instance
# OR
# Use the database connection that you established earlier to wirte a new table directly to Lahman
#Write your data frame back to the dbase. I like to write it as a test table first.
dbWriteTable(con, name='war_pitching', value=final, row.names = FALSE, overwrite = TRUE)


##Now go to the Baseball Reference WAR tables and admire your work!
