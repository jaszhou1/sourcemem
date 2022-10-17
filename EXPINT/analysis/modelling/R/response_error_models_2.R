# Top level script to fit response error models to my final PhD experiment

# Compared to the "initial" version, these models are further elaborated
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

# 1. gamma_cond allows different intrusion scaling across conditions
source('fit_gamma.R')
# 2. gamma_beta_cond allows for different intrusion, and guess weight across conditions
source('fit_gamma_beta.R')
# 3. gamma_beta_kappa_cond allows for all of above, as well as different precision of mem/intrusion across conditions
# Actually not doing this yet, instead fit a dummy strawman type one, with no spatiotemporal
source('fit_pure_orthosem.R')

# Exclude data from practice blocks
data <- data[data$block != -1,]

# Exclude foils
data <- data[data$is_stimulus, ]

# Exclude data with inalid RT
data <- data[data$valid_RT, ]

# Exclude data where target words were not recognised
data <- data[data$recognised == 1,]

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

## PARTICIPANT PARALLEL LOOPS
fit.gamma.all <- function(){
  cl <- makeForkCluster((detectCores() - 1))
  registerDoParallel(cl)
  res = foreach (i = 1:length(participants),
                 .combine = rbind) %dopar% {
                   this.data <- data[data$participant == i,]
                   optim <- fit_gamma(this.data, i)
                   pest <- optim$bestmem
                   this_fit <- c(participants[i], optim$bestval, optim$aic, pest[1:19])
                   return(this_fit)
                 }
  colnames(res) <- c('participant','nLL','aic','kappa1','kappa2', 'beta', 'gamma1',
                     'gamma2', 'gamma3', 'tau', 'lambda_b', 'lambda_f', 
                     'zeta', 'rho', 'chi1', 'chi2', 'iota1', 'iota2', 'upsilon1', 'upsilon2', 
                     'psi1', 'psi2')
  
  res <- as.data.frame(res)
  write.csv(res, paste(toString(Sys.Date()), '_gamma_pest.csv', sep =""))
  return(res)
}

simulate.gamma <- function(fits, data){
  simulated_data <- data.frame()
  for(i in 1:length(participants)){
    this_data <- data[data$participant == i, ]
    this_params <- fits[i, 4:length(fits)]
    this_sim <- simulate_gamma_cond_model(i, this_data, this_params)
    simulated_data <- rbind(simulated_data, this_sim)
  }
  return(simulated_data)
}

fit.gammabeta.all <- function(){
  cl <- makeForkCluster((detectCores() - 1))
  registerDoParallel(cl)
  res = foreach (i = 1:length(participants),
                 .combine = rbind) %dopar% {
                   this.data <- data[data$participant == i,]
                   optim <- fit_gamma_beta(this.data, i)
                   pest <- optim$bestmem
                   this_fit <- c(participants[i], optim$bestval, optim$aic, pest[1:21])
                   return(this_fit)
                 }
  colnames(res) <-  c('participant','nLL','aic','kappa1','kappa2', 'beta1', 'beta2', 'beta3',
                      'gamma1','gamma2', 'gamma3', 'tau', 'lambda_b', 'lambda_f', 
                      'zeta', 'rho', 'chi1', 'chi2', 'iota1', 'iota2', 'upsilon1', 'upsilon2', 
                      'psi1', 'psi2')
  
  res <- as.data.frame(res)
  write.csv(res, paste(toString(Sys.Date()), '_gammabeta_pest.csv', sep =""))
  return(res)
}

simulate.gammabeta <- function(fits, data){
  simulated_data <- data.frame()
  for(i in 1:length(participants)){
    this_data <- data[data$participant == i, ]
    this_params <- fits[i, 4:length(fits)]
    this_sim <- simulate_gamma_beta_cond_model(i, this_data, this_params)
    simulated_data <- rbind(simulated_data, this_sim)
  }
  return(simulated_data)
}

fit.pure.orthosem.all <- function(){
  cl <- makeForkCluster((detectCores() - 1))
  registerDoParallel(cl)
  res = foreach (i = 1:length(participants),
                 .combine = rbind) %dopar% {
                   this.data <- data[data$participant == i,]
                   optim <- fit_pure_orthosem(this.data, i)
                   pest <- optim$bestmem
                   this_fit <- c(participants[i], optim$bestval, optim$aic, pest[1:7])
                   return(this_fit)
                 }
  colnames(res) <-  c('participant','nLL','aic','kappa1','kappa2', 'beta', 'gamma',
                      'iota', 'upsilon', 'psi')
  
  res <- as.data.frame(res)
  write.csv(res, paste(toString(Sys.Date()), '_gammabeta_pest.csv', sep =""))
  return(res)
}

simulate.pure.orthosem <- function(fits, data){
  simulated_data <- data.frame()
  for(i in 1:length(participants)){
    this_data <- data[data$participant == i, ]
    this_params <- fits[i, 4:length(fits)]
    this_sim <- simulate_pure_orthosem_model(i, this_data, this_params)
    simulated_data <- rbind(simulated_data, this_sim)
  }
  return(simulated_data)
}


# Function calls
# gamma <- fit.gamma.all()
# sim_gamma <- simulate.gamma(gamma)
# 
# gammabeta <- fit.gammabeta.all()
# sim_gammabeta <- simulate.gammabeta(gammabeta)
# 
# orthosem <- fit.pure.orthosem.all()
# sim_orthosem <- simulate.pure.orthosem(orthosem)

## Recentering
source("~/git/sourcemem/EXPINT/analysis/plotting/response_error/resp_recenter_data.R")
# # Data
# recenter_data <- recenter.data(data)
# 
# # Recenter the gamma model
# recenter_gamma <- recenter.model(sim_gamma, 'gamma')
# recenter_gammabeta <- recenter.model(sim_gammabeta, 'gamma + beta')
# recenter_orthosem <- recenter.model(sim_orthosem, 'pure orthosem')
# 
# save.image(file = paste(toString(Sys.Date()), '_response_error.RData', sep =""))

