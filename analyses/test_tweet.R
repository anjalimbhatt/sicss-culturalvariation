library(rtweet)
library(tidyverse)

https://mkearney.github.io/rtweet/articles/stream.html

appname <- "culturalvar"
key <- "5JyPHxeXEOoheoyW7c2lJ1zxT"
secret <-"549Tfshtx200b3SGSx5Pb2yEmUV1nk5tBvuXG8WcZswACfbRZU"

twitter_token <- create_token(
  app = appname,
  consumer_key = key,
  consumer_secret = secret)

q <- paste0("hillaryclinton,imwithher,realdonaldtrump,maga,electionday")
filename <- "rtelect.json"
rt <- stream_tweets(q = q, timeout = 60, file_name = filename)


test = rt %>%
  mutate_all(funs(as.factor))
