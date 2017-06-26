# stream Iowa tweets

library(rtweet)
library(tidyverse)

#https://mkearney.github.io/rtweet/articles/stream.html

appname <- "culturalvar"


twitter_token <- create_token(
  app = appname,
  consumer_key = key,
  consumer_secret = secret)

# Iowa bounding box
q = c(-96.6397171020508, 40.3755989074707, -90.1400604248047, 43.5011367797852)

filename <- "rtelect.json"

rt <- stream_tweets(q = q, timeout = 5, file_name = filename)

test = rt %>%
  mutate_all(funs(as.factor))

## stream 3 random samples of tweets
n.tweets <- 500
for (i in seq_len(n.tweets)) {
  stream_tweets(q = "", timeout = 60,
                file_name = paste0("rtw_iowa", i), parse = FALSE)
  if (i == n.tweets) {
    message("all done!")
    break
  } else {
    # wait between 0 and 300 secs before next stream
    Sys.sleep(runif(1, 0, 150))
  }
}
