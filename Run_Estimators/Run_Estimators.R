##Provides forulas for calculating the coefficient correlation of several baseball battig metrics.

###The first section of code is used to gather the data from the Lahman database using a RMySQL connection.
###I left the code so anyone who doen't have R connected directly to the dbase can still see the
###required SQL code to gather the requried information.

library(RMySQL)

drv = dbDriver("MySQL")
con = dbConnect(dbDriver("MySQL"), user = "root", password = "password", dbname = "lahman")

##SQL get dat
teams = dbSendQuery(con,
"SELECT yearID, teamID, name,

AB, H, 2B, 3B, HR, R, SB,

H / AB AS BA,

(H + BB + HBP) / (AB + BB + HBP + SF) AS OBP,

((H + BB + HBP) / (AB + BB + HBP + SF)) + (((H-2B-3B-HR) + (2 * 2B) + (3 * 3B) + (4 * HR))/AB) AS OPS,

(H + 2B + 2 * 3B + 3 * HR) / AB AS SLG

FROM Teams

WHERE yearID > 2000")


Batting = fetch(teams, n = -1)

#Batting average
plot(Batting$R, Batting$BA, xlab="Runs", 
     ylab = "BA", pch=23, col='red')
     
abline(lm(Batting$BA~Batting$R))

cor(Batting$R,Batting$BA)

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



