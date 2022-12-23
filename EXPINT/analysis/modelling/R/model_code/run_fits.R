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

models <- c(saturated, fixed_guess, two_cond, same_decay, orth_weight, no_sem, same_weight, spatiotemporal, space_orth, temp_orth, flat_gamma1, flat_gamma2, flat_intrusion)

model_names <- c('saturated', 'fixed_guess', 'two_cond', 'same_decay', 'orth_weight', 'no_sem', 'same_weight', 'spatiotemporal', 'space_orth', 'temp_orth', 'flat_gamma1', 'flat_gamma2', 'flat_intrusion')

fit_model <- function(data, model, model_name){
  cl <- makeForkCluster((detectCores() - 1))
  registerDoParallel(cl)
  res = foreach (i = 1:length(participants),
                 .combine = rbind) %dopar% {
                   this.data <- data[data$participant == i,]
                   optim <- model(this.data, i)
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
for(i in length(models)){
  this_model_fit <- fit_model(data, models[[i]], model_names[[i]])
  model_fits <- append(model_fits, list(this_model_fit))
}

save(model_fits, file = paste(toString(Sys.Date()), '_fits.RData', sep =""))

# Simulate model predictions from the estimated parameters






