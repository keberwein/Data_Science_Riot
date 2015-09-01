library(forecast)
# Date formatting is bad, convert to correct format
SuperstoreSales$Order.Date <- as.Date(as.character(SuperstoreSales$Order.Date), format="%m/%d/%y")
# Create time sereis
time <- ts(data=SuperstoreSales$Sales, start=c(2010, 1), deltat=1/12)
# Fit into forecsast model
fcast <- forecast(time)
# Determine accuracy of fit
accuracy(fcast)
# Plot fitted model
plot(forecast(time))
lines(fitted(fcast),col="blue")

