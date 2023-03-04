library(dplyr)
library(tidyverse)
library(lubridate)
library(readr)
library(tibble)
library(ggplot2)
#Financial market Statistics 
# we chose only last 60 months, or 5 years 
#last date data was updated is data February 15, 2023
#first date is February 15th (or closets to it),2018 

##set directory to subfolder 

dir<- file.path(getwd(), "R", "Assignment")
setwd(dir)
getwd()
rm(dir)
colSelect<-c("REF_DATE","Rates","VECTOR","VALUE","STATUS")
colTypes<-cols(REF_DATE = col_date(format = "%m/%d/%Y"))

finData = read_csv("findata.csv", col_select=colSelect,  col_types = colTypes) #data was renamed, file findata.csv contains full statistics for all years
rm(colSelect,colTypes)

glimpse(finData)

#select subset for the last five years
finData%>%select("Rates","VECTOR")%>%distinct()

View(finData)
#VECTOR is id for time series corresponding to specific rate, we are interested in specific 3 VECTORs:
# bank rate
# Chartered bank administered interest rates - Prime rate
# Treasury Bills: 3 month *influences bank rate - I am curious.

#ratesOfInterest<-c("v80691310","v80691311","v80691344") #Bank rate 

ratesOfInterest<-c("v80691310","v80691311") #Bank rate 

#I want to reduce rows to last 5 years flooring it to January, 1st
# and only rates of my interest (3 vectors)
latest_date <- finData%>%summarise(max_date = max(REF_DATE))%>%pull(max_date )
earliest_date<- floor_date(latest_date - years(5),"year")
earliest_date

ratesLast5Year<-finData%>%
  filter(REF_DATE >= earliest_date & VECTOR %in% ratesOfInterest)

glimpse(ratesLast5Year)

# Min and Max date in my tibble just to there it is 5 year period
ratesLast5Year %>%
  summarise(min_date = min(REF_DATE),
            max_date = max(REF_DATE)) #It is good


# counting amount of empty values
total_rows = nrow(ratesLast5Year)
total_rows
ratesLast5Year %>% 
  filter(STATUS == "..")%>%
  summarise("Count rows with empty values" = n(),
            "Percent rows with empty values, %" = round(n()*100/total_rows,digits=2))

# Showing rows with epty values 
ratesLast5Year %>% 
  group_by(VECTOR )%>%
  mutate(weekday=weekdays(REF_DATE),before=lag(VALUE), after=lead(VALUE))%>%
  filter(STATUS == "..")

# I am filtering them out
ratesDf<-ratesLast5Year %>% 
  filter(STATUS != ".."|is.na(STATUS))
glimpse(ratesDf)

#a. The average bank rate and prime rate (i.e Chartered bank administered interest rates -
#Prime rate) in each 6-months period over the past 5 years. Do not show other variables
#in the output
# I expect to have 5*2=10 periods plus small period of 2023, total 11 periods

ratesDf6Month<-ratesDf %>%
  mutate(period = floor_date(REF_DATE, unit = "6 months"))
glimpse(ratesDf6Month)

#Checking Periods and dates that fall into periods, I keep it connected to first day of year and 
ratesDf6Month%>%select(period,REF_DATE)%>%
  group_by(period)%>%
  summarise(min=min(REF_DATE),max=max(REF_DATE))

## Answer A Summarizing rates
average_rates<-ratesDf6Month%>%filter(VECTOR %in% c("v80691310","v80691311"))%>%
  group_by(period, Rates)%>%
  summarise("Average 6 month rate" =mean(VALUE))%>%
  arrange(Rates)

View(average_rates)
# print(average_rates, n = 22)
cat("\014")


# b. The average rate change period in days (i.e how many days in average between consecutive rate changes)? 
periods_bank_rates<-ratesDf%>%filter(VECTOR %in% c("v80691310"))%>%
  group_by(grp = cumsum(VALUE != lag(VALUE, default = first(VALUE))))%>%
  summarise(start_date = min(REF_DATE), 
            end_date = max(REF_DATE), 
            duration = end_date - start_date + 1, 
            value = first(VALUE))

periods_bank_rates

periods_bank_rates%>%
  arrange(duration)

#Visualize
ggplot(data = ratesDf, aes(x = REF_DATE, y = VALUE, color = Rates)) +
  geom_line() +
  xlab("Time") +
  ylab("Rate value(%)") +
  ggtitle("Duration of rates")

glimpse(ratesDf)



#period: 2020-04-01 2022-03-02 is suspect

check<-ratesDf%>%filter(VECTOR %in% c("v80691310"),
                 REF_DATE>=as.Date('2020-04-01') & REF_DATE<=as.Date('2022-03-02'))

#need to visualize in the future 

View(check)
#Checking if it works


mean_bank_rate_duration <- periods_bank_rates%>%
  summarise(mean_duration=round(mean(duration),0))%>%
  pull(mean_duration)

cat("Mean of duration for bank rate is: ", mean_bank_rate_duration, " days")
cat("Which is approximately ", mean_bank_rate_duration/30.44, "months")

periods_prime_rates<-ratesDf%>%filter(VECTOR %in% c("v80691311"))%>%
  group_by(grp = cumsum(VALUE != lag(VALUE, default = first(VALUE))))%>%
  summarise(start_date = min(REF_DATE), 
            end_date = max(REF_DATE), 
            duration = end_date - start_date + 1, 
            value = first(VALUE))

periods_prime_rates

mean_prime_rate_duration <- periods_prime_rates%>%
  summarise(mean_duration=round(mean(duration),0))%>%
  pull(mean_duration)


cat("Mean of duration for prime rate is: ", mean_prime_rate_duration)


# Idea of Solution from https://stackoverflow.com/questions/62990396/dpylr-solution-for-cumsum-with-a-factor-reset


#c. Unique (Distinct) bank rates and the frequency of each 
#(i.e the repetitions: in how many months did each bank rate appear). 

frequency_rates<-ratesDf%>%filter(VECTOR %in% c("v80691310"))%>%
  group_by(VALUE)%>%
  summarise(start_date = min(REF_DATE), 
            end_date = max(REF_DATE), 
            duration_months = as.numeric(diff(end_date - start_date + 1))/30.44)

frequency_rates

#another version
periods_rates%>%
  mutate(duration_months =as.numeric(difftime(end_date,start_date,units="days")+1)/30.44)%>%
  arrange(duration)


# duration in months 

#d. Arrange the data frame above by frequencies (bank rate repetitions)

frequency_rates%>%arrange(duration)





