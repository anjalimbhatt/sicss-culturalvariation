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

cities = read.csv("../data/iowa_cities_wiki.csv", header = F)
names(cities) = "city"

get_place_codes <- function(this.place){
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
               place  = NA,   
               place.name = NA)
     }
}

m = place.codes = purrr::map_df(cities$city, get_place_codes) %>%
  bind_rows()

CITYNAME = "Ankeny"
place.code = geo.lookup(state="IA", place = CITYNAME) %>%
  filter(!is.na(place)) %>%
  slice(1)

geo.obj = geo.make(state="IA", place = place.code$place)

acs.fetch(geography = geo.obj, endyear=2015, table.number="B01003")@estimate # population



acs.fetch(geography=geo.obj, endyear=2015, table.number="B19013")@estimate #income
acs.fetch(geography=geo.obj, endyear=2015, table.number="B02008")@estimate # race
acs.fetch(geography=geo.obj, endyear=2015, table.number="B02009")@estimate
acs.fetch(geography=geo.obj, endyear=2015, table.number="B020010")@estimate
acs.fetch(geography=geo.obj, endyear=2015, table.number="B020011")@estimate
acs.fetch(geography=geo.obj, endyear=2015, table.number="B020012")@estimate
acs.fetch(geography=geo.obj, endyear=2015, table.number="B020013")@estimate
acs.fetch(geography=geo.obj, endyear=2015, table.number="B11001")@estimate # household type
acs.fetch(geography=geo.obj, endyear=2015, table.number="B15002")@estimate # sex by education
acs.fetch(geography=geo.obj, endyear=2015, table.number="B08105A")@estimate # transportation to work
acs.fetch(geography=geo.obj, endyear=2015, table.number="B99051")@estimate # citizen status







# Get codes: https://www.socialexplorer.com/data/ACS2012/metadata/?ds=ACS12&table=B99051

# https://censusreporter.org/topics/race-hispanic/
# B01003 total populatoin
# B06004 place of birth # doesn't work
# B19013 median household income
# B01002 median age
# B02008:B020134 # race categories
# B11001 household type
# B11017: multigenerational households
# B15002 sex by education
# B08105A: means of transpirtation to work
# B99051 citizenship status
