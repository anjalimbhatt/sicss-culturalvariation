get_our_places <- function(lat, lon, location, radius, apikey, pause_length){ 
  lat = as.numeric(lat)
  lon = as.numeric(lon)
  
  MAX_PAGES <- 3
  current.page = 1
  token = "first"
  
  all.places = data.frame(place.id = NA,
                          name = NA,
                          types = NA,
                          latitude = NA,
                          longitude = NA,
                          location = NA)
  
  # first page
  while(!is.null(token) & current.page < (MAX_PAGES + 1)) {
        #print("hi")
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
        
        print(current.page)
        
}
  
    all.places
  
}


