## Load dependencies
library(circular)
library(stringdist)
library(rjson)
library(lsa)
library(psycho)

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
data <- read.csv("~/git/sourcemem/EXPINT/data/EXPINT_data2.csv")

# Exclude data from practice blocks
data <- data[data$block != -1,]

# Define some things to iterate through
participants <- unique(data$participant)
conds <- unique(data$condition)

# Flip the semantic similarity so it is expressed as a distance like others
data[,51:57] <- 1-data[,51:57]

## Hit Rates and False Alarms for each participant
recog <- data.frame(participant = integer(),
                    condition = character(),
                    hits = numeric(),
                    misses = numeric(),
                    false.alarms = numeric(),
                    correct.rejections = numeric(),
                    dprime = numeric(),
                    beta = numeric())
idx <- 1
for(i in participants){
  this.p.data <- data[data$participant == i, ]
  for(j in conds){
    this.cond.data <- this.p.data[this.p.data$condition == j, ]
    this.cond.stim <- this.cond.data[this.cond.data$is_stimulus,]
    this.cond.foil <- this.cond.data[!this.cond.data$is_stimulus,]
    # Calculate hits and misses
    this.hits <- nrow(this.cond.stim[this.cond.stim$recognised,])/nrow(this.cond.stim)
    this.misses <- 1-this.hits
    # False alarms and correct rejections
    this.fa <- nrow(this.cond.foil[this.cond.foil$recognised,])/nrow(this.cond.foil)
    this.reject <- 1-this.fa
    # Index for the bigger dataframe
    recog[idx, 'participant'] <- i
    recog[idx, 'condition'] <- j
    recog[idx, 'hits'] <- this.hits
    recog[idx, 'misses'] <- this.misses
    recog[idx, 'false.alarms'] <- this.fa
    recog[idx, 'correct.rejections'] <- this.reject
    
    # Tacking on some SDT measurements
    SDT <- dprime(nrow(this.cond.stim[this.cond.stim$recognised,]),  nrow(this.cond.foil[this.cond.foil$recognised,]), 
           nrow(this.cond.stim[!this.cond.stim$recognised,]),  nrow(this.cond.foil[!this.cond.foil$recognised,]))
    recog[idx, "dprime"] <- SDT$dprime
    recog[idx, "beta"] <- SDT$beta
    idx <- idx + 1
  }
}

#Plot d prime across conditions
recog$condition <- factor(recog$condition, levels = c("unrelated", "semantic", "orthographic"), ordered = T)
recog$participant <- as.factor(recog$participant)
recog_plot <- ggplot(recog, aes(x=condition,  y = dprime, group = participant, color = participant)) + 
  geom_line(lwd = 1.5, alpha = 0.4) + geom_point(size = 3) +
  geom_text(data = subset(recog, condition == "orthographic"), aes(label = participant, colour = participant, x = Inf, y = dprime), hjust = -.1)

gt <- ggplotGrob(recog_plot)
gt$layout$clip[gt$layout$name == "panel"] <- "off"
grid.draw(gt)


# Rayleigh test of uniformity
rayleigh <- data.frame(participant = integer(),
                       stat = numeric(),
                      sig = numeric())
for(i in participants){
  this.p.data <- data[data$participant == i, ]
  this.rayleigh <- rayleigh.test(this.p.data$source_error)
  rayleigh[i, 'participant'] <- i
  rayleigh[i, 'stat'] <- this.rayleigh$statistic
  rayleigh[i, 'sig'] <- this.rayleigh$p.value
}

# Recentering on Time, Space, Semantics, Orthography
recenter.data <- function(data){
  data <- na.omit(data)
  n_intrusions <- 7
  recentered_errors <- data.frame(matrix(ncol=10,nrow=nrow(data)*n_intrusions, 
                                         dimnames=list(NULL, c('participant', 'cond',
                                                               'intruding_angle', 'offset', 
                                                               'lag', 'spatial', 
                                                               'orthographic', 'semantic',
                                                               'spatial_bin', 'semantic_bin'))))
  idx <- 1
  for (i in 1:nrow(data)){
    this_trial <- data[i,]$present_trial
    this_response_angle <- data[i,]$response_angle
    this_target_angle <- data[i,]$target_angle
    this_intrusions <- data[i,16:22]
    temporal <- data[i,30:36]
    spatial <- data[i,37:43]
    orthographic <- data[i,44:50]
    semantic <- data[i,51:57]
    for(j in 1:n_intrusions){
      recentered_errors[idx,1] <- data[i, 'participant']
      recentered_errors[idx,2] <- data[i, 'condition']
      recentered_errors[idx,3] <- this_intrusions[[j]]
      recentered_errors[idx,4] <- angle_diff(this_response_angle, this_intrusions[[j]])
      recentered_errors[idx,5] <- temporal[[j]]
      recentered_errors[idx,6] <- spatial[[j]] ##Note the "1-", for all others small number
                                                  # means more similar, while its reverse for
                                                  # semantic, which is a cosine similarity
      recentered_errors[idx,7] <- orthographic[[j]]
      recentered_errors[idx,8] <- semantic[[j]]
      idx <- idx + 1
    }
  }
  # Discretise the spatial and semantic columns for some rough plots
  n_bins <- 5
  sem_bins <- quantile(recentered_errors$semantic, seq(0, 1, length =n_bins), na.rm = TRUE)
  spatial_bins <- quantile(recentered_errors$spatial, seq(0, 1, length = n_bins), na.rm = TRUE)
  for(i in 1:(n_bins-1)){
    recentered_errors[(recentered_errors$spatial >= spatial_bins[[i]]&
                         recentered_errors$spatial <= spatial_bins[[i+1]]),
                      'spatial_bin'] <- i
    recentered_errors[(recentered_errors$semantic >= sem_bins[[i]]&
                         recentered_errors$semantic <= sem_bins[[i+1]]),
                      'semantic_bin'] <- i
  }
  return(recentered_errors)
}

# recenter each condition
recenter.condition <- function(data, cond){
  this_data <- data[data$cond == cond, ]
  orth <- ggplot(this_data) + geom_histogram(aes(x = offset, y = ..density..), bins = 30) + 
    ylim(0, 0.5) + 
    facet_grid(~orthographic) +
    ggtitle(sprintf('%s Condition, Recentered on orthographic', cond))
  ggsave(sprintf('recenter_orthographic_cond_%s.png', cond), plot = orth, width = 20, height = 15, units = "cm")
  
  sem <- ggplot(this_data) + geom_histogram(aes(x = offset, y = ..density..), bins = 30) + 
    ylim(0, 0.5) + 
    facet_grid(~semantic_bin) +
    ggtitle(sprintf('%s Condition, Recentered on semantic (quantile)', cond))
  ggsave(sprintf('recenter_semantic_cond_%s.png', cond), plot = sem, width = 20, height = 15, units = "cm")
  
  spatial <- ggplot(this_data) + geom_histogram(aes(x = offset, y = ..density..), bins = 30) + facet_grid(~spatial_bin) +
    ggtitle(sprintf('%s Condition, Recentered on spatial (quantile)', cond))
  ggsave(sprintf('recenter_spatial_cond_%s.png', cond), plot = spatial, width = 20, height = 15, units = "cm")
}
