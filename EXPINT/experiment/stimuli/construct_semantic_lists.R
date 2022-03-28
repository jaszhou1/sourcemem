# Third approach here to making semantically similar lists
# We need to make x lists of words about 15-20 long where the pairwise 
# word2vec similarity is maximised. Here using a matrix of pairwise sim
# as opposed to trying to the k-means strat.
library(rjson)
library(stats)
library(lsa)

setwd("~/git/sourcemem/EXPINT/experiment/stimuli")

# Load in a list of words and a JSON dictionary with word2vec vectors
wordlist <- read.csv('subtlex_6_filtered.csv')
# words to exclude
profanity <- read.table('bad-words.txt')
baby.names <- tolower(read.csv('baby-names.csv')$name)
baby.names <- baby.names[!(baby.names == "river")] # I want to keep river
banned.words <- c(baby.names, profanity)
wordlist <- wordlist[!(wordlist$word %in% banned.words),]
wordlist$word <- tolower(wordlist$word)

word2vec <- fromJSON(file = 'word2vec_length_6.json')


# Find unique words
words <- unique(wordlist$word)

# Build a n by n matrix of pairwise cosine similarity,
# where n is the number of words in the word list
paired.cosine <- data.frame(matrix(nrow = length(words), ncol = length(words)))
rownames(paired.cosine) <- words
colnames(paired.cosine) <- words
for(i in 1:length(words)){
  for(j in 1:length(words)){
    this.pair <- cosine(word2vec[[words[i]]], word2vec[[words[j]]])
    paired.cosine[i,j] <- this.pair
  }
}

get.matches <- function(word, threshold, all.words){
  # Subset the main dataframe with a starting word
  this.word <- as.list(all.words[word,])
  
  # Get the words that match a minimum threshold of similarity with the seed
  this.word <- this.word[this.word > threshold]
  
  # Order these words by ascending similarity to the starting word
  this.word.ascending <- this.word[order(unlist(this.word), decreasing = FALSE)]
  
  # Subset the main dataframe so only these words are included
  this.subset <- all.words[row.names(all.words) %in% names(this.word),
                           colnames(all.words) %in% names(this.word)]
  # For each word, starting with the weakest match to the starting one,
  # remove it from all rows and columns if there is a weak match (<threshold)
  for(i in names(this.word.ascending)){
    if (any(this.subset[i,]<threshold)){
      this.subset <- this.subset[!(row.names(this.subset) %in% i),
                                 !(colnames(this.subset) %in% i)]
    }
  }
  return(this.subset)
}