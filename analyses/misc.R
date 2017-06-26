library(stringr)

# the twitter of babel
## parse the samples
all.files = list.files("iowa_tweets/")

tw <- lapply(as.list(list.files("iowa_tweets/")),
             parse_stream) %>%
        as.data.frame() 

list.files("iowa_tweets/")

tw %>% 
  separate(place_full_name, ", ")

coord = tw %>%
  filter(!is.na(coordinates) | place_type == "city") %>%
  separate(place_full_name,c("town", "state"), ", ") %>%
  filter(!is.na(coordinates) | state == "IA")


coord2 = tw %>%
      filter(!is.na(coordinates))

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
map <- get_stamenmap(iowa_bounding_box, zoom = 5, maptype = "toner-lite")
ggmap(map)



  