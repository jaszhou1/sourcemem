## Load dependencies
library(boot)
library(ggplot2)

## Looking at data prior to modelling
data <- read.csv("~/git/sourcemem/EXPINT/data/EXPINT_data.csv")

# Exclude data from practice blocks
data <- data[data$block != -1,]
# Get rid of foil data, and data with invalid RT
data <- data[(data$valid_RT) & (data$is_stimulus),]

data$present_trial <- data$present_trial + 1

# Get rid of foil data, and data with invalid RT
data <- data[(data$valid_RT) & (data$is_stimulus),]
data <- data[data$recog_rating %in% c(0,8,9),]

# recentered_data <- recenter.data(data)
# save(recentered_data, file = "~/git/sourcemem/EXPINT/data/recentered_data.RData")
load("~/git/sourcemem/EXPINT/data/recentered_data.RData")

# Load Model Predictions
load("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/fitted_models/2023-03-16_fits.RData")
# Load simulated datasets
load("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/fitted_models/2023-03-16_sim_data.RData")
load("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/fitted_models/2023-03-16_simulated_recenter.RData")


# Define some things to iterate through
participants <- unique(data$participant)
conds <- unique(data$condition)

# Function to subset the data to one serial position, get the avg (median) error for this pos.
get.this.pos.error <- function(data, indices){
  data <- data[indices,]
  data$source_error <- abs(data$source_error)
  this_error <- mean(data$source_error)
  return(this_error)
}

get.this.pos.RT <- function(data, indices){
  data <- data[indices,]
  data$source_RT <- abs(data$source_RT)
  this_RT <- mean(data$source_RT)
  return(this_RT)
}

# Get the median error across serial positions for this condition
get.this.cond.error <- function(data, cond){
  this_cond <- data.frame(matrix(nrow = 8, ncol = 5))
  this_data <- data[data$condition == cond,]
  for(i in unique(data$present_trial)){
    this_pos_data <- this_data[this_data$present_trial == i,]
    this_error <- get.this.pos.error(this_pos_data, 1:nrow(this_pos_data))
    this_RT <- get.this.pos.RT(this_pos_data, 1:nrow(this_pos_data))
    # Bootstrap sample for Confidence Interval
    boot_error <- boot(data = this_pos_data, statistic = get.this.pos.error, R = 500)
    this_error_ci <- boot.ci(boot_error, conf = c(0.95), type = c("norm"))
    boot_RT <- boot(data = this_pos_data, statistic = get.this.pos.RT, R = 500)
    this_RT_ci <- boot.ci(boot_RT, conf = c(0.95), type = c("norm"))
    this_cond[i,1] <- i
    this_cond[i,2] <- cond
    this_cond[i,3] <- this_error
    this_cond[i,4] <- this_error_ci$normal[2]
    this_cond[i,5] <- this_error_ci$normal[3]
    this_cond[i,6] <- this_RT
    this_cond[i,7] <- this_RT_ci$normal[2]
    this_cond[i,8] <- this_RT_ci$normal[3]
  }
  return(this_cond)
}

# Wrapper, serial position across error, for group
get.all.cond.error <- function(data){
  res <- data.frame()
  for(i in unique(data$cond)){
    this_cond_error <- get.this.cond.error(data, i)
    res <- rbind(res, this_cond_error)
  }
  colnames(res) <- c('Position', 'Condition', 'Error', 'ci_lower', 'ci_upper',
                     'RT', 'RT_ci_lower', 'RT_ci_upper')
  return(res)
}

# Wrapper, serial position across error, for participant level
get.individual.cond.error <- function(data){
  res <- data.frame()
  for(k in unique(data$participant)){
    for(i in unique(data$cond)){
      this_cond_error <- get.this.cond.error(data[data$participant == k,], i)
      this_cond_error <- cbind(this_cond_error, k)
      res <- rbind(res, this_cond_error)
    }
  }
  colnames(res) <- c('Position', 'Condition', 'Error', 'ci_lower', 'ci_upper',
                     'RT', 'RT_ci_lower', 'RT_ci_upper', 'participant')
  return(res)
}

# Group, median error across serial position
plot.serial.error <- function(serial_error){
  plot <- ggplot(data = serial_error) +
    # Median Error in dots and lines
    geom_point(aes(x = Position, y = Error, colour = Condition)) +
    geom_line(aes(x = Position, y = Error, colour = Condition)) +
    # Line segment for 95% confidence interval at each point
    geom_errorbar(aes(x = Position, ymin = ci_lower, ymax = ci_upper, colour = Condition), alpha = 0.3, width = 0.1) +
    ggtitle('Median Error across Serial Position') +
    scale_x_continuous(breaks = 1:8) +
    theme(text = element_text(size = 16))
  # Can facet to make each condition clearer
  #facet_wrap(~Condition, nrow = 3, scales = 'free')
  return(plot)
}

# Individual, median error across serial position
indiv_serial <- get.individual.cond.error(data)
plot.indiv.serial.error <- function(indiv_serial){
  plot <- ggplot(data = indiv_serial) +
    # Error in dots and lines
    geom_point(aes(x = Position, y = Error, colour = Condition)) +
    geom_line(aes(x = Position, y = Error, colour = Condition)) +
    # Line segment for 95% confidence interval at each point
    geom_errorbar(aes(x = Position, ymin = ci_lower, ymax = ci_upper, colour = Condition), alpha = 0.3, width = 0.1) +
    ggtitle('Error across Serial Position') +
    scale_x_continuous(breaks = 1:8) +
    theme(text = element_text(size = 16)) +
    facet_wrap(~participant, nrow = 5, scales = 'free')
  return(plot)
}

plot.indiv.serial.error(indiv_serial)

plot.histograms.position <- function(data){
  plot <- ggplot(data = data) +
    geom_density(aes(x = source_error, colour = condition), adjust = 1.5) +
    ggtitle('Error Distribution across Serial Position') +
    facet_wrap(~present_trial, ncol = 4) +
    xlab("Serial Position") + ylab("Mean Error") +
    theme(text = element_text(size=20),
          strip.background = element_blank(),
          plot.title = element_text(face = "bold", size = 12),
          legend.position = "none",
          axis.ticks = element_line(colour = "grey70", size = 0.2),
          axis.line.x = element_line(color="black", size = 0.2),
          axis.line.y = element_line(color="black", size = 0.2),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "white"))
}

res <- get.all.cond.error(data)
mean_errors <- plot.serial.error(res)
histograms <- plot.histograms.position(data)

# Out of curiosity, lets have a look at RTs?
plot.serial.RT <- function(serial_error){
  plot <- ggplot(data = serial_error) +
    # Median Error in dots and lines
    geom_point(aes(x = Position, y = RT, colour = Condition)) +
    geom_line(aes(x = Position, y = RT, colour = Condition)) +
    # Line segment for 95% confidence interval at each point
    geom_errorbar(aes(x = Position, ymin = RT_ci_lower, ymax = RT_ci_upper, colour = Condition), alpha = 0.3, width = 0.1) +
    ggtitle('Median RT across Serial Position') +
    scale_x_continuous(breaks = 1:8) +
    theme(text = element_text(size = 16)) 
  # Can facet to make each condition clearer
  #facet_wrap(~Condition, nrow = 3, scales = 'free')
  return(plot)
}

median_RT <- plot.serial.error(res)

# Save plot
setwd("~/git/sourcemem/EXPINT/analysis/plotting/output")
# ggsave('pos_mean_errors.png', plot = mean_errors, width = 20, height = 10, units = "cm")
# ggsave('pos_errors.png', plot = histograms, width = 30, height = 20, units = "cm")
