# Highway Exits (distance to closest)
# Anjali Bhatt
# June 2017

library(stringr)
library(geosphere)
library(matrixStats)
library(gmapsdistance)
library(ggmap)
library(dplyr)

### DO FOR BOTH IOWA AND ARKANSAS

# Import highway exit data
setwd("./highways")
raw <- readLines("iowa_highwayexits.txt")

# Create table of lat/lon coordinates of highway exits
lines <- grep('\"lat\"|\"lon\"',raw,value=TRUE)
lines <- str_extract_all(lines, "\\-?[0-9]*\\.\\-?[0-9]*", simplify = TRUE)
lines <- matrix(as.numeric(unlist(lines)),nrow=nrow(lines))
exits <- data.frame(matrix(lines,ncol=2,byrow=TRUE))
names(exits) = c('latitude','longitude')

# Write out as csv
write.csv(exits,"iowaexits_coordinates.csv", row.names=F)


### CALCULATE SHORTEST DISTANCE
# Using Haversine distance as recommended by http://www.cs.nyu.edu/visual/home/proj/tiger/gisfaq.html

### TEST WHICH DIST FUNCTION TO USE
# Vincenty ellipsoid corrects for larger distances (not as much of a concern)
# but is computational more intensive (definitely a concern)
# df.cities <- data.frame(name = c("New York City", "Chicago", "Pittsburgh", "Atlanta", "Philly"),
#   lon  = c(-73.99420, -87.63940, -79.995888, -84.39360, -75.165222),
#   lat  = c(40.75170,  41.87440, 40.440624,  33.75280, 39.952583)
# )
# round(distm(df.cities[,2:3], fun=distVincentyEllipsoid)/1000)
# round(distm(df.cities[,2:3], fun=distHaversine)/1000)


# Need to reorder to lon, lat format
setwd("~/Git/sicss-culturalvariation/highways")
iowa_exits <- read.csv("iowaexits_coordinates.csv", header=T)
iowa_exits <- iowa_exits[,c(2,1)]
ark_exits <- read.csv("arkansasexits_coordinates.csv", header=T)
ark_exits <- ark_exits[,c(2,1)]

setwd("~/Git/sicss-culturalvariation/google_reviews/data/locations/")
all_locations <- read.csv("all_locations.csv")
places <- all_locations[,c(2,1)] # reordering to lon,lat format
row.names(places) <- all_locations$location

# Calculate the minimum distance (as the crow flies) between places and exits
dist_matrix <- round(distm(places,iowa_exits, fun=distHaversine)/1000, digits=2)
diag(dist_matrix) <- NA # remove diagonals
places$mindist <- rowMins(dist_matrix, na.rm=T) # store the minimum distance by row
for (i in 1:nrow(dist_matrix)) {
  places$minexit[i] <- which.min(dist_matrix[i,]) # store the exit with minimum distance by row
}
summary(places$mindist) # check to see if reasonable

# Calculate the minimum distance (as the car drives) between places and exits
places <- places %>% mutate(latlon=paste0(lat,",",lon))
iowa_exits <- iowa_exits %>% mutate(latlon=paste0(latitude,",",longitude))
drive_matrix <- gmapsdistance(places$latlon, iowa_exits$latlon,
      combinations="all", key="AIzaSyDK2fihNCbG_7ziW3TMjCHD9NZL-lW7dXk",
      mode="driving", shape="long")
diag(driv_matrix) <- NA # remove diagonals
all_locations$mindrive <- rowMins(drive_matrix, na.rm=T)

# Too many calls to gmaps API, so instead doing driving distance to exit with min crow's distance
places <- places %>% mutate(exitcoords=paste0(iowa_exits$latitude[minexit],",",iowa_exits$longitude[minexit]))
drive_1 <- gmapsdistance(places$latlon[1:300], places$exitcoords[1:300], combinations="pairwise", mode="driving")
drive_2 <- gmapsdistance(places$latlon[301:600], places$exitcoords[301:600], combinations="pairwise", mode="driving")
drive_3 <- gmapsdistance(places$latlon[601:946], places$exitcoords[601:946], combinations="pairwise", mode="driving")

places$mindrive <- NA
places$mindrive[1:300] <- drive_1$Distance[,c("Distance")]/1000
places$mindrive[301:600] <- drive_2$Distance[,c("Distance")]/1000
places$mindrive[601:946] <- drive_3$Distance[,c("Distance")]/1000

cor(places$mindist, places$mindrive) # 0.93 correlation

### Plot cities & exits

# Iowa bounding box
iowa_bounding_box = c(-96.6397171020508, 40.3755989074707, # southwest coordinates
                      -90.1400604248047, 43.5011367797852) # northeast coordinates

# Change to include exits outside of state
bounds <- c(min(iowa_exits$longitude-.05), min(iowa_exits$latitude-.05),
            max(iowa_exits$longitude)+.05, max(iowa_exits$latitude+.05))

# Create map with exits and cities
setwd("~/Git/merging_data/Presentation")
map <- get_map(bounds, zoom = 7, maptype = "roadmap", source="google")
png(filename="Iowa_distance.png", units="in", width=6, height=6, pointsize=16, res=256)
  ggmap(map) +
    geom_point(aes(x = longitude, y = latitude), data = iowa_exits, alpha = .5, color = "black") +
    geom_point(aes(x=lon, y=lat, color=mindist), data=places, alpha=.5) +
    theme_bw()
dev.off()

# Color cities by distance from exit

