setwd("~/git/sourcemem/EXPINT/experiment_stimuli")
orthographic <- read.csv('orthographic_lists_final_v2.csv')
semantic <- read.csv('semantic_lists_final_v2.csv')
used.words <- rbind(orthographic, semantic)

# Load in a list of words and a JSON dictionary with word2vec vectors
wordlist <- read.csv('subtlex_filtered_final.csv')

used.wordlist <- wordlist[tolower(wordlist$word) %in% used.words$word,]