# Cultural Variation by Geography
# June 2017
# Pull Arkansas Tweets

setwd("~/Git/sicss-culturalvariation")
library(rtweet)

## Do this to save twitter token for further use
twitter_token <- create_token(
  app = appname,
  consumer_key = key,
  consumer_secret = secret)

## path of home directory
home_directory <- path.expand("~/")

## combine with name for token
file_name <- file.path(home_directory, "twitter_token.rds")

## save token to home directory
saveRDS(twitter_token, file = file_name)

cat(paste0("TWITTER_PAT=", file_name),
    file = file.path(home_directory, ".Renviron"),
    append = TRUE)

## IMPORTANT: RESTART R/RSTUDIO



# Load twitter token
twitter_token <- get_tokens()

# Set geographic bounds
# Need SW and NE corners of bounding box
# CSV format from http://boundingbox.klokantech.com/
# Then revised as Twitter's bounding box for Arkansas
ark_coords <- c(-94.61771,33.004106,-89.644838,36.499767)

# Stream tweets into file
filename <- "arkansastweets"
arkansas_tweets <- stream_tweets(q = ark_coords, timeout = 10, file_name = filename)

n.tweets <- 500
for (i in seq_len(n.tweets)) {
  stream_tweets(q = ark_coords, timeout = 60,
                file_name = paste0(filename, i), parse = FALSE)
  if (i == n.tweets) {
    message("all done!")
    break
  } else {
    # wait between 0 and 150 secs before next stream
    Sys.sleep(runif(1, 0, 150))
  }
}

# parse the samples
tw <- lapply(c("rtw1.json", "rtw2.json", "rtw3.json"),
             parse_stream)

# collapse lists into single data frame
tw.users <- do.call("rbind", users_data(tw))
tw <- do.call("rbind", tw)
attr(tw, "users") <- tw.users

### Read coordinates of interstate highway exits
### Pulled from http://overpass-turbo.eu/


