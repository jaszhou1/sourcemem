# Check the word frequency of constructed lists

setwd("~/git/sourcemem/EXPINT/experiment_stimuli")

wordlist <- read.csv('subtlexLength.csv')
wordlist$word <- tolower(wordlist$word)
semantic <- read.csv('semantic_lists_final.csv', fileEncoding="UTF-8-BOM")
orthographic <- read.csv('orthographic_lists_final.csv', fileEncoding="UTF-8-BOM")

for(i in 1:nrow(semantic)){
  this.list.length <- nrow(semantic[semantic$list == semantic$list[i],])
  semantic$list_length[i] <- this.list.length
  semantic$frequency[i] <- wordlist[wordlist$word == as.character(semantic$word[[i]]), 'FREQlow']
}

write.csv(semantic, file = 'semantic_list.csv')

for(i in 1:nrow(orthographic)){
  this.list.length <- nrow(orthographic[orthographic$list == orthographic$list[i],])
  orthographic$list_length[i] <- this.list.length
  orthographic$frequency[i] <- wordlist[wordlist$word == as.character(orthographic$word[[i]]), 'FREQlow']
}

write.csv(orthographic, file = 'orthographic_list.csv')

words <- rbind(semantic,orthographic)
hist(words$frequency)