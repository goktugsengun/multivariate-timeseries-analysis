BIST100 and EUR/TRY Exchange Rate Forecasting
Overview
This project analyzes and forecasts the relationship between the BIST100 index (representing the Turkish stock market) and the EUR/TRY exchange rate using econometric models. It involves preprocessing the data, calculating log returns, cross-correlation analysis, and applying Vector Autoregressive (VAR) models to forecast future values for both variables. The forecasts are compared with actual values, and the prediction results are evaluated using residual analysis and Granger causality tests.

Data
BIST100 Index: Data for the BIST100 index is collected from an external source and includes date and index values.

EUR/TRY Exchange Rate: Data for the EUR/TRY exchange rate is collected and contains the date and closing values.

The datasets are merged by the date column, and rows with missing values are excluded.

Preprocessing Steps
Reading Data: The BIST100 index and EUR/TRY exchange rate data are read from CSV files.

Data Cleaning:

Columns are selected for the date, BIST index, and exchange rate.

Rows with missing or invalid values are removed.

Data Conversion: The 'Date' column is converted to the Date format, and BIST100 and EUR/TRY values are converted to numeric.

Analysis Steps
Log Returns Calculation:

The log returns for both the BIST100 index and the EUR/TRY exchange rate are computed.

The last 10 observations are separated as a test dataset for future forecasting comparison.

Cross-Correlation:

The cross-correlation function (CCF) between the log returns of the BIST100 index and the exchange rate is computed to explore their relationship over time.

VAR Model:

Vector Autoregressive (VAR) models with lag orders 1 and 5 are applied to forecast the log returns for both BIST100 and EUR/TRY.

The AIC and BIC criteria are used for model selection.

Forecasting:

Forecasted values for the next 10 time periods are obtained using the VAR models.

Forecasted values are plotted alongside actual values with upper and lower confidence bounds.

Residual Analysis:

Residuals from the forecasts are analyzed using ACF plots and the Ljung-Box test.

Granger Causality:

Granger causality tests are conducted to assess the causal relationship between the BIST100 index and the EUR/TRY exchange rate at different lags.

Visualization
Plots of the normalized BIST100 and EUR/TRY exchange rate values.

Plots of the log returns over time for both BIST100 and EUR/TRY.

Forecasted vs. actual log returns with confidence intervals for both BIST100 and EUR/TRY.

ACF and Ljung-Box test results for residual analysis.

Libraries Used
psych: For descriptive statistics.

vars: For Vector Autoregressive (VAR) models.

lmtest: For Granger causality tests.

forecast: For forecasting and confidence intervals.

Results
Forecasts for the BIST100 index and the EUR/TRY exchange rate for the next 10 periods are generated.

Residuals and Granger causality tests are conducted to assess model performance and the direction of causality between the variables.

Files
XU100.IS (3).csv: BIST100 index data.

EURTRY=X.csv: EUR/TRY exchange rate data.

forecasting_script.R: The R script with all the analysis, forecasting, and visualization code.

License
This project is licensed under the MIT License.
