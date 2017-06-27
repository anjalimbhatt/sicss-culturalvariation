library(googleway)
library(tidyverse)
library(stringr)
library(tidyjson)
library(rjson)

APIKEY <-"AIzaSyAsDgVcVRRPF9A5OvJbyWkGCFrFrJ9vOb0"
APIKEY <- "AIzaSyAVDQbuDljyFtq_E29UINC1tRx5tW41GA8"
APIKEY <- "AIzaSyAhoy81HgmCz_VzZ6M4wpWknRrQB65hdyc"
APIKEY <- "AIzaSyDCPbsoTlouUl3ry2vzzsbggXm_QWpK_Og"
APIKEY <- "AIzaSyBfbPE1XlfeAdJMosW_LBXQ2ifnVu-Y6Ic"


RADIUS <- 5000


# list of cities
iowa_cities <- read.csv("../data/iowa_cities_from_city-data.csv") %>%
  separate(Name, c("city", "state"), ", ") %>%
  select(-state) %>%
  mutate(city = tolower(city))

# get lat/lon for each city
locations = lapply(iowa_cities$city[1:3], function(x) {
                     google_geocode(address = paste(x, "Iowa"), 
                     simplify = TRUE,   
                     key = APIKEY)})

locations.trim = data.frame(lat = unlist(lapply(locations, 
                                         function(x){x$results$geometry$location$lat})),
                            lon = unlist(lapply(locations, function(x){x$results$geometry$location$lng})),
                            location = iowa_cities$city[1:3])[1:3,]

# get meta_data for all places at each location (city)
get_our_places <- function(lat, lon, location, radius, apikey, pause_length){ 
 
      # first page
      page1 = list(google_places(radius = radius,
                        location = c(lat, lon),  
                        key = apikey)) 
      
      if(is.null(names(page1))) {page1= purrr::flatten(page1)}
      
      Sys.sleep(runif(1, 0, pause_length))
      
      places1 = as.data.frame(cbind(place.id = page1$results$place_id,
                                        names = unlist(page1$results$name),
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
                                      names = unlist(page2$results$name),
                                      types = page2$results$types)) 
          
          places12 = bind_rows(places1, places2)
          print(places12)
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
                                    names = unlist(page3$results$name),
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
              slice(1:3) %>%
              pmap(get_our_places, radius, apikey, pause_length) %>%
              bind_rows()

# just fix location name


places.with.reviews = places %>%
  mutate( google_place_details(place_id = place[], key = APIKEY))



  

