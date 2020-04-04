# Angel Henriquez
# Influenza vs. COVID-19 dataset
# New York has the most cases of the coronavirus.
# This dataset may be used to compare the most recent influenza and coronavirus deaths in New York.

# The COVID-19 data can be found here: 
# https://www.kaggle.com/fireballbyedimyrnmom/us-counties-covid-19-dataset/data

# The influenza data can be found here:
# https://healthdata.gov/dataset/influenza-laboratory-confirmed-cases-county-beginning-2009-10-season/resource/eda1fec6-2da6#{view-graph:{graphOptions:{hooks:{processOffset:{},bindEvents:{}}}},graphOptions:{hooks:{processOffset:{},bindEvents:{}}}}

rm(list = ls())

#library
library(dplyr)
library(tidyr)

#covid 19 data
covid_19_dataset <- read.csv("~/RProjects/covid19_influenza_data/us-counties.csv")
#Isolate most recent cases
covid_19_dataset <- covid_19_dataset[c(2:6)]

#Create new data frame with max
covid_19_agg_cases <- aggregate(cases ~ county, covid_19_dataset, max)
covid_19_agg_deaths<- aggregate(deaths ~ county, covid_19_dataset, max)
covid_19_agg <- merge(covid_19_agg_cases, covid_19_agg_deaths, by = c("county"))
covid_19_dataset <- covid_19_dataset[c(1:3)]
covid_19_dataset <- distinct(covid_19_dataset)
#Merge with original
covid_19_dataset <- merge(covid_19_dataset, covid_19_agg, by = "county")
covid_19_dataset$county <- tolower(covid_19_dataset$county)

names(covid_19_dataset)[4] <- "covid_19_cases"
names(covid_19_dataset)[5] <- "covid_19_deaths"

rm('covid_19_agg')
rm('covid_19_agg_cases')
rm('covid_19_agg_deaths')

#influenza data
influenza_dataset <- read.csv("~/RProjects/covid19_influenza_data/Influenza_Laboratory-Confirmed_Cases_By_County__Beginning_2009-10_Season.csv")
#Isolate most recent years
influenza_dataset$Season <- gsub("[-]", "", influenza_dataset$Season)
influenza_dataset$Season <- as.numeric(influenza_dataset$Season)
influenza_dataset$Season <- influenza_dataset$Season %% 10000
influenza_dataset <- subset(influenza_dataset, Season == 2020)
influenza_dataset_count <- subset(influenza_dataset[c(3,7)])

influenza_dataset_count <- influenza_dataset_count %>% 
  group_by(County) %>% 
  summarise(cases = sum(Count))

influenza_dataset <- influenza_dataset[c(3,9)]
influenza_dataset <- merge(influenza_dataset_count, influenza_dataset, by = c("County"))
rm('influenza_dataset_count')
influenza_dataset <- influenza_dataset[c(1,3,2)]
influenza_dataset$County <- tolower(influenza_dataset$County)
names(influenza_dataset)[3] <- "influenza_cases"

covid19_and_influenza_2019_dataset <- merge(covid_19_dataset, influenza_dataset, 
                                            by.x = c("county","fips"), 
                                            by.y = c("County", "FIPS"))

rm('covid_19_dataset')
rm('influenza_dataset')
#Only New York Dataset
covid19_and_influenza_2019_dataset <- distinct(covid19_and_influenza_2019_dataset)

#text file
write.table(covid19_and_influenza_2019_dataset, "~/RProjects/covid19_influenza_data/covid19_and_influenza_2019_dataset.txt", sep="\t")
#CSV file
write.table(covid19_and_influenza_2019_dataset, "~/RProjects/covid19_influenza_data/covid19_and_influenza_2019_dataset.csv", sep="\t")
