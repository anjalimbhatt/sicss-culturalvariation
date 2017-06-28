library(stringr)

tw <- lapply(list.files(), 
             function(x) {print(x) 
               as.data.frame(parse_stream(x))}) %>%
        bind_rows()

coord = tw %>%
  filter(!is.na(coordinates) | place_type == "city") %>%
  separate(place_full_name, c("town", "state"), ", ") %>%
  filter(!is.na(coordinates) | state == "IA") %>%
  filter(source != "TweetMyJOBS")



###################
########

gt = read.delim("GeoText.2010-10-12/full_text.txt", sep ="\t", header = F)

gt.clean = gt %>%
  select(-V2, -V3)

names(gt.clean) = c("userid", "latitude", "longitude", "tweet")

d.iowa  = gt.clean %>%
  filter(longitude > -96.6397171020508 & longitude < -90.1400604248047) %>%
  filter(latitude > 40.3755989074707 & latitude < 43.5011367797852)

  
length(unique(d.iowa$userid))

length(unique(gt.clean$userid))
# Iowa bounding box
iowa_bounding_box = c(-96.6397171020508, 40.3755989074707, # southwest coordinates
                      -90.1400604248047, 43.5011367797852) # northeast coordinates

#######
coord2 = coord %>%
  separate(coordinates, c("lat", "lon"), " ") %>%
  mutate(lon = as.numeric(lon),
         lat = as.numeric(lat)) %>%
  mutate_geocode(value.place_name)

map <- get_stamenmap(iowa_bounding_box, zoom = 5, maptype = "toner-lite")
ggmap(map)
qmplot(lon, lat, 
       data = coord2, maptype = "toner-lite", color = I("red")) 

ggmap(map) +
  geom_point(aes(x = lon, y = lat), data = coord2, alpha = .5, color = "red") +
  theme_bw()
