library(rtweet)
library(tidyverse)

https://mkearney.github.io/rtweet/articles/stream.html

appname <- "culturalvar"

twitter_token <- create_token(
  app = appname,
  consumer_key = key,
  consumer_secret = secret)

q <- paste0("hillaryclinton,imwithher,realdonaldtrump,maga,electionday")
filename <- "rtelect.json"
rt <- stream_tweets(q = q, timeout = 60, file_name = filename)


test = rt %>%
  mutate_all(funs(as.factor))
