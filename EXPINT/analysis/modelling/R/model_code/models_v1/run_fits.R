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

## Load in the model variants
source("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/1_saturated.R")
source("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/2_fixed_guess.R")
source("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/3_two_condition.R")
source("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/4_same_decay.R")
source("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/5_orth_weight.R")
source("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/6_no_sem.R")
source("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/7_same_weight.R")
source("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/8_spatiotemporal.R")
source("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/9_space_orth.R")
source("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/10_temp_orth.R")
source("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/11_12_flat_gamma.R")
source("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/13_flat_intrusion.R")

# Second family of models, which take out the temporal asymmetry
source('~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/14_sym_equal.R')
source('~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/15_sym_weight.R')
source('~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/16_sym_decay.R')
source('~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/17_sym_weight_chi.R')

setwd("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/fitted_models")
models <- c(saturated, fixed_guess, two_cond, same_decay, orth_weight, no_sem, same_weight, spatiotemporal, space_orth, temp_orth, flat_gamma1, flat_gamma2, flat_intrusion, sym_equal, sym_weight, sym_decay, sym_weight_chi)

model_names <- c('saturated', 'fixed_guess', 'two_cond', 'same_decay', 'orth_weight', 'no_sem', 'same_weight', 'spatiotemporal', 'space_orth', 'temp_orth', 'flat_gamma1', 'flat_gamma2', 'flat_intrusion', 'sym_equal', 'sym_weight', 'sym_decay', 'sym_weight_chi')

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
  colnames(res) <- c('participant','nLL','aic', 'kappa1', 'kappa2', 'beta1', 'beta2', 'beta3', 'gamma1', 'gamma2', 'gamma3', 'rho1', 'rho2', 'rho3', 'chi1', 'chi2', 'chi3', 'psi1', 'psi2', 'psi3', 'tau1', 'tau2', 'tau3', 'lambda_b1', 'lambda_f1', 'lambda_b2', 'lambda_f2', 'lambda_b3', 'lambda_f3','zeta1', 'zeta2', 'zeta3', 'iota1', 'iota2', 'iota3', 'upsilon1', 'upsilon2', 'upsilon3')
  write.csv(res, paste(toString(Sys.Date()), '_', model_name,'.csv', sep =""))
  return(res)
}

fit_model_serial <- function(data, model, model_name){
  for(i in unique(participants)){
    this.data <- data[data$participant == i,]
    optim <- model(this.data)
    pest <- optim$bestmem
    this_fit <- c(participants[i], optim$bestval, optim$aic, optim$Pest)
    return(this_fit)
  }
  res <- as.data.frame(res)
  colnames(res) <- c('participant','nLL','aic', 'kappa1', 'kappa2', 'beta1', 'beta2', 'beta3', 'gamma1', 'gamma2', 'gamma3', 'rho1', 'rho2', 'rho3', 'chi1', 'chi2', 'chi3', 'psi1', 'psi2', 'psi3', 'tau1', 'tau2', 'tau3', 'lambda_b1', 'lambda_f1', 'lambda_b2', 'lambda_f2', 'lambda_b3', 'lambda_f3','zeta1', 'zeta2', 'zeta3', 'iota1', 'iota2', 'iota3', 'upsilon1', 'upsilon2', 'upsilon3')
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
wAIC <- AIC_weight(AICs, 'wAIC.csv')

# Simulate model predictions from the estimated parameters
source("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/resp_recenter_data.R")
sim_data <- data.frame()
recentered_sim_data <- data.frame()
for(i in 1:length(models)){
  this_model <- model_fits[[i]]
  for(j in participants){
    this_participant_data <- data[data$participant == j,]
    this_Pest <- this_model[j, 4:38]
    # the no temporal model needs a different simulation function
    if(model_names[[i]] == "space_orth"){
      this_sim_data <- simulate_intrusion_cond_model_phi(j, this_participant_data, this_Pest, model_names[i])
    } else{
      this_sim_data <- simulate_intrusion_cond_model(j, this_participant_data, this_Pest, model_names[i])
    }
    this_recentered_data <- recenter.model(this_sim_data, model_names[i])
    sim_data <- rbind(sim_data, this_sim_data)
    recentered_sim_data <- rbind(recentered_sim_data, this_recentered_data)
  }
}

recentered_data <- recenter.data(data)

save(sim_data, recentered_sim_data, recentered_data, file = paste(toString(Sys.Date()), '_simulated.RData', sep =""))




