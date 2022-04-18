# filter SUBTLEX
# Simple script to take the SUBTLEX corpus and filter for five letter words.
setwd("~/git/sourcemem/EXPINT/experiment/static/stimuli")

wordlist <- read.csv('subtlexLength.csv')

profanity <- read.table('bad-words.txt')
baby.names <- tolower(read.csv('baby-names.csv')$name)
banned.words <- c(as.character(profanity$V1), baby.names, 'cetera', 'wampum',
                  'autism', 'gayest', 'leadin', 'nomine', 'muumuu', 'mizzen',
                  'senhor', 'blende', 'chicky', 'kibitz')

wordlist.filtered <- wordlist[!(wordlist$word %in% banned.words),]
wordlist.filtered$word <- tolower(wordlist.filtered$word)

wordlist.filtered2 <- wordlist.filtered[(wordlist.filtered$length == 6) 
                              & (wordlist.filtered$FREQlow >= 10) 
                              & (wordlist.filtered$FREQlow <= 1000),]

# Save filtered subtlex to draw from to make stimuli lists
write.csv(wordlist.filtered2, file = "subtlex_filtered_final.csv")
# Just save the word column as its own csv to pass into python to get embeddings for wordlist
write.csv(wordlist.filtered2$word, file = "word2vec_length_final.csv")