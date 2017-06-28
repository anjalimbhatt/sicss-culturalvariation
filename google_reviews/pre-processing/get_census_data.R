### GET CENSUS DATA FOR EACH CITY ####
# metadata: lat, lon, place_ids of stores
# reads in list of towns, gets lat, lon, then queries google for meta-data
###################################


# libraries
library(acs)
library(tidyverse)
library(stringr)
library(feather)

#api.key.install(key="b9c63b79fd54c3a6b55952ce08d86a708ce926b5")
# Get codes: https://www.socialexplorer.com/data/ACS2012/metadata/?ds=ACS12&table=B99051
# https://censusreporter.org/topics/race-hispanic/

#cities = read.csv("../data/iowa_cities_wiki.csv", header = F)
#names(cities) = "city"


# get place codes to query acs api
#get_place_codes <- function(this.place){
    df = geo.lookup(state = "IA", place = as.character(this.place)) 
     
     if (length(df) > 3){   
       df %>%
          filter(!is.na(place))%>%
          mutate(our.place.name = this.place) %>%
          slice(1) 
  
     } else {
       data.frame(state = NA,
               state.name = NA,
               county.name = NA,
               place = NA,   
               place.name = NA)
     }
}

#place.codes =  purrr::map_df(cities$city, get_place_codes) %>%
##  bind_rows()
#write_csv(place.codes, "../data/place_codes.csv")
#place_codes = read_csv("../data/place_codes.csv")


# get censuse data
get_census_data <- function (x){
  
  print(x)
  
  geo.obj <- geo.make(state = "IA", place = x)
  
  population <- rownames_to_column(as.data.frame(acs.fetch(geography = geo.obj, 
                                                           endyear=2015, 
                                                           table.number="B01003")@estimate))
  population_df = ifelse(!exists("population_df"), population,
                         bind_rows(population, population_df))    
  
  income <- rownames_to_column(as.data.frame(acs.fetch(geography=geo.obj, 
                                                       endyear=2015, 
                                                       table.number="B19013")@estimate))
  income_df = ifelse(!exists("income_df"), income, 
                     bind_rows(income, income_df))
  
  race_08 <- rownames_to_column(as.data.frame(acs.fetch(geography = geo.obj, 
                                                        endyear=2015, 
                                                        table.number="B02008")@estimate))
  race_08_df = ifelse(!exists("race_08_df"), race_08, 
                      bind_rows(race_08, race_08_df))
  
  race_09 <- rownames_to_column(as.data.frame(acs.fetch(geography = geo.obj, 
                                                        endyear=2015, 
                                                        table.number="B02009")@estimate))
  race_09_df = ifelse(!exists("race_09_df"), race_09, 
                      bind_rows(race_09, race_09_df))
  
  race_10 <- rownames_to_column(as.data.frame(acs.fetch(geography = geo.obj, 
                                                        endyear=2015, 
                                                        table.number="B020010")@estimate))
  race_10_df = ifelse(!exists("race_10_df"), race_10, 
                      bind_rows(race_10, race_10_df))
  
  race_11 <- rownames_to_column(as.data.frame(acs.fetch(geography = geo.obj, 
                                                        endyear=2015, 
                                                        table.number="B020011")@estimate))
  race_11_df = ifelse(!exists("race_11_df"), race_11, 
                      bind_rows(race_11, race_11_df))
  
  race_12 <- rownames_to_column(as.data.frame(acs.fetch(geography = geo.obj, 
                                                        endyear=2015, 
                                                        table.number="B020012")@estimate))
  race_12_df = ifelse(!exists("race_12_df"), race_12, 
                      bind_rows(race_12, race_12_df))
  
  race_13 <- rownames_to_column(as.data.frame(acs.fetch(geography = geo.obj, 
                                                        endyear=2015, 
                                                        table.number="B020013")@estimate))
  race_13_df = ifelse(!exists("race_13_df"), race_13, 
                      bind_rows(race_13, race_13_df))
  
  household <- rownames_to_column(as.data.frame(acs.fetch(geography = geo.obj, 
                                                          endyear=2015, 
                                                          table.number="B11001")@estimate))
  household = ifelse(!exists("household_df"), household, 
                     bind_rows(household, household_df))
  
  sex_ed <- rownames_to_column(as.data.frame(acs.fetch(geography = geo.obj, 
                                                       endyear=2015, 
                                                       table.number="B15002")@estimate))
  sex_ed = ifelse(!exists("sex_ed_df"), sex_ed, 
                  bind_rows(sex_ed, sex_ed_df))
  
  transp_work <- rownames_to_column(as.data.frame(acs.fetch(geography = geo.obj, 
                                                            endyear=2015, 
                                                            table.number="B08105A")@estimate))
  transp_work = ifelse(!exists("transp_work_df"), transp_work, 
                       bind_rows(transp_work, transp_work_df))
  
  citizen <- rownames_to_column(as.data.frame(acs.fetch(geography = geo.obj, 
                                                        endyear=2015, 
                                                        table.number="B99051")@estimate))
  citizen = ifelse(!exists("citizen_df"), citizen, 
                   bind_rows(citizen, citizen_df))
  
}

## loop over places
map(place_codes$place, get_census_data)













m = read_feather( "../data/reviews/Ackley_reviews")

m$place_id = as.factor(m$place_id)
