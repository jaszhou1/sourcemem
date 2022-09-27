## PLOT_DIFFUSION_PREDICTIONS
# Read in simulated datasets from the MATLAB code as .csv, turn the simulated
# data into density co-ordinates to plot against the data, from a variety of 
# facets.

setwd("~/git/sourcemem/EXPINT/analysis/plotting/diffusion")

## Load dependencies
library(circular)
library(stringdist)
library(rjson)
library(lsa)
library(psycho)
library(ggplot2)
library(grid)

# Define plotting parameters
AXIS.CEX <- 1
AXIS.LABEL.CEX <- 1
NUM.BINS <- 50
X.RESP.LOW <- -pi - 0.01
X.RESP.HI <- pi + 0.01
Y.RESP.LOW <- 0.0
Y.RESP.HI <- 0.8


## Read in and handle observed data
data <- read.csv("~/git/sourcemem/EXPINT/analysis/modelling/MATLAB/EXPINT_data.csv")

# Exclude data from practice blocks
data <- data[data$block != -1,]

# Get rid of foil data, and data with invalid RT
data <- data[(data$valid_RT) & (data$is_stimulus),]

# Express RTs in seconds, not ms
data$source_RT <- data$source_RT/1000

# Define some things to iterate through
participants <- unique(data$participant)
conds <- unique(data$condition)

## Read in simulated data
saturated <- read.csv("~/git/sourcemem/EXPINT/analysis/plotting/diffusion/sim_saturated.csv")
spatiotemporal <- read.csv("~/git/sourcemem/EXPINT/analysis/plotting/diffusion/sim_spatiotemporal.csv")
saturated[,50] <- 'saturated'
spatiotemporal[,50] <- 'spatiotemporal'

col.names <- c('error', 'rt', 'resp_angle', 'targ_angle', 'trial_number',
               'offset_1', 'offset_2', 'offset_3', 'offset_4', 'offset_5',
               'offset_6', 'offset_7',
               'lag_1', 'lag_2', 'lag_3', 'lag_4', 'lag_5',
               'lag_6', 'lag_7',
               'space_1', 'space_2', 'space_3', 'space_4', 'space_5',
               'space_6', 'space_7',
               'orth_1', 'orth_2', 'orth_3', 'orth_4', 'orth_5',
               'orth_6', 'orth_7',
               'sem_1', 'sem_2', 'sem_3', 'sem_4', 'sem_5',
               'sem_6', 'sem_7',
               'angle_1', 'angle_2', 'angle_3', 'angle_4', 'angle_5',
               'angle_6', 'angle_7',
               'cond', 'participant', 'model')

colnames(saturated) <- col.names
colnames(spatiotemporal) <- col.names

models <- rbind(saturated, spatiotemporal)

# Plotting
setwd("~/git/sourcemem/EXPINT/analysis/plotting/output/diffusion")

# Marginal Error/ RT
indiv_error <- ggplot(data) + 
  geom_histogram(aes(x = source_error, y = ..density..), colour = 1, fill = 'white', bins = 50) +
  geom_density(data = models, aes(x = error, colour = model), size = 1.2) +
  facet_wrap(~participant, ncol = 5)

group_error <- ggplot(data) + 
  geom_histogram(aes(x = source_error, y = ..density..), colour = 1, fill = 'white', bins = 50) +
  geom_density(data = models, aes(x = error, colour = model), size = 1.2) 

indiv_rt <- ggplot(data) + 
  geom_histogram(aes(x = source_RT, y = ..density..), colour = 1, fill = 'white', bins = 50) +
  geom_density(data = models, aes(x = rt, colour = model), adjust = 1.5, size = 1.2) +
  xlim(0, 5) +
  facet_wrap(~participant, ncol = 5)

group_rt <- ggplot(data) + 
  geom_histogram(aes(x = source_RT, y = ..density..), colour = 1, fill = 'white', bins = 50) +
  geom_density(data = models, aes(x = rt, colour = model), adjust = 1.5, size = 1.2) +
  xlim(0, 5) 


# Joint Quantiles

# Recentered on Non-
source('recenter_data.R')
load("~/git/sourcemem/EXPINT/analysis/plotting/diffusion/recenter_data.RData")

models <- rbind(recenter_spatiotemporal, recenter_saturated)

plot_orth <- function(data, models, cond){
  this_cond_data <- data[data$cond == cond, ]
  this_cond_models <- model[model$cond == cond, ]
  orth <- ggplot() + 
    geom_histogram(data = this_cond_data, aes(x = offset, y = ..density..), bins = 30) +
    geom_density(data = this_cond_models, aes(x = offset), colour = model) + 
    ylim(0, 0.5) + 
    facet_grid(participant~orthographic) +
    ggtitle(sprintf('%s Condition, Recentered on orthographic', cond))
}



ggplot() + 
  geom_histogram(data = recenter_data[recenter_data$cond == 'orthographic',], aes(x = offset, y = ..density..), bins = 30) +
  geom_density(data = recentered_shallow[recentered_shallow$cond == 2, ], aes(x = offset), colour = 'red') +
  geom_density(data = recentered_steep[recentered_steep$cond == 2, ], aes(x = offset), colour = 'blue') +
  ylim(0, 0.5) + 
  facet_grid(~orthographic)