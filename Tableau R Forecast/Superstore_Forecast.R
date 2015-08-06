library(forecast)

#Date formatting is bad, convert to correct format
superstore_fit$Order.Date <- as.Date(as.character(superstore_fit$Order.Date), format="%m/%d/%y")
#Create time sereis
ts <- ts(data=superstore_fit$Profit, start=c(2010, 1), deltat=1/12)
#Fit into an ETS forecsast model
fit <- Arima(ts)
fit1 <- ets(ts)
#Determine accuracy of fit
accuracy(fit)
accuracy(fit1)
#Plot fitted model
plot(forecast(ts))
lines(fitted(fit),col="blue")

