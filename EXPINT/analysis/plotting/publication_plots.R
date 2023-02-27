# Top-level plotting script that generates (most) figures for the manuscript

setwd("~/git/sourcemem/EXPINT/analysis/plotting")
source('individual_error.R')

# Load in data
data <- read.csv("~/git/sourcemem/EXPINT/data/EXPINT_data.csv")
data <- data[data$block != -1,]
# Exclude foils
data <- data[data$is_stimulus, ]
# Exclude data with inalid RT
data <- data[data$valid_RT, ]

# Load recentered data
load("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/recentered_data.RData")

# Load model simulation
load("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/fitted_models/2023-02-18_sim_data.RData")
load("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/fitted_models/2023-02-18_simulated_recenter.RData")


# Plot of individual-level source error distributions
fig4 <- individual.error.figure(data, "")

