library(ggplot2)
library(ggpubr)

load("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/fitted_models/2023-02-25_fits.RData")
# Load simulated datasets
load("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/fitted_models/2023-02-25_sim_data.RData")
load("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/fitted_models/2023-02-25_simulated_recenter.RData")
load("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/recentered_data.RData")
data <- read.csv("~/git/sourcemem/EXPINT/data/EXPINT_data.csv")
data <- data[data$block != -1,]
# Exclude foils
data <- data[data$is_stimulus, ]
# Exclude data with inalid RT
data <- data[data$valid_RT, ]

data <- data[data$recog_rating %in% c(0,8,9),]

sim_data$present_trial <- sim_data$target_position
data$present_trial <- data$present_trial + 1

participants <- unique(data$participant)

model_names <- unique(sim_data$model)

plot.response.error <- function(data, model, model_list, participant){
  model <- model[model$model %in% model_names[model_list],]
  if(missing(participant)){
    participant <- 'Group'
  } else{
    data = data[data$participant == participant,]
    model = model[model$participant == participant,]
  }
  ggplot() +
    geom_histogram(data = data, aes(x = source_error, y = ..density..), colour = 1, fill = 'white', bins = 30) +
    geom_density(data = model, aes(x = simulated_error, color = model_name), adjust = 1) +
    facet_wrap(~condition)
  filename <- sprintf('response_error_%s.png', participant)
  ggsave(filename, plot = last_plot(), width = 80, height = 60, units = "cm")
}


plot.error.all <- function(data, sim_data, model_list){
  setwd("~/git/sourcemem/EXPINT/analysis/plotting/output/resp_error")
  for(i in participants){
    plot.response.error(data, sim_data, model_list, i)
  }
  
  plot.response.error(data, sim_data, model_list)
}

# The orthographic condition has less of a serial position effect than the other conditions.
# Does the weight of the temporal_weight model help there?
cond_serial_pos <- function(data, model, model_list){
  model <- model[model$model_name %in% model_names[model_list],]
  plot <- ggplot(data) + 
    geom_histogram(aes(x = source_error, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_density(data = model, aes(x = simulated_error, colour = model_name), size = 1.2) +
    facet_wrap(~condition + present_trial, ncol = 8) #+ 
}


setwd("~/git/sourcemem/EXPINT/analysis/plotting/output/resp_error")
source("~/git/sourcemem/EXPINT/analysis/plotting/response_error/resp_recenter_data.R")
# recentered_data <- recenter.data(data)
# recentered_model <- recentered_sim_data

# ggsave('indiv_error.png', plot = last_plot(), width = 40, height = 35, units = "cm")
plot.recenter <- function(data, model, participant){
  if (missing(participant)){
    participant <- 'Group'
  } else {
    data = data[data$participant == participant,]
    model = model[model$participant == participant,]
  }
  p1 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'orthographic', ], aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_density(data = model[model$cond == 'orthographic', ], aes(x = offset,  color = model), adjust = 1.2) +
    ylim(0, 0.5) + 
    ggtitle(sprintf('%s Condition', 'orth'))
  
  p2 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'unrelated', ], aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_density(data = model[model$cond == 'unrelated', ], aes(x = offset,  color = model), adjust = 1.2) +
    ylim(0, 0.5) + 
    ggtitle(sprintf('%s Condition', 'unrelated'))
  
  p3 <- ggplot() + 
    geom_histogram(data = data, aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_density(data = model, aes(x = offset,  color = model), adjust = 1.2) +
    ylim(0, 0.5) + 
    ggtitle(sprintf('%s Condition', 'overall'))
  
  plot <- ggarrange(p1, p2, p3, ncol = 1, nrow = 3, heights = c(1, 1, 1))
  filename <- sprintf('recenter_%s.png', participant)
  ggsave(filename, plot = last_plot(), width = 15, height = 45, units = "cm")
}


plot.orthographic.recenter <- function(data, model, participant){
  data <- data[data$orthographic < 5,]
  model <- model[model$orthographic < 5,]
  #If participant is not supplied, plot all the data at a group level
  if (missing(participant)){
    participant <- 'Group'
  } else {
    data = data[data$participant == participant,]
    model = model[model$participant == participant,]
  }
  p1 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'orthographic', ], aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 20) +
    geom_density(data = model[model$cond == 'orthographic', ], aes(x = offset,  color = model), adjust = 1.2) +
    ylim(0, 0.4) + 
    facet_grid(~orthographic) +
    ggtitle(sprintf('%s Condition, Recentered on orthographic', 'orth'))
  
  p2 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'unrelated', ], aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 20) +
    geom_density(data = model[model$cond == 'unrelated', ], aes(x = offset,  color = model), adjust = 1.2) +
    ylim(0, 0.4) + 
    facet_grid(~orthographic) +
    ggtitle(sprintf('%s Condition, Recentered on orthographic', 'unrelated'))
  
  p3 <- ggplot() + 
    geom_histogram(data = data, aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 20) +
    geom_density(data = model, aes(x = offset,  color = model), adjust = 1.2) +
    ylim(0, 0.4) + 
    facet_grid(~orthographic)  +
    ggtitle(sprintf('%s Condition, Recentered on orthographic', 'overall'))
  
  plot <- ggarrange(p1, p2, p3, ncol = 1, nrow = 3, heights = c(1, 1, 1))
  filename <- sprintf('recenter_orthographic_%s.png', participant)
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
  filename <- sprintf('recenter_semantic_%s.png', participant)
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
    geom_histogram(data = data[data$cond == 'orthographic', ], aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_density(data = model[model$cond == 'orthographic', ], aes(x = offset,  color = model), adjust = 1.2) +
    ylim(0, 0.25) + 
    facet_grid(~spatial_bin) +
    ggtitle('orthographic')
  
  p2 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'semantic', ], aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_density(data = model[model$cond == 'semantic', ], aes(x = offset,  color = model), adjust = 1.2) +
    ylim(0, 0.25) + 
    facet_grid(~spatial_bin) +
    ggtitle('semantic')
  
  p3 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'unrelated', ], aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_density(data = model[model$cond == 'unrelated', ], aes(x = offset,  color = model), adjust = 1.2) +
    ylim(0, 0.25) + 
    facet_grid(~spatial_bin) +
    ggtitle('unrelated')
  
  p4 <- ggplot() + 
    geom_histogram(data = data, aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_density(data = model, aes(x = offset,  color = model), adjust = 1.2) +
    ylim(0, 0.5) + 
    facet_grid(~spatial_bin) +
    ggtitle('overall')
  
  plot <- ggarrange(p1,p2,p3,p4, ncol = 1, common.legend = TRUE, legend="bottom")
  plot <- annotate_figure(plot, top = text_grob("Spatial Recenter", 
                                                color = "black", face = "bold", size = 16))
  
  filename <- sprintf('recenter_spatial_%s.png', participant)
  ggsave(filename, plot = last_plot(), width = 40, height = 60, units = "cm")
}

plot.temporal.recenter <- function(data, model, participant){
  data$abs_lag <- abs(data$lag)
  model$abs_lag <- abs(model$lag)
  data <- data[data$abs_lag < 5,]
  model <- model[model$abs_lag < 5,]
  if (missing(participant)){
    participant <- 'Group'
  } else {
    data = data[data$participant == participant,]
    model = model[model$participant == participant,]
  }
  p1 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'orthographic', ], aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_density(data = model[model$cond == 'orthographic', ], aes(x = offset,  color = model), adjust = 1.2) +
    ylim(0, 0.25) + 
    facet_grid(~abs_lag) +
    ggtitle('orthographic')
  
  p2 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'semantic', ], aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_density(data = model[model$cond == 'semantic', ], aes(x = offset,  color = model), adjust = 1.2) +
    ylim(0, 0.25) + 
    facet_grid(~abs_lag) +
    ggtitle('semantic')
  
  p3 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'unrelated', ], aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_density(data = model[model$cond == 'unrelated', ], aes(x = offset,  color = model), adjust = 1.2) +
    ylim(0, 0.25) + 
    facet_grid(~abs_lag) +
    ggtitle('unrelated')
  
  p4 <- ggplot() + 
    geom_histogram(data = data, aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_density(data = model, aes(x = offset,  color = model), adjust = 1.2) +
    ylim(0, 0.25) + 
    facet_grid(~abs_lag) +
    ggtitle('overall')
  
  plot <- ggarrange(p1,p2,p3,p4, ncol = 1,  common.legend = TRUE, legend="bottom")
  plot <- annotate_figure(plot, top = text_grob("Temporal Recenter", 
                                                color = "black", face = "bold", size = 16))
  filename <- sprintf('recenter_temporal_%s.png', participant)
  ggsave(filename, plot = last_plot(), width = 40, height = 60, units = "cm")
}

plot.asymm.recenter <- function(data, model, participant){
  if (missing(participant)){
    participant <- 'Group'
  } else {
    data = data[data$participant == participant,]
    model = model[model$participant == participant,]
  }
  data <- data[(data$lag < 5) && (data$lag > -5),]
  p1 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'orthographic', ], aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_density(data = model[model$cond == 'orthographic', ], aes(x = offset,  color = model), adjust = 1.2) +
    ylim(0, 0.25) + 
    facet_grid(~lag) +
    ggtitle('orthographic')
  
  p2 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'semantic', ], aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_density(data = model[model$cond == 'semantic', ], aes(x = offset,  color = model), adjust = 1.2) +
    ylim(0, 0.25) + 
    facet_grid(~lag) +
    ggtitle('semantic')
  
  p3 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'unrelated', ], aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_density(data = model[model$cond == 'unrelated', ], aes(x = offset,  color = model), adjust = 1.2) +
    ylim(0, 0.25) + 
    facet_grid(~lag) +
    ggtitle('unrelated')
  
  p4 <- ggplot() + 
    geom_histogram(data = data, aes(x = offset, y = ..density..), color = 1, fill = 'white', bins = 50) +
    geom_density(data = model, aes(x = offset,  color = model), adjust = 1.2) +
    ylim(0, 0.25) + 
    facet_grid(~lag) +
    ggtitle('overall')
  plot <- ggarrange(p1,p2,p3,p4, ncol = 1,  common.legend = TRUE, legend="bottom")
  plot <- annotate_figure(plot, top = text_grob("Asymmetric Temporal Recenter", 
                                                color = "black", face = "bold", size = 16))
  filename <- sprintf('recenter_asymm_temporal_%s.png', participant)
  ggsave(filename, plot = last_plot(), width = 80, height = 60, units = "cm")
}

plot.recentered.all <- function(recentered_data, recentered_models, model_list){
  setwd("~/git/sourcemem/EXPINT/analysis/plotting/output/resp_error")
  recentered_models <- recentered_models[recentered_models$model %in% model_names[model_list],]
  for(i in participants){
    plot.recenter(recentered_data, recentered_models, i)
    plot.temporal.recenter(recentered_data, recentered_models, i)
    plot.asymm.recenter(recentered_data, recentered_models,i)
    plot.spatial.recenter(recentered_data, recentered_models, i)
    plot.orthographic.recenter(recentered_data, recentered_models, i)
    plot.semantic.recenter(recentered_data, recentered_models, i)
  }
  plot.recenter(recentered_data, recentered_models)
  plot.temporal.recenter(recentered_data, recentered_models)
  plot.asymm.recenter(recentered_data, recentered_models)
  plot.spatial.recenter(recentered_data, recentered_models)
  plot.orthographic.recenter(recentered_data, recentered_models)
  plot.semantic.recenter(recentered_data, recentered_models)
}
