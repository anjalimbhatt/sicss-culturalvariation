# Cultural Variation by Geography
# June 2017
# Pull Arkansas Tweets

library(rtweet)
library(tidyverse)

# ## Do this to save twitter token for further use
# twitter_token <- create_token(
#   app = appname,
#   consumer_key = key,
#   consumer_secret = secret)
# 
# ## path of home directory
# home_directory <- path.expand("~/")
# 
# ## combine with name for token
# file_name <- file.path(home_directory, "twitter_token.rds")
# 
# ## save token to home directory
# saveRDS(twitter_token, file = file_name)
# 
# cat(paste0("TWITTER_PAT=", file_name),
#     file = file.path(home_directory, ".Renviron"),
#     append = TRUE)
# 
# ## IMPORTANT: RESTART R/RSTUDIO

twitter_token <- get_tokens()


stream_tweets(q = "", timeout = 30, parse = TRUE, token = NULL,
              file_name = NULL, gzip = FALSE, verbose = TRUE, fix.encoding = TRUE,
              ...)