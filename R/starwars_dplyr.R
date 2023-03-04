library(dplyr)
head(starwars,4)
# It happened to be 6 observation of species with grey skin color  
#birth-year is NA which is not a number has numeric value 
# I keep it this way, otherwise there will be no observation for sampling
# I can also check !is.nan(birth_year) to filter out NA values

#Q2 a
sample_percent<-50

data("starwars")

table1<-starwars%>%filter(grepl('grey',skin_color, fixed = TRUE))%>%
  select(name ,species,homeworld, hair_color ,birth_year ,skin_color)%>%
  arrange(desc(homeworld))%>%
  filter(is.numeric(birth_year))%>%
  sample_n(nrow(.)*sample_percent/100)
table1


#Q2 b
#1. The average height and average mass of Starwars characters
df_b1<-starwars %>% summarise(height_avg = mean(height, na.rm = TRUE), mass_avg=mean(mass,na.rm=TRUE))%>%
  as.data.frame()
df_b1

#2. List the names (only) for characters whose birth_year > 100

df_b2<-starwars %>% filter(birth_year>100)%>%select(name)%>%
  as.data.frame()
df_b2

#3. List of (unique) films, along with the number of characters appearing in each film

# Get a unique list of films
films <- unique(unlist(starwars$films))
films

#Count the number of characters in each film
df_b3 <- data.frame( n = sapply(films, function(x) sum(grepl(x,starwars$films, fixed = TRUE))))
df_b3
