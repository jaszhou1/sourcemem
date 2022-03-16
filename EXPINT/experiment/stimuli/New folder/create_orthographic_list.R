# Create orthographic list (after semantic lists have alreayd been defined)
setwd("~/git/sourcemem/EXPINT/experiment/stimuli")
library(stringdist)
# Load in words that were used in semantic lists (and are therefore ineligible)
semantic <- read.csv('second_pass_word2vec.csv')

# Load in the SUBTLEX corpus
subtlex <- read.csv('subtlexLength.csv')

# Only want words with a length of 5
subtlex <- subtlex[subtlex$length == 5,]

# Get rid of super rare or super common words
subtlex <- subtlex[(subtlex$FREQlow > 1) & (subtlex$FREQlow < 10000),]

word.list <- subtlex[!(subtlex$word %in% semantic),]
word.list <- subtlex[!(subtlex$word %in% semantic[,1]),]
word.list$word <- tolower(word.list$word)

damerau <- function(word){
  # Match first letter
  this.words <- word.list[substr(word.list$word,1,1) ==  substr(word,1,1), ]
  this.words <- this.words[stringdist(this.words$word, word, method = "dl") < 3,]
  return(this.words)
}

# Find number of matches per word
for(i in 1:nrow(word.list)){
  word.list[i, 11] <- nrow(damerau(word.list[i, 'word']))
}

# Get the words where there are more than 20 possible swaps
filtered.word.list <- word.list[word.list[,11]>=20,]

# Function to assemble the list with unique orthographic "critical lures"
make.lists <- function(words){
  list <- data.frame(cue=character(), word=character(), 
                     distance=numeric(), n = integer())
  cues <- unique(filtered.word.list$word)
  
}


append_orthographic_semantic <- function(data){
  # Empty list to store pairwise orthographic similarities
  orthographic_similarities <- c()
  
  for(i in 1:nrow(data)){
    non_targets <- trials[trials!=this_trial]
    
    this_block_orthographic <- c()
    this_block_semantic <- c()
    idx <- 1
    for (j in non_targets){
      this_intruding_word <- this_block_data$word[j]
      
      # Find the levenshtein distance between the target word and intruding word
      # Since all stimuli are 4 letters, the maximum distance is 4 (swapping all letters)
      str_dist = stringdist(this_word, this_intruding_word, method = 'lv')/4
      this_block_orthographic[idx] <- str_dist
  data <- cbind(data, orthographic_similarities)
  return(data)
    }
  }
}