install.packages("googleway")

library(googleway)

APIKEY <- 'AIzaSyDu4YXjdHJQCyp_tplUfnGr1WJjpe6-Ruw'

APIKEY <-"AIzaSyAsDgVcVRRPF9A5OvJbyWkGCFrFrJ9vOb0"

df_places <- google_places(search_string = "restaurants", 
                           location = c(41.962738, -92.576752, ),   ## TamaIA
                           key = APIKEY)


m = google_place_details(place_id = df_places$results$place_id[1], key = APIKEY)

