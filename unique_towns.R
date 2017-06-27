setwd("~/Git/merging_data")

# Initially thought about dataset obtained from somewhat sketchy site
# https://www.gaslampmedia.com/download-zip-code-latitude-longitude-city-state-county-csv/
zipcodes <- read.csv("zip_codes_states.csv", header=T)

# Then decided to use wikipedia-listed cities
iowa_cities <- read.csv("iowa_cities_wiki.csv", header=F)
