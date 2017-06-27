# stream Iowa tweets

library(rtweet)
library(tidyverse)

#https://mkearney.github.io/rtweet/articles/stream.html

twitter_token <- get_tokens()

# Iowa bounding box
iowa_bounding_box = c(-96.6397171020508, 40.3755989074707, -90.1400604248047, 43.5011367797852)


## stream 3 random samples of tweets
n.tweets <- 500
for (i in seq_len(n.tweets)) {
  stream_tweets(q = iowa_bounding_box, timeout = 60,
                file_name = paste0("iowa_tweets/rtw_iowa", i), parse = FALSE)
  if (i == n.tweets) {
    message("all done!")
    break
  } else {
    # wait between 0 and 300 secs before next stream
    Sys.sleep(runif(1, 0, 150))
  }
}
