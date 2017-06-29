library(qdap)
setwd("~/Git/merging_data/google_reviews/pre-processing")

all_city_files <- list.files("../data/place_ids/")
type_corpus <- matrix(NA, length(all_city_files), 2)
col.names(type_corpus) <- c("city","place_types")

### loop over cities, get reviews for each place id, and write to feather file
for (i in 1:length(all_city_files)) {
  type_corpus[i,1] <- unlist(str_split(all_city_files[i], "_"))[1]
  type_corpus[i,2] <- paste0(read_feather(paste0("../data/place_ids/", all_city_files[i]))$types, collapse = ' ')
}

test <- freq_terms(type_corpus[1,2], 20)
plot(test)
type_corpus[1,2]

