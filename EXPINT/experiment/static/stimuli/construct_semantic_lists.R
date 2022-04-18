# Third approach here to making semantically similar lists
# We need to make x lists of words about 15-20 long where the pairwise 
# word2vec similarity is maximised. Here using a matrix of pairwise sim
# as opposed to trying to the k-means strat.
library(rjson)
library(stats)
library(lsa)

setwd("~/git/sourcemem/EXPINT/experiment/static/stimuli")

# Load in a list of words and a JSON dictionary with word2vec vectors
wordlist <- read.csv('subtlex_6_filtered.csv')
word2vec <- fromJSON(file = 'word2vec_length_6.json')

# wordlist <- read.csv('subtlex_5_filtered.csv')
# word2vec <- fromJSON(file = 'word2vec_length_5.json')

# words to exclude
profanity <- read.table('bad-words.txt')
baby.names <- tolower(read.csv('baby-names.csv')$name)
baby.names <- baby.names[!(baby.names == "river")] # I want to keep river
banned.words <- c(as.character(profanity$V1), baby.names, 'cetera', 'wampum')
wordlist <- wordlist[!(wordlist$word %in% banned.words),]
wordlist$word <- tolower(wordlist$word)


# Find unique words
words <- unique(wordlist$word)

# Build a n by n matrix of pairwise cosine similarity,
# where n is the number of words in the word list
get.paired.cosine <- function(words){
  paired.cosine <- data.frame(matrix(nrow = length(words), ncol = length(words)))
  rownames(paired.cosine) <- words
  colnames(paired.cosine) <- words
  for(i in 1:length(words)){
    for(j in 1:length(words)){
      this.pair <- cosine(word2vec[[words[i]]], word2vec[[words[j]]])
      paired.cosine[i,j] <- this.pair
    }
  }
  return(paired.cosine)
}

# Function to find a matrix containing pairwise similarity higher than threshold
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
  
  # If there are no words matching this word, then return null
  if(is.null(dim(this.subset))){
    return(NULL)
  }
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

get.all.matches <- function(threshold, all.words){
  all.matches <- list()
  for(i in words){
    # Find all words that exist in current lists
    # Unname the outer list (to avoid prefix on every name), and then get the names of inner lists
    existing.words <- names(unlist(unname(all.matches),recursive=FALSE))
    
    # If this word is already in another list, skip it
    if(i %in% existing.words){
      all.matches[[i]] <- NULL
    } else {
      this.matches <- get.matches(i, threshold, all.words)
      all.matches[[i]] <- this.matches
    }
  }
  # Want lists of at least 15 items. Many of these are duplicates,
  # and manual filtering is how I've dealt with that.
  all.matches <- all.matches[sapply(all.matches, nrow) > 15]
  return(all.matches)
}

# Format the list of lists as a 2D dataframe with columns numbering
# each of the inner lists.
format.list <- function(wordlists){
  formatted.list <- data.frame(matrix(nrow = 0, ncol = 3))
  colnames(formatted.list) <- c('word', 'list', 'list_type')
  for(i in 1:length(wordlists)){
    this.list <- wordlists[[i]]
    formatted.list <- rbind(formatted.list, cbind(rownames(this.list), i, 'semantic'))
  }
  colnames(formatted.list) <- c('word', 'list', 'list_type')
  write.csv(formatted.list, file = 'semantic_lists.csv')
  return(formatted.list)
}
