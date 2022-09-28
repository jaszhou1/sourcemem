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
plot_marginal <- function(){
  indiv_error <- ggplot(data) + 
    geom_histogram(aes(x = source_error, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_density(data = models, aes(x = error, colour = model), size = 1.2) +
    facet_wrap(~participant, ncol = 5)
  ggsave('indiv_error.png', plot = last_plot(), width = 40, height = 35, units = "cm")
  
  group_error <- ggplot(data) + 
    geom_histogram(aes(x = source_error, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_density(data = models, aes(x = error, colour = model), size = 1.2) 
  ggsave('group_error.png', plot = last_plot(), width = 40, height = 35, units = "cm")
  
  indiv_rt <- ggplot(data) + 
    geom_histogram(aes(x = source_RT, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_density(data = models, aes(x = rt, colour = model), adjust = 1.5, size = 1.2) +
    xlim(0, 5) +
    facet_wrap(~participant, ncol = 5)
  ggsave('indiv_rt.png', plot = last_plot(), width = 40, height = 35, units = "cm")
  
  group_rt <- ggplot(data) + 
    geom_histogram(aes(x = source_RT, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_density(data = models, aes(x = rt, colour = model), adjust = 1.5, size = 1.2) +
    xlim(0, 5)
  ggsave('group_rt.png', plot = last_plot(), width = 40, height = 35, units = "cm")
}



# Joint Quantiles

# Recentered on Non-
load("~/git/sourcemem/EXPINT/analysis/plotting/diffusion/recentered_diffusion.RData")

recentered_models <- rbind(recentered_spatiotemporal, recentered_saturated)

recentered_models[recentered_models$cond==1, 'cond'] <- 'unrelated'
recentered_models[recentered_models$cond==2, 'cond'] <- 'orthographic'
recentered_models[recentered_models$cond==3, 'cond'] <- 'semantic'

plot.orthographic.recenter <- function(data, model, participant){
  #If participant is not supplied, plot all the data at a group level
  if (missing(participant)){
    participant <- 'Group'
  } else {
    data = data[data$participant == participant,]
    model = model[model$participant == participant,]
  }
  p1 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'orthographic', ], aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 30) +
    geom_density(data = model[model$cond == 'orthographic', ], aes(x = offset,  color = model), adjust = 1.2) +
    ylim(0, 0.5) + 
    facet_grid(~orthographic) +
    ggtitle(sprintf('%s Condition, Recentered on orthographic', 'orth'))
  
  p2 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'unrelated', ], aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 30) +
    geom_density(data = model[model$cond == 'unrelated', ], aes(x = offset,  color = model), adjust = 1.2) +
    ylim(0, 0.5) + 
    facet_grid(~orthographic) +
    ggtitle(sprintf('%s Condition, Recentered on orthographic', 'unrelated'))
  
  p3 <- ggplot() + 
    geom_histogram(data = data, aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 30) +
    geom_density(data = model, aes(x = offset,  color = model), adjust = 1.2) +
    ylim(0, 0.5) + 
    facet_grid(~orthographic)  +
    ggtitle(sprintf('%s Condition, Recentered on orthographic', 'overall'))
  
  plot <- ggarrange(p1, p2, p3, ncol = 1, nrow = 3, heights = c(1, 1, 1))
  filename <- sprintf('%s_recenter_orthographic.png', participant)
  ggsave(filename, plot = last_plot(), width = 40, height = 45, units = "cm")
}

plot.semantic.recenter <- function(data, model, participant){
  if (missing(participant)){
    participant <- 'Group'
  } else {
    data = data[data$participant == participant,]
    model = model[model$participant == participant,]
  }
  p1 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'semantic', ], aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 30) +
    geom_density(data = model[model$cond == 'semantic', ], aes(x = offset,  color = model), adjust = 1.2) +
    ylim(0, 0.5) + 
    facet_grid(~semantic_bin) +
    ggtitle(sprintf('%s Condition, Recentered on semantic', 'semantic'))
  
  p2 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'unrelated', ], aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 30) +
    geom_density(data = model[model$cond == 'unrelated', ], aes(x = offset,  color = model), adjust = 1.2) +
    ylim(0, 0.5) + 
    facet_grid(~semantic_bin) +
    ggtitle(sprintf('%s Condition, Recentered on semantic', 'unrelated'))
  
  p3 <- ggplot() + 
    geom_histogram(data = data, aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 30) +
    geom_density(data = model, aes(x = offset,  color = model), adjust = 1) +
    ylim(0, 0.5) + 
    facet_grid(~semantic_bin)  +
    ggtitle(sprintf('%s Condition, Recentered on semantic', 'overall'))
  
  plot <- ggarrange(p1, p2, p3, ncol = 1, nrow = 3, heights = c(1, 1, 1))
  filename <- sprintf('%s_recenter_semantic.png', participant)
  ggsave(filename, plot = last_plot(), width = 40, height = 45, units = "cm")
}

plot.spatial.recenter <- function(data, model, participant){
  if (missing(participant)){
    participant <- 'Group'
  } else {
    data = data[data$participant == participant,]
    model = model[model$participant == participant,]
  }
  p1 <- ggplot() + 
    geom_histogram(data = data, aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 30) +
    geom_density(data = model, aes(x = offset,  color = model), adjust = 1) +
    ylim(0, 0.7) + 
    facet_grid(~spatial_bin)  +
    ggtitle(sprintf('%s Condition, Recentered on spatial bin', 'overall'))
  
  plot <- ggarrange(p1, ncol = 1, nrow = 1, heights = c(1, 1, 1))
  filename <- sprintf('%s_recenter_spatial.png', participant)
  ggsave(filename, plot = last_plot(), width = 40, height = 15, units = "cm")
}

plot.temporal.recenter <- function(data, model, participant){
  data$lag <- abs(data$lag)
  model$lag <- abs(model$lag)
  if (missing(participant)){
    participant <- 'Group'
  } else {
    data = data[data$participant == participant,]
    model = model[model$participant == participant,]
  }
  p1 <- ggplot() + 
    geom_histogram(data = data, aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 30) +
    geom_density(data = model, aes(x = offset,  color = model), adjust = 1) +
    ylim(0, 0.5) + 
    facet_grid(~lag)  +
    ggtitle('Recentered on lag')
  
  plot <- ggarrange(p1, ncol = 1, nrow = 1, heights = c(1, 1, 1))
  filename <- sprintf('%s_recenter_temporal.png', participant)
  ggsave(filename, plot = last_plot(), width = 40, height = 15, units = "cm")
}

plot.asymm.recenter <- function(data, model, participant){
  if (missing(participant)){
    participant <- 'Group'
  } else {
    data = data[data$participant == participant,]
    model = model[model$participant == participant,]
  }
  p1 <- ggplot() + 
    geom_histogram(data = data, aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 30) +
    geom_density(data = model, aes(x = offset,  color = model), adjust = 1) +
    ylim(0, 0.5) + 
    facet_wrap(~lag, ncol = 7)  +
    ggtitle('Recentered on lag')
  
  plot <- ggarrange(p1, ncol = 1, nrow = 1, heights = c(1, 1, 1))
  filename <- sprintf('%s_recenter_asymm_temporal.png', participant)
  ggsave(filename, plot = last_plot(), width = 40, height = 20, units = "cm")
}

plot.all.individual <- function(){
  setwd("~/git/sourcemem/EXPINT/analysis/plotting/output/diffusion/recenter")
  for(i in participants){
    plot.temporal.recenter(recentered_data, recentered_models, i)
    plot.asymm.recenter(recentered_data, recentered_models,i)
    plot.spatial.recenter(recentered_data, recentered_models, i)
    plot.orthographic.recenter(recentered_data, recentered_models, i)
    plot.semantic.recenter(recentered_data, recentered_models, i)
  }
  plot.temporal.recenter(recentered_data, recentered_models)
  plot.asymm.recenter(recentered_data, recentered_models)
  plot.spatial.recenter(recentered_data, recentered_models)
  plot.orthographic.recenter(recentered_data, recentered_models)
  plot.semantic.recenter(recentered_data, recentered_models)
}
