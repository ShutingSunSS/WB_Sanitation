#install.packages('WDI')
#install.packages('wbstats')
#install.packages('ggplot2')

library(ggplot2)
library(WDI)
library(wbstats)
library(dygraphs)
library(dplyr)

rm(list=ls()) # clear environment

indicators_sanitation = 'SH.STA.SMSS.ZS'
indicators_population = 'SP.POP.TOTL'

countries_incomelevel <- function(inc) {  # a function, given an income level, get the 'iso3c' list of all the countries in that income level
  df_countries = wbcountries()
  countries = df_countries[which(df_countries$incomeID == inc), "iso3c"]
  return(countries)
}

dataset_incomelevel <- function(inc){  # a function, given an income level, return the data set with the safely managed sanitation facilities (%) each year
  data_LIC = WDI(indicator=c(indicators_sanitation, indicators_population), 
                 country = countries_incomelevel(inc),  start=1960, end=2018) # get the sanitaion and population data (1960 to 2018)
  
  data_clean = data_LIC[complete.cases(data_LIC), ] # only keep the rows with both population data and sanitation data
  
  data_clean$total <- data_clean$SH.STA.SMSS.ZS * data_clean$SP.POP.TOTL # total = population * sanitation(%)
  
  total_population = aggregate(SP.POP.TOTL ~ year, data_clean, sum) # group the dataframe by "year", and sum the "population"
  total_sanitation = aggregate(total ~ year, data_clean, sum) # group the dataframe by "year", and sum the "total"
  
  data_sum = merge(x = total_population, y = total_sanitation, by = "year", all = TRUE) # merge the above two dataset
  
  data_sum$trend <- data_sum$total / data_sum$SP.POP.TOTL # here is the weighted arithmetic mean of the sanitation (%population) data
  data_sum$IncomeLevel <- rep(inc,nrow(data_sum)) # add an IncomeLevel column
  return(data_sum)
}

data1 = dataset_incomelevel("LIC")
data2 = dataset_incomelevel("LMC")
data3 = dataset_incomelevel("UMC")
data4 = dataset_incomelevel("HIC")

data1_select = select(data1, year, trend); 
names(data1_select)[names(data1_select) == 'trend'] <- 'LIC'
data2_select = select(data2, trend)
names(data2_select)[names(data2_select) == 'trend'] <- 'LMC'
data3_select = select(data3, trend)
names(data3_select)[names(data3_select) == 'trend'] <- 'UMC'
data4_select = select(data4, trend)
names(data4_select)[names(data4_select) == 'trend'] <- 'HIC'
data_select =cbind(data1_select, data2_select, data3_select, data4_select)
# xts(data_select$trend, as.Date(data_select$year, format='%m/%d/%Y')
dygraph(data_select, main = "Sanitation Access (%population)", 
        ylab = "Sanitation(%)", xlab = "Year") %>%
  dyHighlight(highlightCircleSize = 5, 
              highlightSeriesBackgroundAlpha = 0.2,
              hideOnMouseOut = FALSE)
