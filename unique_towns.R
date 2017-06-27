setwd("~/Git/sicss-culturalvariation")
zipcodes <- read.csv("zip_codes_states.csv", header=T)
iowa_zips <- zipcodes[zipcodes$state=="IA",]
iowa_towns <- as.matrix(unique(iowa_zips$city))
write.csv(iowa_towns, "iowa_towns.csv", row.names=F)
arkansas_zips <- zipcodes[zipcodes$state=="AR",]
arkansas_towns <- as.matrix(unique(arkansas_zips$city))
write.csv(arkansas_towns, "arkansas_towns.csv", row.names=F)

