library(rjson)
library(lsa)

# small world of words
SWOW <- read.csv('automatic_SWOW.csv')

# Tested DRM norms
DRM <- read.csv('DRM_words.csv')

colnames(SWOW) <- c('cue', 'word', 'count')
colnames(DRM) <- c('cue', 'word')

# Load in word2vec semantic vectors
word2vec <- fromJSON(file = 'word2vec_second_pass.json')


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
  DRM[DRM$cue == i,4] <- this.list.mean
}

# Count the number of words in each SWOW list after weak pairs are removed, also calculate the mean 
for(i in unique(SWOW$cue)){
  this.list.mean <- mean(SWOW[SWOW$cue == i,]$cos)
  SWOW[SWOW$cue ==i ,5] <- nrow(SWOW[SWOW$cue ==i,])
  SWOW[SWOW$cue == i, 6] <- this.list.mean
}

colnames(SWOW) <- c('cue', 'word', 'count', 'cos', 'n', 'mean_cos')
colnames(DRM) <- c('cue', 'word', 'cos', 'mean_cos')
write.csv(SWOW, file = 'semantic_lists.csv')