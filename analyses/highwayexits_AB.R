# Highway Exits (distance to closest)
# Anjali Bhatt
# June 2017

library(stringr)
library(geosphere)
library(matrixStats)

### DO FOR BOTH IOWA AND ARKANSAS

# Import highway exit data
setwd("~/Git/merging_data/highways")
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
setwd("~/Git/merging_data/highways")
iowa_exits <- read.csv("iowaexits_coordinates.csv", header=T)
iowa_exits <- iowa_exits[,c(2,1)]
ark_exits <- read.csv("arkansasexits_coordinates.csv", header=T)
ark_exits <- ark_exits[,c(2,1)]

places <- read.csv("") ### INPUT

# Calculate the minimum distance (as the crow flies) between places and exits
dist_matrix <- round(distm(places,iowa_exits, fun=distHaversine)/1000, digits=2)
diag(dist_matrix) <- NA # remove diagonals
places$mindist <- rowMins(dist_matrix, na.rm=T) # store the minimum distance by row

# Calculate the minimum distance (as the car drives) between places and exits
diag(driv_matrix) <- NA # remove diagonals
places$mindrive <- rowMins(drive_matrix, na.rm=T)

