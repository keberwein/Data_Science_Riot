library(reshape2)
library(plyr)
# Melt pitch types into single column
NewData <- melt(FanGraphs.Leaderboard,
  Name=c("Fastball", "Two.seam.FB", "Cutter", "Splitter", "Sinker", "Slider", "Curveball", 
         "Knuckle.Curve", "Eephus", "Changeup", "Split.Curve"))
FinalData <- rename(NewData, c("variable"="PitchType", "value"="Speed"))
# Remove rows where pitch speed is NA
FinalData <- na.omit(FinalData)
# Write to csv
write.csv(FinalData, file="pitching_leaders.csv", row.names=FALSE)
