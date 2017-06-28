# Highway Exits (distance to closest)
# Anjali Bhatt
# June 2017

library(stringr)

### DO FOR BOTH IOWA AND ARKANSAS

# Import highway exit data
setwd("~/Git/merging_data/analyses")
raw <- readLines("iowa_highwayexits.txt")

# Create table of lat/lon coordinates of highway exits
lines <- grep('lat|lon',raw,value=TRUE)
lines <- str_extract_all(lines, "\\-?[0-9]*\\.\\-?[0-9]*", simplify = TRUE)
lines <- matrix(as.numeric(unlist(lines)),nrow=nrow(lines))
exits <- data.frame(matrix(lines,ncol=2,byrow=TRUE))
names(exits) = c('latitude','longitude')

# Write out as csv
setwd("~/Git/merging_data/highways")
write.csv(exits,"iowaexits_coordinates.csv", row.names=F)