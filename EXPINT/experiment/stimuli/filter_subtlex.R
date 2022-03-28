# filter SUBTLEX
# Simple script to take the SUBTLEX corpus and filter for five letter words.
setwd("~/git/sourcemem/EXPINT/experiment/stimuli")

wordlist <- read.csv('subtlexLength.csv')
wordlist.filtered <- wordlist[(wordlist$length == 6) 
                              & (wordlist$FREQlow >= 15) 
                              & (wordlist$FREQlow <= 10000),]
wordlist.filtered$word <- tolower(wordlist.filtered$word)
# Save filtered subtlex to draw from to make stimuli lists
write.csv(wordlist.filtered, file = "subtlex_6_filtered.csv")
# Just save the word column as its own csv to pass into python to get embeddings for wordlist
write.csv(wordlist.filtered$word, file = "word2vec_length_6.csv")