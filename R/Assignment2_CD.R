library(dplyr)
library(tidyverse)
library(lubridate)
library(readr)
library(tibble)

# Seasonally adjusted monthly labour force characteristics by province from
# Statistics Canada for 25 to 54 years old people in January 2023 and Jan 2022.
# Data type = Seasonally adjusted
# REF_DATE in (2022-01,2023-01)
#Age group = 25 to 54 years



dir<- file.path(getwd(), "R", "Assignment")
setwd(dir)
getwd()
rm(dir)

colSelect<-c("REF_DATE",
             "GEO",
             "Labour.force.characteristics",
             "Sex",
             "Age.group",
             "Statistics",
             "Data.type",
             "UOM",
             "SCALAR_FACTOR",
             "SCALAR_ID",
             "VECTOR",
             "VALUE",
             "COORDINATE",
             "STATUS")

colTypes<-cols(REF_DATE = col_date(format = "%Y-%m"))


rawData = read_csv("Employmentdata.csv", col_select=colSelect, col_types = colTypes, name_repair = "universal")
rm(colSelect,colTypes)


glimpse(rawData)

# df<- rawData%>%filter(GEO=="Canada" & REF_DATE == as.Date("2023-01-01") 
#                       & Labour.force.characteristics == "Population"
#                       & Sex == "Both sexes" &
#                       Age.group == "25 to 54 years")%>%
#   select(REF_DATE,VALUE,Labour.force.characteristics,Statistics)

#View(df)

emplDf <- rawData%>%
  filter(REF_DATE %in% c(as.Date('2022-01-01'),('2023-01-01')) &
           Age.group == "25 to 54 years" &
           Data.type == "Seasonally adjusted")


View(emplDf)
#Check what dates we have 
emplDf%>%select(REF_DATE)%>%distinct() 



#a Growth of population, Full-time employment, Part-time employment and
# Unemployment rates between Jan 2022 and Jan 2023 in Ontario, Alberta, BC and overall
#Canada
emplDf%>%select(UOM,SCALAR_FACTOR)%>%distinct()

# numbers of people are in thousands
# I select only persons, not percent

empPivotedDf<-emplDf%>%filter(Sex=="Both sexes" &
                Statistics=="Estimate" &
                UOM == "Persons")%>%
  select(REF_DATE,GEO,VALUE,Labour.force.characteristics)%>%
  pivot_wider(names_from = Labour.force.characteristics, values_from = c(VALUE), names_repair ="universal")
  
View(empPivotedDf)  
glimpse(empPivotedDf) #52 rows = 4 GEO location * 13 dates works

#Growth of population, Full-time employment, Part-time employment and
# Unemployment rates

# empPivotedDf%>%select(REF_DATE,GEO,Population)%>%
#    group_by(GEO)%>%
#    mutate(population_before = lag(Population),
#           population_delta = c(NA,diff(Population)),
#           population_growth =c(NA,diff(Population))/lag(Population))%>%
#    arrange(ifelse(GEO == "Canada", 0, 1),GEO)
# 


#function growth accepts a vector with population number and return vector with growth 
#(same number of dimensions, first is NA)
growth<-function(people){
  round(c(NA,diff(people))*100/lag(people),2)
}

# The unemployment rate is calculated as: (Unemployed ÷ Labor Force) x 100


empCubeA <- empPivotedDf%>%
  filter(GEO %in% c("Ontario", "Alberta", "British Columbia","Canada"))%>%
  group_by(GEO)%>%
  mutate(Growth_of_population = growth(Population),
         Previous_period_population = lag(Population),
         Unemployment_rate = round(Unemployment*100/Labour.force,2),
         Unemployment_rate_diff = c(NA,diff(Unemployment_rate)),
         Growth_Part_time_employment = growth(Part.time.employment),
         Growth_Full_time_employment = growth(Full.time.employment)
         )%>%
  select(REF_DATE,
         GEO,
         Population,
         Growth_of_population,
         Growth_Part_time_employment,
         Growth_Full_time_employment,
         Unemployment_rate,
         Unemployment_rate_diff)%>%
  filter(!is.na(Growth_of_population))%>%
  arrange(ifelse(GEO == "Canada", 0, 1),GEO)

View(empCubeA)
empCubeA

#b. Part-time employment rate (expressed as a percentage of the labor force) of each
#province, in descending Part-time employment rate order Jan, 2023

#rate = part_of_population/Total Labout Force

empCubeB <- empPivotedDf%>%
  filter(REF_DATE==max(REF_DATE))%>%
  group_by(GEO)%>%
  mutate(Part_time_employment_rate = round(Part.time.employment*100/Labour.force,2))%>%
  select(REF_DATE,
         GEO,
         Population,
         Part_time_employment_rate)%>%
  arrange(desc(Part_time_employment_rate) )

View(empCubeB)


#c. Generate a data frame to analyse the (un)employment rate in each province. What can
#you conclude (based on this data) in regard to provincial employment opportunities? Jan, 2023

empCubeC <- empPivotedDf%>%
  filter(REF_DATE==max(REF_DATE))%>%
  group_by(GEO)%>%
  mutate(Unemployment_rate = round(Unemployment*100/Labour.force,2))%>%
  select(REF_DATE,
         GEO,
         Population,
         Unemployment,
         Unemployment_rate)%>%
  arrange(ifelse(GEO == "Canada", 0, 1),Unemployment_rate)

View(empCubeC)







