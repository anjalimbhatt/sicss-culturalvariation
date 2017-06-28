### GET REVIEWS FOR EACH PLACE IN EACH CITY ####
# metadata: lat, lon, place_ids of stores
# reads in list of towns, gets lat, lon, then queries google for meta-data
###################################


# libraries
library(googleway)
library(tidyverse)
library(stringr)
library(feather)

# params
RADIUS <- 5000 # in meters
PAUSE_LENGTH <- 150 # 
MAX_PAGES <- 200 # number of pages of results to open (20/page)
APIKEY <-  "AIzaSyDNI7GK1VPH2fTLhpibFPd7DswTq4HulA0"


get_our_stores <- function(place_id, apikey, pause_length){
  
  details = google_place_details(place_id = place_id, key = apikey)
  
  Sys.sleep(runif(1, 0, pause_length))
  
  reviews = details$result$reviews$text
  address = details$result$formatted_address
  place.lat = details$result$geometry$location$lat
  place.lon = details$result$geometry$location$lng
  price.level = details$result$price_level
  
  data.frame(place_id = place_id,
             reviews = ifelse(is.null(reviews), NA, reviews),
             address = ifelse(is.null(address), NA, address),
             place.lat = ifelse(is.null(place.lat), NA, place.lat),
             place.lon = ifelse(is.null(place.lon), NA, place.lon),
             price.level = ifelse(is.null(price.level), NA, price.level))

}

### read in all files of place ids
all_city_files <- list.files()

### loop over cities, get reviews for each place id, and write to feather file
for (i in length(all_city_files)) {
  
  print( all_city_files[i])
  
  # get all place ids for this city
  ids = read_feather(paste0("../data/reviews/", all_city_files[i]))

  # get reviews for all place ids
  places.with.reviews = ids$place.id %>%
    map(get_our_stores, APIKEY, PAUSE_LENGTH) %>%
    bind_rows()
  
  # write to reviews to feather
  write_feather(places.with.reviews , 
                paste0("../data/reviews/", place_id, "_reviews"))
}
