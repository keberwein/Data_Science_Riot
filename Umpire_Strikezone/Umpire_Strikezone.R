##The following R code assumes you have an existing pitchRx database. 
##The code for the database connection also assumes you are using a MySQL database, if you are using another database please use the appropriate drive and R package.
##Code by Kris Eberwein produced for www.DataScienceRiot.com

library(DBI)
library(dplyr)
library(ggplot2)
library(RMySQL)
library(pitchRx)
library(mgcv)

#Set working Dir
setwd("~/Documents/R/Baseball/Pitchrx")

#Connect to your MySQL database wiht the RMySQL package
drv = dbDriver("MySQL")
con = dbConnect(dbDriver("MySQL"), user = "root", password = "your_password", dbname = "pitchrx")

#Use SQL to isolate data frame
data = dbSendQuery(con,
                   "SELECT u.name AS umpName, a.batter_name, a.pitcher_name, a.stand, a.p_throws,
                   a.b AS b, a.s AS s, a.o AS o, a.b_height AS b_height,
                   p.x AS x, p.y AS y, p.start_speed AS start_speed, p.end_speed AS end_speed, p.sz_top AS sz_top, p.sz_bot AS sz_top, 
                   p.pfx_x AS pfx_x, p.pfx_z AS pfx_z, p.px AS px, p.pz AS pz, p.x0 AS x0, p.y0 AS y0, p.z0 AS z0, 
                   p.vx0 AS vx0, p.vy0 AS vy0, p.vz0 AS vz0, p.ax AS ax, p.ay AS ay, p.az AS az,
                   p.break_y AS break_y, p.break_angle AS break_angle, p.break_length AS break_length, 
                   p.pitch_type AS pitch_type, p.zone AS zone, p.nasty AS nasty, p.count AS count, p.des AS des,
                   u.id AS ump_id, a.pitcher AS pitcher_id, a.batter AS batter_id
                   
                   FROM atbat a
                   INNER JOIN umpire u
                   ON a.gameday_link = u.gameday_link
                   INNER JOIN pitch p
                   ON p.gameday_link = a.gameday_link
                   
                   WHERE u.position = 'home' AND a.date > '2014_07_01' AND a.date < '2014_09_01'")

#Fetch batting into data frame
umpZone <- fetch(data, n = -1)


#Create list for a specific umpire
Timmons <- filter(umpZone, umpName == 'Tim Timmons')


#Subset Balls and Strikes
TimNoswing <- subset(Timmons, des %in% c("Ball", "Called Strike"))

#Plot actual data
strikeFX(TimNoswing, geom="tile", density1=list(des="Called Strike"), density2=list(des="Ball"), 
         layer=facet_grid(.~stand))

strikeFX(AllNoswing, geom="tile", density1=list(des="Called Strike"), density2=list(des="Ball"), 
         layer=facet_grid(.~stand))


#Probable strike zone
TimNoswing <- subset(Timmons, des %in% c("Ball", "Called Strike"))
TimNoswing$strike <- as.numeric(TimNoswing$des %in% "Called Strike")

#This may take a while. You can use it with large data frames but be cautious, this model is a RAM killer!
library(mgcv)
StrikeModel <- bam(strike ~ s(px, pz, by=factor(stand), k=51) + factor(stand), 
                  method="GCV.Cp", data=TimNoswing, family=binomial(link="logit"))

strikeFX(TimNoswing, model=StrikeModel, layer=facet_grid(.~stand))


#Subset Balls and Strikes
AllNoswing <- subset(umpZone, des %in% c("Ball", "Called Strike"))

#Probable strike zone
AllNoswing$strike <- as.numeric(AllNoswing$des %in% "Called Strike")

StrikeModel2 <- bam(strike ~ s(px, pz, by=factor(stand), k=51) + factor(stand), 
                   method="GCV.Cp", data=AllNoswing, family=binomial(link="logit"))

strikeFX(AllNoswing, model=StrikeModel, layer=facet_grid(.~stand))






