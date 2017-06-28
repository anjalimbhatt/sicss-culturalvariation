### GET REVIEWS FOR EACH PLACE IN EACH CITY ####
# reads in list of place_ids for each town then queries google for meta-data
###################################

# libraries
library(googleway)
library(tidyverse)
library(stringr)
library(feather)

# params
PAUSE_LENGTH <- 5 # 
MAX_PAGES <- 200 # number of pages of results to open (20/page)
APIKEY <-  "AIzaSyB3YM0L-nAnDRwvsFrQJBeRulQFPi5AT0A"

get_our_stores <- function(place_id, apikey, pause_length){
  print(place_id)
  details = google_place_details(place_id = place_id, key = apikey)
  
  Sys.sleep(runif(1, 0, pause_length))
  
  all.reviews = details$result$reviews$text
  author.names = details$result$reviews$author_name
  address = details$result$formatted_address
  place.lat = details$result$geometry$location$lat
  place.lon = details$result$geometry$location$lng
  price.level = details$result$price_level
  
  no.reviews <- ifelse(is.null(all.reviews), TRUE, FALSE)

  df = data.frame(place.id = place_id,
                 reviews = ifelse(no.reviews, NA, list(all.reviews)),
                 author.names = ifelse(no.reviews, NA, list(author.names)),
                 address = ifelse(is.null(address), NA, address),
                 place.lat = ifelse(is.null(place.lat), NA, place.lat),
                 place.lon = ifelse(is.null(place.lon), NA, place.lon),
                 price.level = ifelse(is.null(price.level), NA, price.level))
  names(df)[2:3] = c("reviews", "author.names") # ugh this shouldn't be necessary
  df
}

### read in all files of place ids
all_city_files <- list.files("../data/place_ids/")

### loop over cities, get reviews for each place id, and write to feather file
for (i in 1:length(all_city_files)) {
  
  # get city name
  city_name = unlist(str_split(all_city_files[i], "_"))[1]
  print(paste0("########## ", city_name, " ##########"))
  
  # get all place ids for this city
  ids = read_feather(paste0("../data/place_ids/", all_city_files[i]))

  # get reviews for all place ids
  places_with_reviews = ids$place.id %>%
    map(get_our_stores, APIKEY, PAUSE_LENGTH) %>%
    bind_rows()
  
  # write to reviews to feather
  write_feather(places_with_reviews, 
                paste0("../data/reviews/", city_name, "_reviews"))
}
