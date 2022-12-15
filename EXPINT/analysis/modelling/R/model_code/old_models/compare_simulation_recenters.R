# The recentered predictions arent showing what i expect (orthographic slope in saturated, no slope in spat)
library(CircStats)
library(circular)
library(DEoptim)
library(ggplot2)
library(extraDistr)
library(foreach)
library(doParallel)
library(plyr)
library(R.utils)
library(statip)

cosine_distance <- function(theta, phi){
  distance <- 1 - cos(theta - phi)
  return(distance)
}

angle_diff <- function(a,b){
  diff <- atan2(sin(a-b), cos(a-b))
  return(diff)
}


# Load in the data
data <- read.csv("~/git/sourcemem/EXPINT/data/EXPINT_data.csv")
setwd("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code")
# Exclude data from practice blocks
data <- data[data$block != -1,]

# Exclude foils
data <- data[data$is_stimulus, ]

# Exclude data with inalid RT
data <- data[data$valid_RT, ]

# Simulate spatiotemporal model
source('intrusion_gradient_model.R')
spa_P <- c(12, 10, 0.4, 0.2, 0.5, 0.7, 0.7,  0.5, 0.5, 0, 0, 0, 0)
sim_spatiotemporal <- simulate_intrusion_model(99, data, spa_P)

# Simulate orthographic-semantic model
orthosem_P <- c(12, 10, 0.4, 0.2, 0.5, 0.7, 0.7,  0.5, 0.5, 0.8, 1, 1, 0.5)
sim_orthosem <- simulate_intrusion_model(99, data, orthosem_P)

# Simulate the saturated model
source('intrusion_gradient_model_conditions.R')
saturated_P <- c(12, 10, 0.4, 0.2, 0.5, 0.7, 0.7,  0.5, 0.5, 0.1, 0.8, 1, 1, 2, 2, 0.3, 0.6)
sim_saturated <- simulate_intrusion_cond_model(99, data, saturated_P)

## Recntering
source("~/git/sourcemem/EXPINT/analysis/plotting/response_error/resp_recenter_data.R")
# Recenter data
recenter_data <- recenter.data(data)

# Recenter the spatiotemporal model
recenter_spatiotemporal <- recenter.model(sim_spatiotemporal)

# Recenter the orthosem model
recenter_orthosem <- recenter.model(sim_orthosem)

# recenter saturated model
recenter_saturated <- recenter.model(sim_saturated)

recentered_models <- rbind(recenter_spatiotemporal, recenter_orthosem, recenter_saturated)

################# PLOTS

# Plot response error

plot_error <- function(data, model){
  ggplot()+ 
    geom_histogram(data = data, aes(x = source_error, y = ..density..), bins = 30) +
    geom_histogram(data = model, aes(x = simulated_error, y = ..density..), fill = 'red', alpha = 0.2, bins = 30) +
    ylim(0, 2) + 
    facet_grid(~participant)
}


# Plot recentered spatiotemporal against data

plot_temporal <- function(data, model, cond){
  ggplot() + 
    geom_histogram(data = data[data$cond == cond, ], aes(x = offset, y = ..density..), bins = 30) +
    geom_histogram(data = model[model$cond == cond, ], aes(x = offset, y = ..density..), fill = 'red', alpha = 0.2, bins = 30) +
    ylim(0, 0.5) + 
    facet_grid(~lag) +
    ggtitle(sprintf('%s Condition, Recentered on lag', cond))
  
}

plot_spatial <- function(data, model, cond){
  ggplot() + 
    geom_histogram(data = data[data$cond == cond, ], aes(x = offset, y = ..density..), bins = 30) +
    geom_histogram(data = model[model$cond == cond, ], aes(x = offset, y = ..density..), fill = 'red', alpha = 0.2, bins = 30) +
    ylim(0, 0.5) + 
    facet_grid(~spatial_bin) +
    ggtitle(sprintf('%s Condition, Recentered on spatial bin', cond))
  
}

plot_orth <- function(data, model){
  p1 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'orthographic', ], aes(x = offset, y = ..density..), bins = 30) +
    geom_histogram(data = model[model$cond == 'orthographic', ], aes(x = offset, y = ..density..), fill = 'red', alpha = 0.2, bins = 30) +
    ylim(0, 0.5) + 
    facet_grid(~orthographic) +
    ggtitle(sprintf('%s Condition, Recentered on orthographic', 'orth'))

  p2 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'unrelated', ], aes(x = offset, y = ..density..), bins = 30) +
    geom_histogram(data = model[model$cond == 'unrelated', ], aes(x = offset, y = ..density..), fill = 'red', alpha = 0.2, bins = 30) +
    ylim(0, 0.5) + 
    facet_grid(~orthographic) +
    ggtitle(sprintf('%s Condition, Recentered on orthographic', 'unrelated'))

  p3 <- ggplot() + 
    geom_histogram(data = data, aes(x = offset, y = ..density..), bins = 30) +
    geom_histogram(data = model, aes(x = offset, y = ..density..), fill = 'red', alpha = 0.2, bins = 30) +
    ylim(0, 0.5) + 
    facet_grid(~orthographic) +
    ggtitle(sprintf('%s Condition, Recentered on orthographic', 'overall'))
  
  
  ggsave('recenter_orth_overall.png', plot = last_plot(), width = 20, height = 15, units = "cm")
}

plot_sem <- function(data, model, cond){
  ggplot() + 
    geom_histogram(data = data[data$cond == cond, ], aes(x = offset, y = ..density..), bins = 30) +
    geom_histogram(data = model[model$cond == cond, ], aes(x = offset, y = ..density..), fill = 'red', alpha = 0.2, bins = 30) +
    ylim(0, 0.5) + 
    facet_grid(~semantic_bin) +
    ggtitle(sprintf('%s Condition, Recentered on semantic', cond))
  
}

