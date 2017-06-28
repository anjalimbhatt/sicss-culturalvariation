library(googleway)
library(tidyverse)
library(stringr)

RADIUS <- 1000 # in meters
PAUSE_LENGTH <- 4 # in ?
MAX_PAGES <- 2 # number of pages of results to open (20/page)

# list of cities
iowa_cities <- read.csv("../data/iowa_cities_from_city-data.csv") %>%
  separate(Name, c("city", "state"), ", ") %>%
  select(-state) %>%
  mutate(city = tolower(city))

# get lat/lon for each city
locations = lapply(iowa_cities$city[1:10], function(x) {
                     google_geocode(address = paste(x, "Iowa"), 
                     simplify = TRUE,   
                     key = APIKEY)})


locations.trim = data.frame(lat = unlist(lapply(locations, 
                                         function(x){x$results$geometry$location$lat})),
                            lon = unlist(lapply(locations, function(x){x$results$geometry$location$lng})),
                            location = iowa_cities$city[1:10])[1:10,] %>%
                        mutate_all(as.character) # this is because of mp

# get meta_data for all places at each location (city)
get_our_places <- function(lat, lon, location, radius, apikey, pause_length, max_pages){ 
      lat = as.numeric(lat)
      lon = as.numeric(lon)
 
      # first page
      page1 = list(google_places(radius = radius,
                        location = c(lat, lon),  
                        key = apikey)) 
      
      if(is.null(names(page1))) {page1= purrr::flatten(page1)}
      
      Sys.sleep(runif(1, 0, pause_length))
      
      places1 = as.data.frame(cbind(place.id = page1$results$place_id,
                                        name = unlist(page1$results$name),
                                        types =  page1$results$types)) 
      
    if(is.null(page1$next_page_token)){
     
      places1 = places1 %>%
         mutate(latitude = lat,
                longitude = lon,
                location = location)
      
        return(places1)

    } else { #second page
        page2 = google_places(radius = radius,
                              location = c(lat, lon), 
                              page_token = page1$next_page_token,
                              key = apikey)
        
        if(is.null(names(page2))) {page2 = purrr::flatten(page2)}

        
        #Sys.sleep(runif(1, 0, pause_length))
        
        places2 = as.data.frame(cbind(place.id = page2$results$place_id,
                                      name = unlist(page2$results$name),
                                      types = page2$results$types)) 
          
          places12 = bind_rows(places1, places2)
    }
      
    if(is.null(page2$next_page_token)){
      
      places12 = places12 %>%
        mutate(latitude = lat,
               longitude = lon,
               location = location)
      
        
        return(places12)
          
    } else {# third page
      page3 = google_places(radius = radius,
                            location = c(lat, lon), 
                            page_token = page2$next_page_token,
                            key = apikey)
      
      if(is.null(names(page3))) {page3 =  purrr::flatten(page3)}
      
      Sys.sleep(runif(1, 0, pause_length))
      
      places3 = as.data.frame(cbind(place.id = page3$results$place_id,
                                    name = unlist(page3$results$name),
                                    types =  page3$results$types)) %>%
                    mutate(latitude = lat,
                           latitude = lon,
                           location = location)
                  
      places123 = bind_rows(places12, places3)
      
      places123 = places123 %>%
        mutate(lat = lat,
               lon = lon,
               location = location)
      
      return(places123)
    }
}
  
# get reviews for each place at each city
places <- locations.trim %>%
              slice(1) %>%
              pmap(get_our_places, RADIUS, APIKEY, PAUSE_LENGTH, MAX_PAGES) %>%
              bind_rows()
         
places.clean = places %>%
                  mutate(name = unlist(name),
                         place.id = unlist(place.id)) %>%
                  rowwise() %>%
                  mutate(types  = paste(unlist(types), collapse=' ')) %>%
                  select(location, latitude, longitude, place.id, name, types)

# write_csv(places.clean, "place_ids.csv")

ids = read_csv("place_ids.csv")

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

places.with.reviews = ids$place.id %>%
                        map(get_our_stores, APIKEY, PAUSE_LENGTH) %>%
                        bind_rows()

write_csv(places.with.reviews, "review_data.csv")

get_our_places2 <- function(lat, lon, location, radius, apikey, pause_length){ 
  lat = as.numeric(lat)
  lon = as.numeric(lon)
  
  MAX_PAGES <- 4
  current.page = 1
  token = "first"
  
  all.places = data.frame(place.id = NA,
                          name = NA,
                          types = NA,
                          latitude = NA,
                          longitude = NA,
                          location = NA)
  
  # first page
  while(!is.null(token) & current.page < MAX_PAGES) {
    print("hi")
    page = list(google_places(radius = radius,
                              location = c(lat, lon),  
                              key = apikey)) 
    
    if(is.null(names(page))) {page = purrr::flatten(page)}
    
    Sys.sleep(runif(1, 0, pause_length))
    
    places = as.data.frame(cbind(place.id = page$results$place_id,
                                 name = unlist(page$results$name),
                                 types =  page$results$types)) 
    
    if(current.page == 1){
      all.places = places
      print(all.places)
    } else {
      all.places = bind_rows(all.places, places)
    }
    
    token = page$next_page_token 
    current.page = current.page + 1
  }
  
  all.places
  
}

                                      
