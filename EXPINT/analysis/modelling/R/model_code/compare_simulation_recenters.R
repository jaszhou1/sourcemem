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

# Recenter the spatiotemporal model

# recenter saturated model

# Plot recentered spatiotemporal against data

              