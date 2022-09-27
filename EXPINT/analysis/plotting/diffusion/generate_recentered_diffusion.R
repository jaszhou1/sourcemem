## PLOT_DIFFUSION_PREDICTIONS
# Read in simulated datasets from the MATLAB code as .csv, turn the simulated
# data into density co-ordinates to plot against the data, from a variety of 
# facets.

setwd("~/git/sourcemem/EXPINT/analysis/plotting/")

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

# Recentered on Non-
source('recenter_data.R')
recentered_data <- recenter.data(data)
recentered_saturated <- recenter.model(saturated)
recentered_spatiotemporal <- recenter.model(spatiotemporal)

save.image('recentered_diffusion.RData')