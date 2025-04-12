# Please set your directory first
#setwd("/Users/goktug/Desktop/WiSe 23:24/Econometrics of Financial Markets- Seminar")

bist <- read.csv("XU100.IS (3).csv")
bist <- bist[,c(1,5)]
tail(bist)

exchange_rate <- read.csv("EURTRY=X.csv")
exchange_rate <- exchange_rate[,c(1,5)]
exchange_rate

data <- merge(bist, exchange_rate, by = "Date")
colnames(data) <- c("Date", "BistIndex", "ExchangeRate")
colnames(data)

# Remove rows where row value is "null"
data <- data[data$BistIndex != "null", ]
data <- data[data$ExchangeRate != "null", ]
data

data

str(data$BistIndex)

##################

data$Date <- as.Date(data$Date) 
time <- data$Date


n <- length(data$Date)	#length

# Remove rows with any missing values
data <- na.omit(data)
time <- as.Date(data$Date, format = "%d/%m/%Y")	#recognize as time 

# convert variables to numbers. There was a problem with the data 
#    So i fixed it by dividing some bist index observations by 100
data$BistIndex <- as.numeric(data$BistIndex)
data$BistIndex[1:389] <- data$BistIndex[1:389] / 100
data$ExchangeRate <- as.numeric(data$ExchangeRate)
data 





#########

# Plotting BIST log returns
plot(data$Date, scale(data$BistIndex), type = "l", col = "blue", lwd = 1,
     xlab = "Time", ylab = "Normalized Values", main = "BIST & EUR/TRY")
lines(data$Date, scale(data$ExchangeRate), col = "red", lwd = 1)
legend("topleft", legend = c("BIST", "Exchange Rate"), col = c("blue", "red"), lty = 1, lwd = 1)





# install.packages("psych")
library(psych)
# Descriptive statistics 
bist_stats <- describe(data$BistIndex)

exchange_rate_stats <- describe(data$ExchangeRate)

bist_stats <- summary(data$BistIndex)

exchange_rate_stats <- summary(data$ExchangeRate)


n <- length(data$Date)



#last 10 logreturns are separated as a testing data for forecasting comparison

bist_logreturns <- 100*diff(log(data$BistIndex), lag=1) 
last10_bist_returns <- bist_logreturns[(n-9):n-1]
bist_logreturns <- bist_logreturns[1:(n-11)]
tail(bist_logreturns)

exchangeRate_logreturns <- 100*diff(log(data$ExchangeRate), lag=1)
last10_exchangeRate_logreturns <- exchangeRate_logreturns[(n-9):n-1]
exchangeRate_logreturns <- exchangeRate_logreturns[1:(n-11)]

time_for_returns <- time[2:(n-10)]		#remove the first, and last 10
length(time_for_returns)



describe(bist_logreturns)
describe(exchangeRate_logreturns)


# Plotting BIST log returns
plot(time_for_returns, bist_logreturns, type = "l", col = "blue", lwd = .5,
     xlab = "Time", ylab = "Log Returns", main = "Log Returns Over Time")
lines(time_for_returns, exchangeRate_logreturns, col = "red", lwd = .5)
legend("topleft", legend = c("BIST", "Exchange Rate"), col = c("blue", "red"), lty = 1, lwd = 1)



mean(bist_logreturns)
mean(exchangeRate_logreturns)
var(bist_logreturns)
var(exchangeRate_logreturns)


# Explore cross-correlations between BIST100 and exchange rate
cross_corr <- ccf(exchangeRate_logreturns, bist_logreturns, lag.max = 10)
plot(cross_corr, main = "Cross Correlations")



library(vars)

data2 <- data.frame(time_for_returns = time_for_returns, bist_logreturns = bist_logreturns, exchangeRate_logreturns = exchangeRate_logreturns)
str(data2)

# Create a time series object
ts_data <- ts(data2[, c("bist_logreturns", "exchangeRate_logreturns")], frequency = 1)


var_select_result <- VARselect(ts_data, lag.max = 10)
# Extract AIC values
aic_values <- var_select_result$criteria[1,]
# Create a data frame
aic_data <- data.frame(Lag_Order = 1:10, AIC = aic_values)

n <- length(time_for_returns)
p <- aic_data$Lag_Order

bic <- aic_data$AIC  + (log(n)-2) * p
bic
round(t(data.frame(AICScore = aic_data, BICScore = bic)),3)








par(mfrow = c(1,2))

#var_model. daily
var_model <- VAR(ts_data, p = 1)

residuals <- residuals(var_model)

residuals_bist <- residuals[,1]
acf(residuals_bist)
Box.test(residuals_bist, lag = 1, type = "Ljung-Box")

residuals_exchange <- residuals[,2]
acf(residuals_exchange)
Box.test(residuals_exchange, lag = 1, type = "Ljung-Box")


#var_model. 5 days
var_model5 <- VAR(ts_data, p = 5)

residuals5 <- residuals(var_model5)
residuals_bist5 <- residuals5[,1]

acf(residuals_bist5)
Box.test(residuals_bist5, lag = 5, type = "Ljung-Box")

residuals_exchange5 <- residuals5[,2]
acf(residuals_exchange5)
Box.test(residuals_exchange5, lag = 5, type = "Ljung-Box")



# Forecast future values          #1
forecast_values1 <- predict(var_model, n.ahead = 10)
# Extract forecasted series
forecasted_series1 <- forecast_values1$fcst

####################################################################################

# Forecast future values.        #5
forecast_values5 <- predict(var_model5, n.ahead = 10)
# Extract forecasted series
forecasted_series5 <- forecast_values5$fcst







par(mfrow = c(1, 2))
#######################bist returns for lag = 1
last10_bist_returns[-n]
prediction <- forecasted_series1$bist_logreturns[,"fcst"]
upper <- forecasted_series1$bist_logreturns[,"upper"]
lower <- forecasted_series1$bist_logreturns[,"lower"]

time_last10 <- seq(10)

# Plot the predicted and actual values with upper and lower bounds
plot(time_last10, last10_bist_returns, type = "o", col = "blue", 
     pch = 16, ylim = range(c(last10_bist_returns, prediction, upper, lower)),
     xlab = "Time", ylab = "BIST Log Returns")
lines(time_last10, prediction, col = "red", pch = 16, type = "o")
lines(time_last10, upper, col = "green", lty = 2)
lines(time_last10, lower, col = "green", lty = 2)
legend("topright", legend = c("Actual", "Predicted", "Upper Bound", "Lower Bound"), 
       col = c("blue", "red", "green", "green"), pch = 16, lty = c(1, 1, 2, 2),
       cex = 0.7)

#######################exchange rate returns for lag = 1


last10_exchangeRate_logreturns
prediction <- forecasted_series1$exchangeRate_logreturns[,"fcst"]
upper <- forecasted_series1$exchangeRate_logreturns[,"upper"]
lower <- forecasted_series1$exchangeRate_logreturns[,"lower"]


# Plot the predicted and actual values with upper and lower bounds
plot(time_last10, last10_exchangeRate_logreturns, type = "o", col = "blue", 
     pch = 16, ylim = range(c(last10_exchangeRate_logreturns, prediction, upper, lower)),
     xlab = "Time", ylab = "Exchange Rate Log Returns")
lines(time_last10, prediction, col = "red", pch = 16, type = "o")
lines(time_last10, upper, col = "green", lty = 2)
lines(time_last10, lower, col = "green", lty = 2)
legend("topright", legend = c("Actual", "Predicted", "Upper Bound", "Lower Bound"), 
       col = c("blue", "red", "green", "green"), pch = 16, lty = c(1, 1, 2, 2), 
       cex = 0.7)

par(mfrow = c(1, 1))
main_title <- "Actual vs. Predicted Returns for Next 10 Observations with Confidence Intervals
Lag Order 1"
mtext(main_title, side = 3, line = 1, cex = 1.2)



################
################
################
################
################
################
################
################
################







par(mfrow = c(1, 2))
#######################bist returns for lag = 5
last10_bist_returns
prediction <- forecasted_series5$bist_logreturns[,"fcst"]
upper <- forecasted_series5$bist_logreturns[,"upper"]
lower <- forecasted_series5$bist_logreturns[,"lower"]


# Plot the predicted and actual values with upper and lower bounds
plot(time_last10, last10_bist_returns, type = "o", col = "blue", 
     pch = 16, ylim = range(c(last10_bist_returns, prediction, upper, lower)),
     xlab = "Time", ylab = "BIST Log Returns")
lines(time_last10, prediction, col = "red", pch = 16, type = "o")
lines(time_last10, upper, col = "green", lty = 2)
lines(time_last10, lower, col = "green", lty = 2)
legend("topright", legend = c("Actual", "Predicted", "Upper Bound", "Lower Bound"), 
       col = c("blue", "red", "green", "green"), pch = 16, lty = c(1, 1, 2, 2),
       cex = 0.7)

#######################exchange rate returns for lag = 5


last10_exchangeRate_logreturns
prediction <- forecasted_series5$exchangeRate_logreturns[,"fcst"]
upper <- forecasted_series5$exchangeRate_logreturns[,"upper"]
lower <- forecasted_series5$exchangeRate_logreturns[,"lower"]


# Plot the predicted and actual values with upper and lower bounds
plot(time_last10, last10_exchangeRate_logreturns, type = "o", col = "blue", 
     pch = 16, ylim = range(c(last10_exchangeRate_logreturns, prediction, upper, lower)),
     xlab = "Time", ylab = "Exchange Log Rate Returns")
lines(time_last10, prediction, col = "red", pch = 16, type = "o")
lines(time_last10, upper, col = "green", lty = 2)
lines(time_last10, lower, col = "green", lty = 2)
legend("topright", legend = c("Actual", "Predicted", "Upper Bound", "Lower Bound"), 
       col = c("blue", "red", "green", "green"), pch = 16, lty = c(1, 1, 2, 2), 
       cex = 0.7)

par(mfrow = c(1, 1))
main_title <- "Actual vs. Predicted Returns for Next 10 Observations with Confidence Intervals
Lag Order 5"
mtext(main_title, side = 3, line = 1, cex = 1.2)



### bist prediction with lag 1 
prediction_bist_lag1 <- forecasted_series1$bist_logreturns[,"fcst"]
residuals1b <- last10_bist_returns - prediction_bist_lag1
### exchange rate prediction with lag 1
prediction_exchange_lag1 <- forecasted_series1$exchangeRate_logreturns[,"fcst"]
residuals1e <- last10_exchangeRate_logreturns - prediction_exchange_lag1

### bist prediction with lag 5
prediction_bist_lag5 <- forecasted_series5$bist_logreturns[,"fcst"]
residuals5b <- last10_bist_returns - prediction_bist_lag5
### exchange rate prediction with lag 5
prediction_exchange_lag5 <- forecasted_series5$exchangeRate_logreturns[,"fcst"]
residuals5e <- last10_exchangeRate_logreturns - prediction_exchange_lag5




residual_analysis <- function(residuals, lag, header) {
  # ACF Plot
  acf(residuals, main = header)
  
  # Ljung-Box Test
  ljung_box_test <- Box.test(residuals, lag = lag, type = "Ljung-Box")
  ljung_box_p_value <- ljung_box_test$p.value
  print(ljung_box_p_value)
}

par(mfrow=c(2,2))
# 
residual_analysis(residuals1b, 1, "BIST - Lag 1")
residual_analysis(residuals1e, 1, "ExchangeRate - Lag 1")
residual_analysis(residuals5b, 5, "BIST - Lag 5")
residual_analysis(residuals5e, 5, "ExchangRate - Lag 5")


## Granger Causality Test

library(lmtest)



granger_test_result1b <- grangertest(bist_logreturns ~ exchangeRate_logreturns, order = 1, data = ts_data)
granger_test_result1e <- grangertest(exchangeRate_logreturns ~ bist_logreturns, order = 1, data = ts_data)
granger_test_result5b <- grangertest(bist_logreturns ~ exchangeRate_logreturns, order = 5, data = ts_data)
granger_test_result5e <- grangertest(exchangeRate_logreturns ~ bist_logreturns, order = 5, data = ts_data)


granger_test_result1b
granger_test_result1e
granger_test_result5b
granger_test_result5e
