# There are some individual differences in the effect of the similarity manipulation
# Error in orthographic cond > unrelated consistently, but
# for some semantics > unrelated, semantics < unrelated
# quantify this by calculating the absolute mean error across the three conditions
# for each participant, (maybe w a pairwise significance test), group into
# super participants for plotting.

# Load data
data <- read.csv("~/git/sourcemem/EXPINT/data/EXPINT_data.csv")

# Exclude data from practice blocks
data <- data[data$block != -1,]

# Get rid of foil data, and data with invalid RT
data <- data[(data$valid_RT) & (data$is_stimulus),]
data <- data[data$recog_rating %in% c(0,8,9),]

# turn response error to absolute
data$source_error <- abs(data$source_error)

conds <- c('unrelated', 'semantic', 'orthographic')
participants <- unique(data$participant)

res <- matrix(nrow = 0, ncol = 7)
for(i in participants){
  this.data <- data[data$participant == i,]
  this.unrelated <- this.data[this.data$condition == conds[1], 'source_error']
  this.semantic <- this.data[this.data$condition == conds[2], 'source_error']
  this.orthographic <- this.data[this.data$condition == conds[3], 'source_error']
  
  semantic <- t.test(this.unrelated, this.semantic)
  orthographic <- t.test(this.unrelated, this.orthographic)
  
  this.p.means <- c(semantic$estimate[[1]], semantic$estimate[[2]], 
                    orthographic$estimate[[2]], semantic$statistic, semantic$p.value,
                    orthographic$statistic, orthographic$p.value)
  res <- rbind(res, this.p.means)
}
row.names(res) <- 1:10
colnames(res) <- c('unrelated', 'semantic', 'orthographic', 't.sem', 'p.sem', 't.orth', 'p.orth')


