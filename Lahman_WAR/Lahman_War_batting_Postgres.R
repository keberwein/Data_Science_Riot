#Load packages and install if you don't have them
require(DBI)
require(RPostgreSQL)
require(dplyr)

# Get the data from Baseball Reference
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "http://www.baseball-reference.com/data/war_daily_bat.txt"
download.file(fileUrl, destfile="war_daily_bat.csv", method="curl")

# Write the download to a data frame
df <- read.csv("war_daily_bat.csv", header=TRUE, stringsAsFactors=FALSE)

# Write the download to a data frame
df <- read.csv("war_daily_bat.csv", header=TRUE)

# Connect to your Lahman instance so we can grab some data from the master table
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host= "localhost", dbname = "lahman", 
                 user="YOUR USERNAME", password="YOUR PASSWORD")

# SQL the database for playerid on the master table "bbrefid" are the Baseball Reference ids
master <- dbSendQuery(con, "SELECT playerid, bbrefid FROM master")
m <- fetch(master, n = -1)

# SQL on the teams table to match Baseball Ref team_ID
teams <- dbSendQuery(con, "SELECT yearid, teamid, teamidbr FROM teams")
t <- fetch(teams, n = -1)

# Join master and war data frames
df2 <- left_join(df, m, by = c("player_ID" = "bbrefid"))

# Convert and rename a few things in the teams dataframe to make the join smooth
t$teamidbr <- as.factor(t$teamidbr)
names(t)[names(t)=="teamidbr"] <- "team_ID"
names(t)[names(t)=="yearid"] <- "year_ID"

# Now we index the teams
df3 <- left_join(df2, t)

# Reorder data frame
final <- subset(df3, select = c(playerid, year_ID, age, teamid, stint_ID, lg_ID, PA, G, 
                                Inn, runs_bat, runs_br, runs_dp, runs_field, runs_infield, 
                                runs_outfield, runs_catcher, runs_good_plays, runs_defense, 
                                runs_position, runs_position_p, runs_replacement, runs_above_rep, 
                                runs_above_avg, runs_above_avg_off, runs_above_avg_def, WAA, WAA_off, 
                                WAA_def, WAR, WAR_def, WAR_off, WAR_rep, salary, pitcher, teamRpG, 
                                oppRpG, oppRpPA_rep, oppRpG_rep, pyth_exponent, pyth_exponent_rep, 
                                waa_win_perc, waa_win_perc_off, waa_win_perc_def, waa_win_perc_rep))

# Rename a couple of columns in our new tidy data set to fit to Lahman standards
names(final)[names(final)=="stint_ID"] <- "stint"
names(final)[names(final)=="lg_ID"] <- "lgid"
names(final)[names(final)=="year_ID"] <- "yearid"
names(final)[names(final)=="team_ID"] <- "teamid"

# IMPORTANT: Postgres users:
# Postgres WILL yell at you if you don't format these properly! Convert all colnames to lowercase!
names(final)[-1:-3] <- tolower(names(final)[-1:-3])

# Clean up the data types before loading into Lahman
# This part is nausiating but necessary...
final$age <- as.integer(as.character(final$age))
final$stint <- as.integer(as.character(final$stint))
final$pa <- as.integer(as.character(final$pa))
final$g <- as.integer(as.character(final$g))
final$inn <- as.integer(as.character(final$inn))
final$runs_bat <- as.double(as.character(final$runs_bat))
final$runs_br <- as.double(as.character(final$runs_br))
final$runs_dp <- as.double(as.character(final$runs_dp))
final$runs_field <- as.double(as.character(final$runs_field))
final$runs_infield <- as.double(as.character(final$runs_infield))
final$runs_outfield <- as.double(as.character(final$runs_outfield))
final$runs_catcher <- as.double(as.character(final$runs_catcher))
final$runs_good_plays <- as.double(as.character(final$runs_good_plays))
final$runs_position <- as.double(as.character(final$runs_position))
final$replacement <- as.double(as.character(final$replacement))
final$runs_above_rep <- as.double(as.character(final$runs_above_rep))
final$runs_above_avg <- as.double(as.character(final$runs_above_avg))
final$runs_above_avg_off <- as.double(as.character(final$runs_above_avg_off))
final$runs_above_avg_def <- as.double(as.character(final$runs_above_avg_def))
final$waa <- as.double(as.character(final$waa))
final$waa_off <- as.double(as.character(final$waa_off))
final$waa_def <- as.double(as.character(final$waa_def))
final$war <- as.double(as.character(final$war))
final$war_def <- as.double(as.character(final$war_def))
final$war_off <- as.double(as.character(final$war_off))
final$war_rep <- as.double(as.character(final$war_rep))
final$salary <- as.integer(as.character(final$salary))
final$teamrpg <- as.double(as.character(final$teamrpg))
final$opprpg <- as.double(as.character(final$opprpg))
final$opprpg_rep <- as.double(as.character(final$opprpg_rep))
final$opprppa_rep <- as.double(as.character(final$opprppa_rep))
final$pyth_exponent <- as.double(as.character(final$pyth_exponent))
final$pyth_exponent_rep <- as.double(as.character(final$pyth_exponent_rep))
final$waa_win_perc <- as.double(as.character(final$waa_win_perc))
final$waa_win_perc_off <- as.double(as.character(final$waa_win_perc_off))
final$waa_win_perc_def <- as.double(as.character(final$waa_win_perc_def))
final$waa_win_perc_rep <- as.double(as.character(final$waa_win_perc_rep))

# At this point you can do a write.csv() and load that into your Lahman instance
# OR
# Use the database connection that you established earlier to wirte a new table directly to Lahman
#Write your data frame back to the dbase. I like to write it as a test table first.
dbWriteTable(con, name='war_batting', value=final, row.names = FALSE, overwrite = TRUE)

##Now go to the Baseball Reference WAR tables and admire your work!
