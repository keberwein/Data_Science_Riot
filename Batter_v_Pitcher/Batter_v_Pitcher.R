library(DBI)
library(dplyr)
library(ggplot2)
library(pitchRx)

#Set working Dir
setwd("~/Documents/R/")

#Create connection to pitchRx database
db <- src_sqlite('/home/dumps/pitchRx.sqlite3')

#Create Subset
atbat08 <- filter(tbl(db, 'atbat'), date >= '2008_01_01' & date <= '2013_01_01')

#Explain Subset
explain(atbat08)

#Create list for player
lee08 <- filter(atbat08, pitcher_name == 'Cliff Lee')

#Join atbat and pitch tables
pitches <- tbl(db, 'pitch')
lee08 <- inner_join(pitches, lee08, by = c('num', 'gameday_link'))

#Collect Data
cliffLee08 <- collect(lee08)

#See Summary
summary(cliffLee08)

####################################################
#Pitch Types
#Create subset with differant pitch types
LeePtype <- subset(cliffLee08, !(pitch_type  %in%  c("IN",  "")))

#Find Pitch type and Stand
cliffLee08 %.%
  group_by(pitch_type, stand) %>%
  summarise(count = n()) %>%
  arrange(desc(count))

#Plot pitch types
ggplot(data = LeePtype) +
  stat_density2d(geom="tile", aes(x = px, y = pz, fill = ..density..), contour = F, data = cliffLee08) +
  facet_wrap(~pitch_type) +
  scale_x_continuous("horizontal pitch location") +
  scale_y_continuous("vertical pitch location") +
  coord_cartesian(xlim = c(-2, 2), ylim = c(1, 4))

#Plot pitches near strikezone
strikeFX(cliffLee08, color="", layer=facet_grid(s~stand))+
  geom_point(aes(x=px, y=pz, shape=pitch_types))+ 
  geom_text(aes(x=px+0.5, y=pz, label=b))

p <- strikeFX(cliffLee08, geom="tile", layer=facet_grid(.~stand))
p+theme(aspect.ratio=1)

strikeFX(cliffLee08, geom="hex", density1=list(des="Called Strike"), density2=list(des="Ball"),
         draw_zones=FALSE, contour=TRUE, layer=facet_grid(.~stand))
noswing <- subset(pitches, des %in% c("Ball", "Called Strike"))

noswing$strike <- as.numeric(noswing$des %in% "Called Strike")

library(mgcv)
m1 <- bam(strike ~ s(px, pz, by=factor(stand)) +
            factor(stand), data=noswing, family = binomial(link='logit'))
strikeFX(noswing, model=m1, layer=facet_grid(.~stand))

#Plot Strikes
strikes <- subset(cliffLee08, des == "Called Strike")
strikeFX(strikes, geom="tile", layer=facet_grid(.~stand))

#Against a Specific Batter
Lee_v_Mags_08 <- subset(cliffLee08, batter_name == "Miguel Cabrera")
MagsPitchTypes <- subset(Lee_v_Mags_08, !(pitch_type  %in%  c("IN",  "")))
MagsStrikes <- subset(Lee_v_Mags_08, des == "Called Strike")

ggplot(data = MagsPitchTypes) +
  stat_density2d(geom="tile", aes(x = px, y = pz, fill = ..density..), contour = F, data = MagsPitchTypes) +
  facet_wrap(~pitch_type) +
  scale_x_continuous("horizontal pitch location") +
  scale_y_continuous("vertical pitch location") +
  coord_cartesian(xlim = c(-2, 2), ylim = c(1, 4))

#Find Pitch type and Stand
Lee_v_Mags_08 %>%
  group_by(pitch_type, stand) %>%
  summarise(count = n()) %>%
  arrange(desc(count))


