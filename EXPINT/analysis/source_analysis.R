## Load dependencies
library(circular)
library(stringdist)
library(rjson)
library(lsa)
library(psycho)
library(ggplot2)
library(grid)
library(plyr)

# Load in word2vec semantic vectors
word2vec <- fromJSON(file = '~/git/sourcemem/EXPINT/experiment_stimuli/word2vec_final.json')

# Function to compute angular difference
cosine_distance <- function(theta, phi){
  distance <- 1 - cos(theta - phi)
  return(distance)
}

angle_diff <- function(a,b){
  diff <- atan2(sin(a-b), cos(a-b))
  return(diff)
}

## Looking at data prior to modelling
data <- read.csv("~/git/sourcemem/EXPINT/data/EXPINT_data.csv")

# Exclude data from practice blocks
data <- data[data$block != -1,]

# Rename conditions (want capital letters)
data$condition <- revalue(data$condition, c("unrelated" = "Unrelated", "orthographic" = "Orthographic", "semantic" = "Semantic"))

# Define some things to iterate through
participants <- unique(data$participant)
conds <- unique(data$condition)

# Flip the semantic similarity so it is expressed as a distance like others
data[,51:57] <- 1-data[,51:57]

# Plot the source error distributions for the three word list conditions
# Functions necessary for the recongition analyses for EXPINT.

plot.source.cond <- function(data){
  plot <- ggplot(data = data, aes(x = source_error, y = ..density..)) +
    geom_histogram(bins = 50) +
    facet_wrap(~condition) +
    scale_y_continuous(name="Density") +
    scale_x_continuous(name = "Source Error", breaks = c(-pi, 0, pi), labels=c(expression(-pi), "0", expression(pi))) +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(), axis.line = element_line(colour = "black"),
          text = element_text(size = 16),
          strip.background=element_rect(fill="white"))
  return(plot)
}

# Fit the Zhang and Luck (2008) two-component mixture model to estimate the difference in peak and tail
# Separately for each condition
