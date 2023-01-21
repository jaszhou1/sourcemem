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
library(ggpubr)
# Source the model code
source("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/intrusion_cond_model_x.R")
source("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/resp_recenter_data.R")
source("~/git/sourcemem/EXPINT/analysis/plot_recentered_data.R")
load("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/recentered_data.RData")

data <- read.csv("~/git/sourcemem/EXPINT/data/EXPINT_data.csv")
data <- data[data$block != -1,]
data <- data[data$is_stimulus, ]
data <- data[data$valid_RT, ]
data <- data[data$recognised == 1,]

simulate_data <- function(P){# Load in and filter the data
  sim_data <- simulate_intrusion_cond_model_x(99, data, P, 'test')
  recentered_sim_data <- recenter.model2(sim_data)
  res <- c()
  res$sim_data <- sim_data
  res$recentered_sim_data <- recentered_sim_data
  return(res)
}

# Specify some parameter values
prec1 <- 20
prec2 <- 10
beta1 <- 0.3
beta2 <- NA
beta3 <- NA
gamma1 <- 0.5
gamma2 <- NA
gamma3 <- NA
# intrusion weights

chi1 <- 0.2 # Item weight
chi2 <- NA
chi3 <- NA

phi1 <- 0 # Space weight
phi2 <- NA
phi3 <- NA

psi1 <- 0 # Semantic weight
psi2 <- NA
psi3 <- NA

# intrusion similarity decays
tau1 <- 0.5 # Temporal asymmetry (tau >0.5 means forwards are more similar)
tau2 <- NA
tau3 <- NA

lambda_b1 <- 5 # Similarity decay of backwards temporal lag
lambda_f1 <- 5 # Similarity decay of forwards temporal lag

lambda_b2 <- NA # Similarity decay of backwards temporal lag
lambda_f2 <- NA # Similarity decay of forwards temporal lag

lambda_b3 <- NA # Similarity decay of backwards temporal lag
lambda_f3 <- NA # Similarity decay of forwards temporal lag

zeta1 <- 0.3 # Similarity decay of spatial similarity
zeta2 <- NA
zeta3 <- NA

iota1 <- 20 # Similarity decay of orthographic component unrelated
iota2 <- NA # Decay for orthography orthographic
iota3 <- NA

upsilon1 <- 1 # Similarity decay of semantic component unrelated
upsilon2 <- NA # Decay for semantic orth
upsilon3 <- NA


P = c(prec1, prec2, beta1, beta2, beta3, gamma1, gamma2, gamma3, chi1, chi2, chi3,
       phi1, phi2, phi3, psi1, psi2, psi3, tau1, tau2, tau3, 
       lambda_b1, lambda_f1, lambda_b2, lambda_f2, lambda_b3, lambda_f3, zeta1,
       zeta2, zeta3, iota1, iota2, iota3, upsilon1, upsilon2, upsilon3) 

sim1 <- simulate_data(P)

## Plotting functions

plot.orthographic.recenter <- function(data, model){
  model <- model[model$orthographic < 5,]
  data <- data[data$orthographic < 5,]
  p1 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'orthographic', ], 
                   aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_histogram(data = model[model$cond == 'orthographic', ], 
                   aes(x = offset, y = ..density..), fill = 'red', bins = 50, alpha = 0.2) +
    ylim(0, 0.5) + 
    facet_grid(~orthographic) +
    ggtitle(sprintf('%s Condition, Recentered on orthographic', 'orth'))
  
  p2 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'unrelated', ], 
                   aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_histogram(data = model[model$cond == 'unrelated', ], 
                 aes(x = offset, y = ..density..), fill = 'red', bins = 50, alpha = 0.2) +
    ylim(0, 0.5) + 
    facet_grid(~orthographic) +
    ggtitle(sprintf('%s Condition, Recentered on orthographic', 'unrelated'))
  
  p3 <- ggplot() + 
    geom_histogram(data = data, 
                   aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_histogram(data = model, 
                 aes(x = offset, y = ..density..), fill = 'red', bins = 50, alpha = 0.2) +
    ylim(0, 0.5) + 
    facet_grid(~orthographic)  +
    ggtitle(sprintf('%s Condition, Recentered on orthographic', 'overall'))
  
  plot <- ggarrange(p1, p2, p3, ncol = 1, nrow = 3, heights = c(1, 1, 1))
  return(plot)
}

plot.semantic.recenter <- function(data, model){
  p1 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'semantic', ], 
                   aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_histogram(data = model[model$cond == 'semantic', ], 
                 aes(x = offset, y = ..density..), fill = 'red', bins = 50, alpha = 0.2) +
    ylim(0, 0.5) + 
    facet_grid(~semantic_bin) +
    ggtitle(sprintf('%s Condition, Recentered on semantic', 'semantic'))
  
  p2 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'unrelated', ], 
                   aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_histogram(data = model[model$cond == 'unrelated', ], 
                   aes(x = offset, y = ..density..), fill = 'red', bins = 50, alpha = 0.2) +
    ylim(0, 0.5) + 
    facet_grid(~semantic_bin) +
    ggtitle(sprintf('%s Condition, Recentered on semantic', 'unrelated'))
  
  p3 <- ggplot() + 
    geom_histogram(data = data, 
                   aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_histogram(data = model, 
                   aes(x = offset, y = ..density..), fill = 'red', bins = 50, alpha = 0.2) +
    ylim(0, 0.5) + 
    facet_grid(~semantic_bin)  +
    ggtitle(sprintf('%s Condition, Recentered on semantic', 'overall'))
  
  plot <- ggarrange(p1, p2, p3, ncol = 1, nrow = 3, heights = c(1, 1, 1))
  return(plot)
}

plot.spatial.recenter <- function(data, model){
  p1 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'orthographic', ], 
                   aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_histogram(data = model[model$cond == 'orthographic', ], 
                   aes(x = offset, y = ..density..), fill = 'red', bins = 50, alpha = 0.2) +
    ylim(0, 0.5) + 
    facet_grid(~spatial_bin) +
    ggtitle('orthographic')
  
  p2 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'semantic', ], 
                   aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_histogram(data = model[model$cond == 'semantic', ], 
                   aes(x = offset, y = ..density..), fill = 'red', bins = 50, alpha = 0.2) +
    ylim(0, 0.5) + 
    facet_grid(~spatial_bin) +
    ggtitle('semantic')
  
  p3 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'unrelated', ], 
                   aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_histogram(data = model[model$cond == 'unrelated', ], 
                   aes(x = offset, y = ..density..), fill = 'red', bins = 50, alpha = 0.2) +
    ylim(0, 0.5) + 
    facet_grid(~spatial_bin) +
    ggtitle('unrelated')
  
  p4 <- ggplot() + 
    geom_histogram(data = data, 
                   aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_histogram(data = model, 
                   aes(x = offset, y = ..density..), fill = 'red', bins = 50, alpha = 0.2) +
    ylim(0, 0.5) + 
    facet_grid(~spatial_bin) +
    ggtitle('overall')
  
  plot <- ggarrange(p1,p2,p3,p4, ncol = 1, common.legend = TRUE, legend="bottom")
  plot <- annotate_figure(plot, top = text_grob("Spatial Recenter", 
                                                color = "black", face = "bold", size = 16))
  return(plot)
}

plot.temporal.recenter <- function(data, model){
  data$abs_lag <- abs(data$lag)
  model$abs_lag <- abs(model$lag)
  p1 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'orthographic', ], 
                   aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_histogram(data = model[model$cond == 'orthographic', ], 
                   aes(x = offset, y = ..density..), fill = 'red', bins = 50, alpha = 0.2) +
    ylim(0, 0.3) + 
    facet_grid(~abs_lag) +
    ggtitle('orthographic')
  
  p2 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'semantic', ], 
                   aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_histogram(data = model[model$cond == 'semantic', ], 
                   aes(x = offset, y = ..density..), fill = 'red', bins = 50, alpha = 0.2) +
    ylim(0, 0.3) + 
    facet_grid(~abs_lag) +
    ggtitle('semantic')
  
  p3 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'unrelated', ], 
                   aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_histogram(data = model[model$cond == 'unrelated', ], 
                   aes(x = offset, y = ..density..), fill = 'red', bins = 50, alpha = 0.2) +
    ylim(0, 0.3) + 
    facet_grid(~abs_lag) +
    ggtitle('unrelated')
  
  p4 <- ggplot() + 
    geom_histogram(data = data, 
                   aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_histogram(data = model, 
                   aes(x = offset, y = ..density..), fill = 'red', bins = 50, alpha = 0.2) +
    ylim(0, 0.3) + 
    facet_grid(~abs_lag) +
    ggtitle('overall')
  
  plot <- ggarrange(p1,p2,p3,p4, ncol = 1,  common.legend = TRUE, legend="bottom")
  plot <- annotate_figure(plot, top = text_grob("Temporal Recenter", 
                                                color = "black", face = "bold", size = 16))
  return(plot)
}

plot.asymm.recenter <- function(data, model){
  p1 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'orthographic', ], 
                   aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_histogram(data = model[model$cond == 'orthographic', ], 
                   aes(x = offset, y = ..density..), fill = 'red', bins = 50, alpha = 0.2) +
    ylim(0, 0.3) + 
    facet_grid(~lag) +
    ggtitle('orthographic')
  
  p2 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'semantic', ], 
                   aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_histogram(data = model[model$cond == 'semantic', ], 
                   aes(x = offset, y = ..density..), fill = 'red', bins = 50, alpha = 0.2) +
    ylim(0, 0.3) + 
    facet_grid(~lag) +
    ggtitle('semantic')
  
  p3 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'unrelated', ], 
                   aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_histogram(data = model[model$cond == 'unrelated', ], 
                   aes(x = offset, y = ..density..), fill = 'red', bins = 50, alpha = 0.2) +
    ylim(0, 0.3) + 
    facet_grid(~lag) +
    ggtitle('unrelated')
  
  p4 <- ggplot() + 
    geom_histogram(data = data, 
                   aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_histogram(data = model, 
                   aes(x = offset, y = ..density..), fill = 'red', bins = 50, alpha = 0.2) +
    ylim(0, 0.3) + 
    facet_grid(~lag) +
    ggtitle('overall')
  plot <- ggarrange(p1,p2,p3,p4, ncol = 1,  common.legend = TRUE, legend="bottom")
  plot <- annotate_figure(plot, top = text_grob("Asymmetric Temporal Recenter", 
                                                color = "black", face = "bold", size = 16))
  return(plot)
}


