library(stringr)

# the twitter of babel
## parse the samples

tw <- lapply(list.files()[-116],
             function(x) {print(x)
               as.data.frame(parse_stream(x))}) %>%
  bind_rows()

coord = tw %>%
  filter(!is.na(coordinates) | place_type == "city") %>%
  separate(place_full_name,c("town", "state"), ", ") %>%
  filter(!is.na(coordinates) | state == "AR") %>%
  filter(source != "TweetMyJOBS")

ark_coords <- c(-94.61771,33.004106,-89.644838,36.499767)


coord2 = coord %>%
  separate(coordinates, c("lat", "lon"), " ") %>%
  mutate(lon = as.numeric(lon),
         lat = as.numeric(lat)) %>% 
  mutate_geocode(place_name)

map <- get_stamenmap(ark_coords, zoom = 5, maptype = "toner-lite")
ggmap(map)

qmplot(lon.1, lat.1, 
       data = coord2, maptype = "toner-lite", color = I("red")) 
