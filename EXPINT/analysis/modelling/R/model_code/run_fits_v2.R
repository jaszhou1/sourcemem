# Top level script to fit response error models to my final PhD experiment

# Version 2, use a more refined set of models to narrow in on comparisons that 
# can be written up sensibly.

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

# Source core model function
source("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/intrusion_cond_model_x.R")

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
setwd("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code")
source('x1_flat_intrusion.R')
source('x2_flat_gamma_1.R')
source('x3_flat_gamma_2.R')
source('x4_temporal.R')
source('x5_asym_temporal.R')
source('x6_spatial.R')
source('x7_ortho.R')
source('x8_temp_ortho.R')
source('x9_spatial_ortho.R')
source('x10_spatiotemporal.R')
source('x11_spatiotemporal_ortho.R')
source('x12_four_factor.R')

models <- c(flat_intrusion, flat_gamma1, flat_gamma2, temporal, 
            asym_temporal, spatial, ortho, temporal_ortho,
            spatial_ortho, spatiotemporal, spatiotemporal_ortho,
            four_factor)

model_names <- c('flat_intrusion', 'flat_gamma1', 'flat_gamma2', 'temporal',
                 'asym_temporal', 'spatial', 'ortho', 'temporal_ortho',
                 'spatial_ortho', 'spatiotemporal', 'spatiotemporal_ortho',
                 'four_factor')

fit_model <- function(data, model, model_name){
  cl <- makeForkCluster((detectCores() - 1))
  registerDoParallel(cl)
  res = foreach (i = 1:length(participants),
                 .combine = rbind) %dopar% {
                   this.data <- data[data$participant == i,]
                   optim <- model(this.data)
                   pest <- optim$bestmem
                   this_fit <- c(participants[i], optim$bestval, optim$aic, optim$Pest)
                   return(this_fit)
                 }
  res <- as.data.frame(res)
  colnames(res) <- c('participant','nLL','aic', 'kappa1', 'kappa2', 'beta1', 'beta2', 'beta3', 'gamma1', 'gamma2', 'gamma3', 
                     'phi1', 'phi2', 'phi3', 'rho1', 'rho2', 'rho3', 'chi1', 'chi2', 'chi3', 'psi1', 'psi2', 'psi3', 'tau1', 'tau2', 'tau3', 'lambda_b1', 'lambda_f1', 'lambda_b2', 'lambda_f2', 'lambda_b3', 'lambda_f3','zeta1', 'zeta2', 'zeta3', 'iota1', 'iota2', 'iota3', 'upsilon1', 'upsilon2', 'upsilon3')
  write.csv(res, paste(toString(Sys.Date()), '_', model_name,'.csv', sep =""))
  return(res)
}

model_fits <- list()
for(i in 1:length(models)){
  this_model_fit <- fit_model(data, models[[i]], model_names[[i]])
  model_fits <- append(model_fits, list(this_model_fit))
}
names(model_fits) <- model_names
save(model_fits, file = paste(toString(Sys.Date()), '_fits.RData', sep =""))

# Put all the aics together
AICs <- setNames(data.frame(matrix(nrow = 10, ncol = length(model_fits))), model_names)
for(i in 1:length(model_fits)){
  AICs[,i] <- model_fits[[i]]$aic 
}
AICs[11,] <- colSums(AICs)
source("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/AIC_weight.R") 


# Simulate model predictions from the estimated parameters (big job because recentering)
source("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/resp_recenter_data.R")
sim_data <- data.frame()
recentered_sim_data <- data.frame()
for(i in 1:length(models)){
  this_model <- model_fits[[i]]
  for(j in participants){
    this_participant_data <- data[data$participant == j,]
    this_Pest <- this_model[j, 4:38]
    this_sim_data <- simulate_intrusion_cond_model_x(j, this_participant_data, this_Pest, model_names[i])
    this_recentered_data <- recenter.model(this_sim_data, model_names[i])
    sim_data <- rbind(sim_data, this_sim_data)
    recentered_sim_data <- rbind(recentered_sim_data, this_recentered_data)
  }
}

recentered_data <- recenter.data(data)

# Bundle everything up and save output
setwd("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/fitted_models")
wAIC <- AIC_weight(AICs, 'wAIC.csv')
save(sim_data, recentered_sim_data, recentered_data, file = paste(toString(Sys.Date()), '_simulated.RData', sep =""))




