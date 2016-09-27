require(forecast)

###Forecast the Gross Domestic Product

#Set date type
gdp$Date <- as.Date(as.character(gdp$Date), "%Y-%m-%d")

#Set GDP numeric type
gdp$GDP <- as.numeric(as.character(gdp$GDP))

#Create time series vector from data frame
gdpts <- ts(data=gdp$GDP, start=c(1947, 1), deltat=3/12)

#Forecast and Plot
plot(forecast.ets(gdpts))

summary(forecast(gdpts))



###Forecast Major League Homeruns

#Set numeric data type
HR$Homeruns <- as.numeric(as.character(HR$Homeruns))

#Create time series vector from data frame
hrts <- ts(data=HR$Homeruns, start=c(1947, 1))

#Forecast and Plot
plot(forecast(hrts), main="Homeruns")

summary(forecast(hrts))



