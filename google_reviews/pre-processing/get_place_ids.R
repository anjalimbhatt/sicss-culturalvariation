### GET PLACE IDs FOR EACH CITY ####
# reads in list of cities with lat lon and then queries google for all place_ids
####################################

# libraries
library(googleway)
library(tidyverse)
library(stringr)
library(feather)

# params
RADIUS <- 5000 # in meters
PAUSE_LENGTH <- 5 # 
MAX_PAGES <- 200 # number of pages of results to open (20/page)
APIKEY <- "AIzaSyDQtvvYVcPDGlNnZ7iAqKUnpCSokspaxak"

### read in list of cities with lat lon coordinates
all_locations <- read_csv("../data/locations/all_locations.csv")[88:473,] # you do [474:946,]

### function that queries google for place_ids
get_our_places <- function(lat, lon, location, radius, apikey, pause_length, max_pages){ 
  print(location)
  lat = as.numeric(lat)
  lon = as.numeric(lon)
  
  current.page = 1
  token = "first"
  
  
  all.places = data.frame(place.id = NA,
                            name = NA,
                            types = NA,
                            latitude = NA,
                            longitude = NA,
                            location = NA)
  
  # loop until reach max pages or token is null
  while(!is.null(token) & current.page < (MAX_PAGES + 1)) {
    
    print(current.page)
    if (token == "first") {
      page = list(google_places(radius = radius,
                                location = c(lat, lon), 
                                key = apikey)) 
    } else {
      page = list(google_places(radius = radius,
                                location = c(lat, lon),  
                                page_token = token,
                                key = apikey)) 
    }
    
    if(is.null(names(page))) {page = purrr::flatten(page)}

    Sys.sleep(runif(1, 0, pause_length))
    
    places = as.data.frame(cbind(place.id = page$results$place_id,
                                 name = unlist(page$results$name),
                                 types =  page$results$types)) 
    if(current.page == 1){
      all.places = places
    } else {
      all.places = bind_rows(all.places, places)
    }
    token = page$next_page_token 
    current.page = current.page + 1
  }
  
  # clean dataset
  places.clean = all.places %>%
    rowwise() %>%
    mutate(name = unlist(name),
           place.id = unlist(place.id)) %>%
    mutate(types  = paste(unlist(types), collapse=' '),
           location = location,
           lat = lat,
           lon = lon) %>%
    select(location, lat, lon, place.id, name, types)
  
  # write to feather
  write_feather(places.clean , 
                paste0("../data/place_ids/", location, "_place_ids"))
}

### loop over locations
pmap(all_locations, get_our_places, RADIUS, APIKEY, PAUSE_LENGTH, MAX_PAGES)