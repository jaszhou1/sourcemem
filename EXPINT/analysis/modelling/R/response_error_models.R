# Top level script to fit response error models to my final PhD experiment
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

## Handle data prior to modelling
data <- read.csv("~/git/sourcemem/EXPINT/data/EXPINT_data.csv")
setwd("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code")
# Exclude data from practice blocks
data <- data[data$block != -1,]

# Exclude foils
data <- data[data$is_stimulus, ]

# Exclude data with inalid RT
data <- data[data$valid_RT, ]


# Define some things to iterate through
participants <- unique(data$participant)
conds <- unique(data$condition)

# Function to calculate aic 
get_aic <- function(L, n_params){
  aic <- 2*L + 2*n_params
  return(aic)
}

cosine_distance <- function(theta, phi){
  distance <- 1 - cos(theta - phi)
  return(distance)
}

angle_diff <- function(a,b){
  diff <- atan2(sin(a-b), cos(a-b))
  return(diff)
}


# There are three conditions, orthographic lists, semantic lists, and unrelated lists
# We can express this in a binary high/low way in terms of orthographic and semantic similarity

# Orthographic:   1, 0
# Semantic:       0, 1
# Unrelated:      0, 0

# Each component has two parameters associated with it: weight and scaling
# We make the selective influence assumption that changing the stimuli does not
# change the precision of memory, or how people percieve temporal similarity etc.
# only the degree to which semantic similarity influences intrusion probability.
# so I think we let only the weight change across conditions.

# Fit the spatiotemporal model as a baseline
source('fit_spatiotemporal_model.R')
# for(i in participants){
#   this.data <- data[data$participant == i,]
#   this.p.fit <- fit_spatiotemporal(this.data, i)
# }

source('fit_orthosem.R')

# Fit the saturated model
source('fit_saturated_model.R')
# for(i in participants){
#   this.data <- data[data$participant == i,]
#   this.p.fit <- fit_saturated(this.data,i)
# }

## PARTICIPANT PARALLEL LOOPS
fit_spatiotemporal_all <- function(){
  cl <- makeForkCluster((detectCores() - 1))
  registerDoParallel(cl)
  res = foreach (i = 1:length(participants),
                 .combine = rbind) %dopar% {
                   this.data <- data[data$participant == i,]
                   optim <- fit_spatiotemporal(this.data, i)
                   pest <- optim$bestmem
                   this_fit <- c(participants[i], optim$bestval, optim$aic, pest[1:13])
                   return(this_fit)
                 }
  colnames(res) <- c('participant','nLL','aic','kappa1','kappa2', 'beta', 'gamma', 'tau', 'lambda_b', 
                     'lambda_f', 'zeta', 'rho', 'chi', 'iota', 'upsilon', 'psi')
  
  res <- as.data.frame(res)
  write.csv(res, paste(toString(Sys.Date()), '_spatiotemporal_pest.csv', sep =""))
  return(res)
}

fit_orthosem_all <- function(){
  cl <- makeForkCluster((detectCores() - 1))
  registerDoParallel(cl)
  res = foreach (i = 1:length(participants),
                 .combine = rbind) %dopar% {
                   this.data <- data[data$participant == i,]
                   optim <- fit_orthosem(this.data, i)
                   pest <- optim$bestmem
                   this_fit <- c(participants[i], optim$bestval, optim$aic, pest[1:13])
                   return(this_fit)
                 }
  colnames(res) <- c('participant','nLL','aic','kappa1','kappa2', 'beta', 'gamma', 'tau', 'lambda_b', 
                     'lambda_f', 'zeta', 'rho', 'chi', 'iota', 'upsilon', 'psi')
  
  res <- as.data.frame(res)
  write.csv(res, paste(toString(Sys.Date()), '_orthosem_pest.csv', sep =""))
  return(res)
}

fit_saturated_all <- function(){
  cl <- makeForkCluster((detectCores() - 1))
  registerDoParallel(cl)
  res = foreach (i = 1:length(participants),
                 .combine = rbind) %dopar% {
                   this.data <- data[data$participant == i,]
                   optim <- fit_saturated(this.data, i)
                   pest <- optim$bestmem
                   this_fit <- c(participants[i], optim$bestval, optim$aic, pest[1:17])
                   return(this_fit)
                 }
  colnames(res) <- c('participant','nLL','aic', 'kappa1', 'kappa2', 'beta', 'gamma', 'tau', 'lambda_b', 'lambda_f', 
                     'zeta', 'rho', 'chi1', 'chi2', 'iota1', 'iota2', 'upsilon1', 'upsilon2', 
                     'psi1', 'psi2')
  
  res <- as.data.frame(res)
  write.csv(res, paste(toString(Sys.Date()), '_saturated_pest.csv', sep =""))
  return(res)
}



simulate_spatiotemporal <- function(fits, data){
  simulated_data <- data.frame()
  for(i in 1:length(participants)){
    this_data <- data[data$participant == i, ]
    this_params <- fits[i, 4:length(fits)]
    this_sim <- simulate_intrusion_model(i, this_data, this_params)
    simulated_data <- rbind(simulated_data, this_sim)
  }
  return(simulated_data)
}

simulate_saturated <- function(fits, data){
  simulated_data <- data.frame()
  for(i in 1:length(participants)){
        this_data <- data[data$participant == i, ]
        this_params <- fits[i, 4:length(fits)]
        this_sim <- simulate_intrusion_cond_model(i, this_data, this_params)
        simulated_data <- rbind(simulated_data, this_sim)
  }
  return(simulated_data)
}

# spatiotemporal <- fit_spatiotemporal_all()
# orthosem <- fit_orthosem_all()
# saturated <- fit_saturated_all()


# sim_spatiotemporal <- simulate_spatiotemporal(spatiotemporal)
# sim_orthosem <- simulate_spatiotemporal(orthosem)
# sim_saturated <- simulate_spatiotemporal(saturated)

## Recntering
source("~/git/sourcemem/EXPINT/analysis/plotting/response_error/resp_recenter_data.R")
# 
# recenter_data <- recenter.data(data)
# 
# # Recenter the spatiotemporal model
# recenter_spatiotemporal <- recenter.model(sim_spatiotemporal)
# 
# # Recenter the orthosem model
# recenter_orthosem <- recenter.model(sim_orthosem)
# 
# # recenter saturated model
# recenter_saturated <- recenter.model(sim_saturated)

