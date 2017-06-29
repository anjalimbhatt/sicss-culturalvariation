library(qdap)
library(stringr)
library(feather)
library(readr)
library(tm)
setwd("~/Git/merging_data/google_reviews/pre-processing")

all_city_files <- list.files("../data/place_ids/")
type_corpus <- matrix(NA, length(all_city_files), 2)
colnames(type_corpus) <- c("city","place_types")

# grab place types for each city
for (i in 1:length(all_city_files)) {
  type_corpus[i,1] <- unlist(str_split(all_city_files[i], "_"))[1]
  type_corpus[i,2] <- paste0(read_feather(paste0("../data/place_ids/", all_city_files[i]))$types, collapse = ' ')
}

# convert list of place types to corpus
source <- VectorSource(type_corpus[,2])
corpus <- VCorpus(source)
corpus <- tm_map(corpus, removeWords, c("establishment","point_of_interest"))

# analyze frequent terms
dtm <- DocumentTermMatrix(corpus)
dtm_unsparse <- removeSparseTerms(dtm, 0.20)
colnames(dtm_unsparse)
type_corpus <- as.data.frame(type_corpus)

# explore
test <- freq_terms(type_corpus[which(type_corpus$city=="Waukon"),2],
                   top=20, stopwords=c("establishment","pointofinterest"))
plot(test)
corpus[[which(type_corpus$city=="Hayesville")]][1]
