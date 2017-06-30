### GET CENSUS DATA FOR EACH CITY ####
# metadata: lat, lon, place_ids of stores
# reads in list of towns, gets lat, lon, then queries google for meta-data
###################################


# libraries
library(acs)
library(tidyverse)
library(stringr)
library(feather)
library(purrr)

api.key.install(key="b9c63b79fd54c3a6b55952ce08d86a708ce926b5")
# Get codes: https://www.socialexplorer.com/data/ACS2012/metadata/?ds=ACS12&table=B99051
# https://censusreporter.org/topics/race-hispanic/

# cities <- read.csv("./google_reviews/data/iowa_cities_wiki.csv", header = F)
# names(cities) = "city"


# get place codes to query acs api
#get_place_codes <- function(this.place){
#     df = geo.lookup(state = "IA", place = as.character(this.place)) 
#      
#      if (length(df) > 3){   
#        df %>%
#           filter(!is.na(place))%>%
#           mutate(our.place.name = this.place) %>%
#           slice(1) 
#   
#      } else {
#        data.frame(state = NA,
#                state.name = NA,
#                county.name = NA,
#                place = NA,   
#                place.name = NA)
#      }
# }

#place.codes =  purrr::map_df(cities$city, get_place_codes) %>%
##  bind_rows()
#write_csv(place.codes, "../data/place_codes.csv")
place_codes = read_csv("place_codes.csv")


# Function to get census data
get_census_data <- function (x) {
  geo.obj <- geo.make(state = "IA", place = x)
  
  population <- acs.fetch(
    geography = geo.obj, 
    endyear=2015, 
    table.number="B01003")@estimate
  
  income <- acs.fetch(
    geography=geo.obj, 
    endyear=2015, 
    table.number="B19013")@estimate
  
  race <- acs.fetch(
    geography = geo.obj, 
    endyear=2015, 
    table.number="B02008")@estimate
  
  hispanic <- acs.fetch(
    geography = geo.obj, 
    endyear=2015, 
    variable="B03003_003")@estimate
  
  print(x)
  result <- c(income,population,race,hispanic)
}

## loop over cities
census_data <- data.frame(city=place_codes$our.place.name, medianincome=NA,
                          pop=NA, popwhite=NA, pophisp=NA)
for (i in 1:nrow(place_codes)) {
  census_data[i,2:5] <- get_census_data(place_codes$place[i])
}

# Write to csv
# Make sure to remove Des Moines later
write_csv(census_data, "census_data.csv", col_names=T)

