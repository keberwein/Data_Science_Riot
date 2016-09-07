# Provides forulas for calculating the coefficient correlation of several baseball battig metrics.

# The first section of code is used to gather the data from the Lahman database using a RMySQL connection.
# I left the code so anyone who doen't have R connected directly to the dbase can still see the
# required SQL code to gather the requried information.

library(RMySQL)

drv <- dbDriver("MySQL")
con <- dbConnect(dbDriver("MySQL"), user = "root", password = "password", dbname = "lahman")


# Note the join on the table "Guts." This is a custom table that includes yearly wOBA values
# The Guts table is only required for wOBA, you can delet the join and the wOBA calculation or
# you can go to Fangraphs.com and download the Guts table to add to your own database.

teams <- dbSendQuery(con,
"SELECT t.yearID, t.teamID, t.name,

t.AB, t.H, t.2B, t.3B, t.HR, t.R, t.SB,

t.H / t.AB AS BA,

(t.H + t.BB + t.HBP) / (t.AB + t.BB + t.HBP + t.SF) AS OBP,

((t.H + t.BB + t.HBP) / (t.AB + t.BB + t.HBP + t.SF)) + (((t.H-t.2B-t.3B-t.HR) + (2 * t.2B) + (3 * t.3B) + (4 * t.HR))/t.AB) AS OPS,

(t.H + t.2B + 2 * t.3B + 3 * t.HR) / t.AB AS SLG,

(g.wBB * (t.BB) + g.wHBP * t.HBP + g.w1B * (t.H-t.2B-t.3B-t.HR) + g.w2B * t.2B + g.w3B * t.3B + g.wHR * t.HR) /
(t.AB + t.BB + t.SF + t.HBP) AS wOBA

FROM Teams t
Join Guts g
ON g.yearID = t.yearID
WHERE t.yearID > 2000
")


Batting <- fetch(teams, n = -1)

#Batting average
plot(Batting$R, Batting$BA, xlab="Runs", 
     ylab = "BA", pch=23, col='red')
     
abline(lm(Batting$BA~Batting$R))

cor(Batting$BA,Batting$R)

#OBP

plot(Batting$R, Batting$OBP, xlab="Runs", 
     ylab = "OBP", pch=23, col='purple')

abline(lm(Batting$OBP~Batting$R))

cor(Batting$R,Batting$OBP)

#Slugging 
plot(Batting$R, Batting$SLG, xlab="Runs", 
     ylab = "SLG", pch=23, col='green')

abline(lm(Batting$SLG~Batting$R))

cor(Batting$R,Batting$SLG)

#OPS
plot(Batting$R, Batting$OPS, xlab="Runs", 
     ylab = "OPS", pch=23, col='blue')

abline(lm(Batting$OPS~Batting$R))

cor(Batting$R,Batting$OPS)

#wOBA
#Note, this wOBA calculation DOES NOT account for IBB but applies weights to the OPS formula.
plot(Batting$R, Batting$wOBA, xlab="Runs", 
     ylab = "wOBA", pch=23, col='brown')

abline(lm(Batting$wOBA~Batting$R))

cor(Batting$R,Batting$wOBA)




