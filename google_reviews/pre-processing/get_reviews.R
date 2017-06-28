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
  
  details = google_place_details(place_id = place_id, key = apikey)
  
  Sys.sleep(runif(1, 0, pause_length))
  
  reviews = details$result$reviews$text
  author_name = details$result$reviews$author_name
  address = details$result$formatted_address
  place.lat = details$result$geometry$location$lat
  place.lon = details$result$geometry$location$lng
  price.level = details$result$price_level
  
  no_reviews <- ifelse(details$result$reviews$text[1] == "", TRUE, FALSE)
  
  m = as.data.frame(place_id = rep(place_id, length(reviews)),
             reviews = ifelse(no_reviews, NA, reviews),
             author_name = ifelse(is.null(author_name), rep(NA, length(reviews)), rep(author_name, length(reviews))),
             address = ifelse(is.null(address), rep(NA, length(reviews)), rep(place_id, length(address))),
             place.lat = ifelse(is.null(place.lat), rep(NA, length(reviews)), rep(place.lat, length(reviews))),
             place.lon = ifelse(is.null(place.lon), rep(NA, length(reviews)), rep(place.lon, length(reviews))),
             price.level = ifelse(is.null(price.level), rep(NA, length(reviews)), rep(price.level, length(reviews))))

}

### read in all files of place ids
all_city_files <- list.files("../data/place_ids/")

### loop over cities, get reviews for each place id, and write to feather file
for (i in 1:length(all_city_files)) {
  
  city_name = unlist(str_split(all_city_files[i], "_"))[1]
  print(city_name)
  
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

place_id = "ChIJ202o56sr8IcRtIlPdgAnVqc"#pizza_ranch id
