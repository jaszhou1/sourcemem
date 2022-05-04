setwd("~/git/sourcemem/EXPINT/experiment_stimuli/SWOW")
library(jsonlite)
library(lsa)

# small world of words
SWOW <- read.csv('filtered_SWOW3.csv')

# Specifically get rid of these unwanted cue words
unwanted.words <- c('white')
SWOW <- SWOW[!(SWOW$cue %in% unwanted.words),]

# Tested DRM norms
DRM <- read.csv('DRM_words.csv')
DRM <- DRM[DRM$number<3,]

colnames(SWOW) <- c('cue', 'n_resp', 'word', 'count')
colnames(DRM) <- c('cue', 'word', 'number')

# Load in word2vec semantic vectors
word2vec <- fromJSON(txt = 'word2vec_filtered.json')

for(i in 1:nrow(DRM)){
  cos <- cosine(word2vec[[DRM$cue[i]]], word2vec[[DRM$word[i]]])
  DRM$cos[i] <- cos
}

for(i in 1:nrow(SWOW)){
  cos <- cosine(word2vec[[SWOW$cue[i]]], word2vec[[SWOW$word[i]]])
  SWOW$cos[i] <- cos
}

# Find the mean similarity for each list

for(i in unique(DRM$cue)){
  this.list.mean <- mean(DRM[DRM$cue == i,]$cos)
  DRM[DRM$cue == i,'list_mean'] <- this.list.mean
}

# From the SWOW list, remove any pairs where the semantic similarity is less than 2 sd below the mean 
# of the DRM list

SWOW <- SWOW[SWOW$cos > mean(DRM$cos) - 2*sd(DRM$cos),]

# Count the number of words in each SWOW list after weak pairs are removed, also calculate the mean 
for(i in unique(SWOW$cue)){
  this.list.mean <- mean(SWOW[SWOW$cue == i,]$cos)
  SWOW[SWOW$cue == i,6] <- this.list.mean
  SWOW[SWOW$cue ==i ,2] <- nrow(SWOW[SWOW$cue ==i,])
}

# Remove lists where the number of responses are now less than 20
SWOW <- SWOW[SWOW$n_resp >= 20,]

# Where a response is duplicated for several cues, remove it from all lists except the strongest match
for(i in unique(SWOW$word)){
  this.word <- SWOW[SWOW$word == i,]
  # Defining strongest match by the highest number of responses in the SWOW task
  to.remove <- rownames(this.word[this.word$n_resp < max(this.word$n_resp),])
  SWOW <- SWOW[!(row.names(SWOW) %in% to.remove),]
}


# Count the number of words in each SWOW list after weak pairs are removed, also calculate the mean 
for(i in unique(SWOW$cue)){
  this.list.mean <- mean(SWOW[SWOW$cue == i,]$cos)
  SWOW[SWOW$cue == i,6] <- this.list.mean
  SWOW[SWOW$cue ==i ,2] <- nrow(SWOW[SWOW$cue ==i,])
}

# Again, remove lists where the number of responses are now less than 20
SWOW <- SWOW[SWOW$n_resp >= 20,]

# Remove responses which are also critical lures
SWOW <- SWOW[!(SWOW$word %in% unique(SWOW$cue)),]

#write.csv(SWOW, file = 'automatic_SWOW.csv')
