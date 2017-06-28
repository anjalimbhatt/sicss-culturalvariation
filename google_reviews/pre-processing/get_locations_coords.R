### GET LOCATION COORDINATES FOR EACH CITY ####
# reads in list of towns, gets lat, lon
####################################

# libraries
library(googleway)
library(tidyverse)
library(stringr)
library(feather)

# params
PAUSE_LENGTH <- 5 
API <-  "AIzaSyCnLIvzHx8w2M-OSK8QQQtF2mlUct5ldGk"


# list of cities
iowa_cities <- read.csv("../data/iowa_cities_wiki.csv", header = F) %>%
  rename(names = V1) %>%
  filter(names != "Des Moines")

### query google for lat/lon for each city
lapply(iowa_cities$names, function(city.name) {
  
  Sys.sleep(runif(1, 0, PAUSE_LENGTH))
  
  print(city.name)
  
  location.info = google_geocode(address = paste(x, "Iowa"), 
                                 simplify = TRUE,   
                                 key = APIKEY)
  
  # munge location df
  locations.trim = data.frame(lat = location.info$results$geometry$location$lat,
                              lon = location.info$results$geometry$location$lng,
                              location = city.name) %>%
    mutate_all(as.character) 
  
  write_feather(locations.trim, paste0("../data/locations/", city.name))
})


### read in all location files and bind
all.locations <- lapply(list.files("../data/locations/"), 
                        function(x) {print(x) 
                          read_feather(paste0("../data/locations/", x))}) %>%
                    bind_rows()

### write location df to csv
write_csv(all.locations, "../data/locations/all_locations.csv")

