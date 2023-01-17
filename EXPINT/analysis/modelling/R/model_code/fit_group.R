# Top level script to fit response error models to my final PhD experiment

# Fit to group level data, see if it picks up the intursion patterns any better

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

# Introduce a new set of models, based on what fit well from the above list,
# which allow for difference in weight and slope of similarity factors
source('x13_temporal_weight.R')
source('x14_spatial_weight.R')
source('x15_spatiotemporal_weight.R')
source('x16_temporal_decay.R')
source('x17_spatial_decay.R')
source('x18_spatiotemporal_decay.R')

models <- c(flat_intrusion, flat_gamma1, flat_gamma2, temporal, 
            asym_temporal, spatial, ortho, temporal_ortho,
            spatial_ortho, spatiotemporal, spatiotemporal_ortho,
            four_factor, temporal_ortho_weight, spatial_ortho_weight,
            spatiotemporal_ortho_weight, temporal_ortho_decay, spatial_ortho_decay,
            spatiotemporal_ortho_decay)

model_names <- c('flat_intrusion', 'flat_gamma1', 'flat_gamma2', 'temporal',
                 'asym_temporal', 'spatial', 'ortho', 'temporal_ortho',
                 'spatial_ortho', 'spatiotemporal', 'spatiotemporal_ortho',
                 'four_factor', 'temporal_weight', 'spatial_weight',
                 'spatiotemporal_weight', 'temporal_decay', 'spatial_decay', 
                 'spatiotemporal_decay')

cl <- makeForkCluster((detectCores() - 1))
registerDoParallel(cl)
res = foreach (i = 1:length(models), .combine = rbind) %dopar% {
  optim <- models[[i]](data)
  this_model <- c(model_names[i], optim$bestval, optim$aic, optim$Pest)
  return(this_model)
}
colnames(res) <- c('model','nLL','aic', 'kappa1', 'kappa2', 'beta1', 'beta2', 'beta3', 'gamma1', 'gamma2', 'gamma3', 
                  'phi1', 'phi2', 'phi3', 'rho1', 'rho2', 'rho3', 'chi1', 'chi2', 'chi3', 'psi1', 'psi2', 'psi3', 'tau1', 'tau2', 'tau3', 'lambda_b1', 'lambda_f1', 'lambda_b2', 'lambda_f2', 'lambda_b3', 'lambda_f3','zeta1', 'zeta2', 'zeta3', 'iota1', 'iota2', 'iota3', 'upsilon1', 'upsilon2', 'upsilon3')

save(res, file = paste(toString(Sys.Date()), '_group_fits.RData', sep =""))

# Simulate model predictions from the estimated parameters (big job because recentering)
source("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/resp_recenter_data.R")
sim_data <- data.frame()
recentered_sim_data <- data.frame()

for(i in 1:length(models)){
  this_Pest <- res[i, 4:41]
  this_sim_data <- simulate_intrusion_cond_model_x('Group', data, this_Pest, model_names[i])
  this_recentered_data <- recenter.model2(this_sim_data)
  sim_data <- rbind(sim_data, this_sim_data)
  recentered_sim_data <- rbind(recentered_sim_data, this_recentered_data)
}
# Bundle everything up and save output
# save(recentered_data, file = paste(toString(Sys.Date()), '_simulated.RData', sep =""))
save(sim_data, file = paste(toString(Sys.Date()), '_group_sim_data.RData', sep =""))
save(recentered_sim_data, file = paste(toString(Sys.Date()), '_group_simulated_recenter.RData', sep =""))
