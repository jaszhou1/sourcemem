# Sort through the SWOW data and pick out suitable stimuli
setwd("~/git/sourcemem/EXPINT/experiment/stimuli")
data <- read.csv('SWOW-EN.R100.csv')
data$cue <- as.character(data$cue)
data$R1 <- as.character(data$R1)
data$R2 <- as.character(data$R2)
data$R3 <- as.character(data$R3)
five.letters <- data[nchar(data$cue) == 5,]
words <- unique(five.letters$cue)

semantic.lists <- data.frame(matrix(nrow = 0, ncol = 4))
colnames(semantic.lists) <- c('cue',  'n_resp', 'resp', 'count')

# For each five-letter cue word, find the unique responses which are also five letters long, 
# and the number of times they occur
for(i in words){
  this.word <- five.letters[five.letters$cue == i,]
  # Pull out all the unique responses across the three response columns
  this.word.responses <- as.vector(as.matrix(this.word[,c("R1", "R2", "R3")]))
  this.word.responses <- this.word.responses[nchar(this.word.responses)==5]
  # Count the number of times each 5 letter response occurs
  this.word.responses.count <- aggregate(data.frame(count = this.word.responses), 
                                         list(value = this.word.responses), length)
  # Remove cases where the response word is actually just the same word as the cue (this happens)
  this.word.responses.count <- this.word.responses.count[this.word.responses.count$value != i,]
  
  # Add the cue word as a new column (avoiding lists of lists to play nice with other languages down the line)
  this.word.responses.count <- cbind(i, nrow(this.word.responses.count),
                                     this.word.responses.count)
  colnames(this.word.responses.count) <- c('cue', 'n_resp', 'resp', 'count')
  # Sort the resulting dataframe by the count of each response
  res <- this.word.responses.count[order(this.word.responses.count$count, decreasing = TRUE),]
  semantic.lists <- rbind(semantic.lists, res)
}

# Remove cues where fewer than 20 responses were exactly five letters long
semantic.lists <- semantic.lists[semantic.lists$n_resp >= 25,]

