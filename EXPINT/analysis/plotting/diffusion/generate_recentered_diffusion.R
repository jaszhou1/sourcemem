## PLOT_DIFFUSION_PREDICTIONS
# Read in simulated datasets from the MATLAB code as .csv, turn the simulated
# data into density co-ordinates to plot against the data, from a variety of 
# facets.

setwd("~/git/sourcemem/EXPINT/analysis/plotting/diffusion")

## Load dependencies
library(circular)

## Read in and handle observed data
data <- read.csv("~/git/sourcemem/EXPINT/analysis/modelling/MATLAB/EXPINT_data.csv")

# Exclude data from practice blocks
data <- data[data$block != -1,]

# Get rid of foil data, and data with invalid RT
data <- data[(data$valid_RT) & (data$is_stimulus),]
data <- data[data$recog_rating %in% c(0,8,9),]

# Express RTs in seconds, not ms
data$source_RT <- data$source_RT/1000

# Define some things to iterate through
participants <- unique(data$participant)
conds <- unique(data$condition)

## Read in simulated data
spatiotemporal <- read.csv("~/git/sourcemem/EXPINT/analysis/plotting/diffusion/sim_spatiotemp.csv")
fourfactor <- read.csv("~/git/sourcemem/EXPINT/analysis/plotting/diffusion/sim_fourfactor.csv")
spatiotemporal_ortho <- read.csv("~/git/sourcemem/EXPINT/analysis/plotting/diffusion/sim_spatiotemp_ortho.csv")

spatiotemporal[,50] <- 'spatiotemporal'
fourfactor[,50] <- 'fourfactor'
spatiotemporal_ortho[,50] <- 'spatiotemporal_ortho'

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

colnames(spatiotemporal) <- col.names
colnames(fourfactor) <- col.names
colnames(spatiotemporal_ortho) <- col.names

models <- rbind(spatiotemporal, fourfactor, spatiotemporal_ortho)

# Recentered on Non-
source('recenter_data.R')
recentered_data <- recenter.data(data)
recentered_spatiotemporal <- recenter.model(spatiotemporal)
recentered_orthographic <- recenter.model(fourfactor)
recentered_spatiotemporal_w <- recenter.model(spatiotemporal_ortho)

save.image('recentered_diffusion.RData')
