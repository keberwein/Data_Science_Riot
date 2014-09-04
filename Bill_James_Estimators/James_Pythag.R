
###The first section of code is used to gather the data from the Lahman database using a RMySQL connection.
###I left the code so anyone who doen't have R connected directly to the dbase can still see the
###required SQL code to gather the requried information.

library(RMySQL)

##Connect to database. Username and password required.
drv = dbDriver("MySQL")
con = dbConnect(dbDriver("MySQL"), user = "root", password = "pass", dbname = "lahman")

#SQl 
JamesPyth = dbSendQuery(con,
"SELECT yearID, teamID
   , R , RA
   , R / (W + L) AS RperG
   , RA / (W + L) AS RAperG   
   , W , L
   , W / (W + L) AS WPct
   , .484 * (R/RA) AS Cook_WPct
   , (.102 * R / (W + L)) - (.103 * RA / (W + L)) + .505 AS Soolman_WPct
   , IF(R > RA, R/(2*RA), (1 - RA/(2*R))) AS Kross_WPct 
   , (R-RA)/(R+RA) + .5 AS Smyth_WPct 
   , POW(R,2) / (POW(R,2) + POW(RA,2)) AS BJames_Pythag_WPct
   , POW(R,1.83) / (POW(R,1.83) + POW(RA,1.83)) AS BJames_Pythag_WPct83
FROM Teams 
WHERE yearID > 1900")

Win = fetch(JamesPyth, n = -1)

##Bill James Pythagorean theorem
#Scatter Plot
plot(Win$WPct, Win$BJames_Pythag_WPct, xlab="winning percentage", 
     ylab = "James Pythagorean", pch=23, col='red')

#Add a line of best fit
abline(lm(Win$WPct~Win$BJames_Pythag_WPct))

#Find R^2
cor(Win$WPct,Win$BJames_Pythag_WPct)

##Bill James Pythagorean (Alternate 1.83)
#Scatter Plot
plot(Win$WPct, Win$BJames_Pythag_WPct83, xlab="winning percentage", 
     ylab = "James Pythagorean 1.83", pch=23, col='red')

#Add a line of best fit
abline(lm(Win$WPct~Win$BJames_Pythag_WPct83))

#Find R^2
cor(Win$WPct,Win$BJames_Pythag_WPct83)

##Earnshaw Cook win percentage
#Scatter Plot
plot(Win$WPct, Win$Cook_WPct, xlab="winning percentage", 
     ylab = "Cook's Estimator", pch=23, col='red')

#Add a line of best fit
abline(lm(Win$WPct~Win$Cook_WPct))

#Find R^2
cor(Win$WPct,Win$Cook_WPct)

##Bill Kross win percentage
#Scatter Plot
plot(Win$WPct, Win$Kross_WPct, xlab="winning percentage", 
     ylab = "Kross' Estimator", pch=23, col='red')

#Add a line of best fit
abline(lm(Win$WPct~Win$Kross_WPct))

#Find R^2
cor(Win$WPct,Win$Kross_WPct)

##David Smythe win percentage
plot(Win$WPct, Win$Smyth_WPct, xlab="winning percentage", 
     ylab = "Smythe's Estimator", pch=23, col='red')

#Add a line of best fit
abline(lm(Win$WPct~Win$Smyth_WPct))

#Find R^2
cor(Win$WPct,Win$Smyth_WPct)

