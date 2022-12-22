# PLOT_SIMULATION.R
# This function is one intended for exploration of the model.
# Provided a set of parameters, we simulate some data and generate a series of plots
# including recentered ones. This allows us to see if the model is behaving sensibly,
# particularly in regards to the different intrusion weights and slopes.

## load dependencies
library(CircStats)
library(circular)
library(ggplot2)
library(extraDistr)
library(plyr)
library(R.utils)
library(statip)

# Source the model code
source("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/intrusion_cond_model.R")

# Load in and filter the data
data <- read.csv("~/git/sourcemem/EXPINT/data/EXPINT_data.csv")
data <- data[data$block != -1,]
data <- data[data$is_stimulus, ]
data <- data[data$valid_RT, ]
data <- data[data$recognised == 1,]

# Specify some parameter values
prec1 <- 20
prec2 <- 10
beta1 <- 0.3
beta2 <- NA
beta3 <- NA
gamma1 <- 0.1
gamma2 <- NA
gamma3 <- NA
# intrusion weights
rho1 <- 0.3 # Spatial weight
rho2 <- NA
rho3 <- NA

chi1 <- 0.2 # Orthographic weight
chi2 <- NA
chi3 <- NA

psi1 <- 0 # Semantic weight
psi2 <- NA
psi3 <- NA

# intrusion similarity decays
tau1 <- 0.6 # Temporal asymmetry (tau >0.5 means forwards are more similar)
tau2 <- NA
tau3 <- NA

lambda_b1 <- 1 # Similarity decay of backwards temporal lag
lambda_f1 <- 1 # Similarity decay of forwards temporal lag

lambda_b2 <- NA # Similarity decay of backwards temporal lag
lambda_f2 <- NA # Similarity decay of forwards temporal lag

lambda_b3 <- NA # Similarity decay of backwards temporal lag
lambda_f3 <- NA # Similarity decay of forwards temporal lag

zeta1 <- 0.3 # Similarity decay of spatial similarity
zeta2 <- NA
zeta3 <- NA

iota1 <- 0.2 # Similarity decay of orthographic component unrelated
iota2 <- NA # Decay for orthography orthographic
iota3 <- NA

upsilon1 <- 0.4 # Similarity decay of semantic component unrelated
upsilon2 <- NA # Decay for semantic orth
upsilon3 <- NA

P = c(prec1, prec2, beta1, beta2, beta3, gamma1, gamma2, gamma3, rho1, rho2, rho3,
         chi1, chi2, chi3, psi1, psi2, psi3, tau1, tau2, tau3, lambda_b1,
         lambda_f1, lambda_b2, lambda_f2, lambda_b3, lambda_f3, zeta1,
         zeta2, zeta3, iota1, iota2, iota3, upsilon1, upsilon2, upsilon3)

sim_data <- simulate_intrusion_cond_model(99, data, P)

# Recenter the simulated data
source("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/recenter_data.R")
source("~/git/sourcemem/EXPINT/analysis/plot_recentered_data.R")
recentered_sim_data <- recenter_model(sim_data)

