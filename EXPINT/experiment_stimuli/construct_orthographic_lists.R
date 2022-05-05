library(stringdist)
setwd("~/git/sourcemem/EXPINT/experiment_stimuli")
# Load in semantic lists, exclude those words, construct orthographic
# from the leftovers

semantic.lists <- read.csv('semantic_list_filtered_v4.csv')

# Load in a list of words and a JSON dictionary with word2vec vectors
wordlist <- read.csv('subtlex_filtered_final.csv')

# exclude words that exist in semantic lists
wordlist$word <- tolower(wordlist$word)
wordlist <- wordlist[!(wordlist$word %in% semantic.lists$word),]

# Find unique words
words <- unique(wordlist$word)

# Build a n by n matrix of pairwise dama,
# where n is the number of words in the word list
get.paired.dist <- function(words){
  paired.dist <- data.frame(matrix(nrow = length(words), ncol = length(words)))
  rownames(paired.dist) <- words
  colnames(paired.dist) <- words
  for(i in 1:length(words)){
    for(j in 1:length(words)){
      # If the first letter doesn't match, assign an arbitrarily large value
      if(substr(words[i], 1, 1) != substr(words[j], 1, 1)){
        paired.dist[i,j] <- 99 
      } else {
        this.dist <- stringdist(words[i], words[j], method = "dl")
        paired.dist[i,j] <- this.dist 
      }
    }
  }
  return(paired.dist)
}

get.matches <- function(word, threshold, all.words){
  # Subset the main dataframe with a starting word
  this.word <- as.list(all.words[word,])
  
  # Get the words that are at most "threshold" distance away from target
  this.word <- this.word[this.word <= threshold]
  
  # Order these words by ascending distance to the starting word
  if(!(is.vector(unlist(this.word)))){
    browser()
  }
  this.word.ascending <- this.word[order(unlist(this.word), decreasing = TRUE)]
  
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
    if (any(this.subset[i,]>threshold)){
      this.subset <- this.subset[!(row.names(this.subset) %in% i),
                                 !(colnames(this.subset) %in% i)]
    }
  }
  return(this.subset)
}

get.all.matches <- function(threshold, all.words){
  all.matches <- list()
  for(i in names(all.words)){
    # Find all words that exist in current lists
    # Unname the outer list (to avoid prefix on every name), and then get the names of inner lists
    existing.words <- names(unlist(unname(all.matches),recursive=FALSE))
    
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
    formatted.list <- rbind(formatted.list, cbind(rownames(this.list), i, 'orthographic'))
  }
  colnames(formatted.list) <- c('word', 'list', 'list_type')
  write.csv(formatted.list, file = 'orthographic_lists_final.csv')
  return(formatted.list)
}

# Top level function
construct_orthographic_lists <- function(threshold){
  paired.dist <- get.paired.dist(words)
  all.matches <- get.all.matches(threshold, paired.dist)
  format.list(all.matches)
}
