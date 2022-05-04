# Third approach here to making semantically similar lists
# We need to make x lists of words about 15-20 long where the pairwise 
# word2vec similarity is maximised. Here using a matrix of pairwise sim
# as opposed to trying to the k-means strat.
library(rjson)
library(stats)
library(lsa)

# Get the semantic threshold from looking at DRM norms
source('~/git/sourcemem/EXPINT/experiment_stimuli/SWOW/compare_cosine.R')
threshold <- mean(DRM$list_mean)


setwd("~/git/sourcemem/EXPINT/experiment_stimuli")

# Load in a list of words and a JSON dictionary with word2vec vectors
wordlist <- read.csv('subtlex_filtered_final.csv')
word2vec <- fromJSON(txt = 'word2vec_final.json')


# wordlist <- read.csv('subtlex_5_filtered.csv')
# word2vec <- fromJSON(file = 'word2vec_length_5.json')

# words to exclude
wordlist <- wordlist[wordlist$word %in% names(word2vec), ]
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
    all.words <- all.words[!(row.names(all.words) %in% existing.words),
                               !(colnames(all.words) %in% existing.words)]
    # If this word is already in another list, skip it
    if(i %in% existing.words){
      all.matches[[i]] <- NULL
    } else {
      this.matches <- get.matches(i, threshold, all.words)
      # If there are less than 16 words in this list, then we dont want this list
      # and all the words in it should be eligible for subsequent lists
      if (length(this.matches) < 16){
        all.matches[[i]] <- NULL
      } else{
        all.matches[[i]] <- this.matches
      }
    }
  }
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
  write.csv(formatted.list, file = 'semantic_lists_final.csv')
  return(formatted.list)
}

# Top level function
construct_semantic_lists <- function(threshold){
  paired.cosine <- get.paired.cosine(words)
  all.matches <- get.all.matches(threshold, paired.cosine)
  format.list(all.matches)
}