setwd("~/Git/merging_data")

# Initially thought about dataset obtained from somewhat sketchy site
# https://www.gaslampmedia.com/download-zip-code-latitude-longitude-city-state-county-csv/
zipcodes <- read.csv("zip_codes_states.csv", header=T)

# Then decided to use wikipedia-listed cities
# https://en.wikipedia.org/wiki/List_of_cities_in_Iowa
# https://en.wikipedia.org/wiki/List_of_cities_and_towns_in_Arkansas

iowa_cities <- read.csv("iowa_cities_wiki.csv", header=F)

# get highway exit coordinates in csv
# create function that calculates shortest distance from place to exit
# look up how to get census information for addresses/coordinates