# Script to fit a fully parameterised version of the model (Reviewer 1 of M&C wants to see gamma comparison)
library(CircStats)
library(circular)
library(DEoptim)
library(ggplot2)
library(extraDistr)
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

data <- data[data$recog_rating %in% c(0,8,9),]
# Source core model function
source("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/intrusion_cond_model_x2.R")

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

## Load in the model variants
source("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/5_fourfactor_gamma.R")

setwd("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/fitted_models")
models <- c(fourfactor_gamma)

model_names <- c('fourfactor_gamma')


fit_model <- function(data, model, model_name){
  res <- data.frame(matrix(nrow = length(participants), ncol = 38))
  for(i in 1:length(participants)){
    this.data <- data[data$participant == i,]
    fit <- model(this.data)
    pest <- fit$bestmem
    this_fit <- c(participants[i], fit$bestval, fit$aic, fit$Pest)
    res[i, ] <- this_fit
  }
  colnames(res) <- c('participant','nLL','aic', 'kappa1', 'kappa2', 'beta1', 'beta2', 'beta3', 'gamma1', 'gamma2', 'gamma3', 'chi1', 'chi2', 'chi3', 'phi1', 'phi2', 'phi3', 'psi1', 'psi2', 'psi3', 'tau1', 'tau2', 'tau3', 'lambda_b1', 'lambda_f1', 'lambda_b2', 'lambda_f2', 'lambda_b3', 'lambda_f3','zeta1', 'zeta2', 'zeta3', 'iota1', 'iota2', 'iota3', 'upsilon1', 'upsilon2', 'upsilon3')
  write.csv(res, paste(toString(Sys.Date()), '_', model_name,'.csv', sep =""))
  save(res, file = paste(toString(Sys.Date()), '_fourfactor_gamma_fit.RData', sep =""))
  return(res)
}

model_fits <- fit_model(data, fourfactor_gamma, 'fourfactor_gamma')
# Simulate model predictions from the estimated parameters (big job because recentering)
source("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/resp_recenter_data.R")
sim_data <- data.frame()
recentered_sim_data <- data.frame()
for(i in 1:length(models)){
  this_model <- model_fits
  for(j in participants){
    this_participant_data <- data[data$participant == j,]
    this_Pest <- this_model[j, 4:38]
    this_sim_data <- simulate_intrusion_cond_model_x(j, this_participant_data, this_Pest, model_names[i])
    this_recentered_data <- recenter.model2(this_sim_data)
    sim_data <- rbind(sim_data, this_sim_data)
    recentered_sim_data <- rbind(recentered_sim_data, this_recentered_data)
  }
}

recentered_data <- recenter.data(data)
recentered_data$model <- 'data'
recentered_sim_data <- rbind(recentered_sim_data, recentered_data)

# Bundle everything up and save output
# save(recentered_data, file = paste(toString(Sys.Date()), '_simulated.RData', sep =""))
save(sim_data, file = paste(toString(Sys.Date()), '_full_sim_data.RData', sep =""))
save(recentered_sim_data, file = paste(toString(Sys.Date()), '_full_simulated_recenter.RData', sep =""))
