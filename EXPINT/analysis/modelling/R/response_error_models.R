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
data <- read.csv("~/git/sourcemem/EXPINT/data/EXPINT_data2.csv")
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

fit_saturated_all <- function(){
  cl <- makeForkCluster((detectCores() - 1))
  registerDoParallel(cl)
  res = foreach (i = 1:length(participants),
                 .combine = rbind) %dopar% {
                   this.data <- data[data$participant == i,]
                   optim <- fit_saturated(this.data, i)
                   pest <- optim$bestmem
                   this_fit <- c(participants[i], optim$bestval, optim$aic, pest[1:18])
                   return(this_fit)
                 }
  colnames(res) <- c('participant','nLL','aic', 'kappa1', 'kappa2', 'beta', 'gamma', 'tau', 'lambda_b', 'lambda_f', 
                     'zeta', 'rho', 'chi1', 'chi2', 'iota1', 'iota2', 'upsilon1', 'upsilon2', 
                     'psi1', 'psi2', 'psi3')
  
  res <- as.data.frame(res)
  write.csv(res, paste(toString(Sys.Date()), '_saturated_pest.csv', sep =""))
  return(res)
}