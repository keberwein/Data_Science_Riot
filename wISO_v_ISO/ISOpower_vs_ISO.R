##Provides forulas for calculating the coefficient correlation of several baseball battig metrics.

###The first section of code is used to gather the data from the Lahman database using a RMySQL connection.
###I left the code so anyone who doen't have R connected directly to the dbase can still see the
###required SQL code to gather the requried information.

library(RMySQL)

drv <- dbDriver("MySQL")
con <- dbConnect(dbDriver("MySQL"), user = "YOUR_USERNAME", 
                            password = "YOUR_PASSWORD", dbname = "lahman")

##SQL get dat
teams <- dbSendQuery(con,
                    "SELECT t.yearID, t.teamID, t.name, R,            
                    t.H / t.AB AS BA,
                    (t.H + t.2B + 2 * t.3B + 3 * t.HR) / t.AB AS SLG,
                    (t.2B) + (1.9*t.3B) + (3.17*t.HR) / t.AB AS wISO,
                    (t.2B) + (2*t.3B) + (3*t.HR) / AB AS ISO
                    FROM Teams t
                    Join Guts g
                    ON g.yearID = t.yearID
                    WHERE t.yearID > 1900 AND t.yearID <> 1981 AND t.yearID <> 1994
                    ")

Batting <- fetch(teams, n = -1)

#Batting average
plot(Batting$R, Batting$BA, xlab="Runs", 
     ylab = "BA", pch=23, col='red')

abline(lm(Batting$BA~Batting$R))

cor(Batting$R,Batting$BA)

#Slugging 
plot(Batting$R, Batting$SLG, xlab="Runs", 
     ylab = "SLG", pch=23, col='green')

abline(lm(Batting$SLG~Batting$R))

cor(Batting$R,Batting$SLG)

#wISO
plot(Batting$R, Batting$wISO, xlab="Runs", 
     ylab = "wISO", pch=23, col='red')

abline(lm(Batting$wISO~Batting$R))

cor(Batting$R,Batting$wISO)

#ISO
plot(Batting$R, Batting$ISO, xlab="Runs", 
     ylab = "ISO", pch=23, col='red')

abline(lm(Batting$ISO~Batting$R))

cor(Batting$R,Batting$ISO)
