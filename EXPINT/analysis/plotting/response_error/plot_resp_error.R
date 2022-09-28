load("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/resp_error.RData")
#load("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/saturated.RData")
library(ggplot2)
library(ggpubr)

# Concatenate the simulated datasets
sim_spatiotemporal$model <- 'Spatiotemporal'
sim_orthosem$model <- 'Orthosem'
sim_saturated$model <- 'Saturated'

recenter_spatiotemporal$model <- 'Spatiotemporal'
recenter_orthosem$model <- 'Orthosem'
recenter_saturated$model <- 'Saturated'

models <- rbind(sim_spatiotemporal, sim_orthosem, sim_saturated)
recentered_models <- rbind(recenter_spatiotemporal, recenter_orthosem, recenter_saturated)

# Plot plain old response error
# plot.error <- function(data, models, participant){
#   # If participant is not supplied, plot all the data at a group level
#   if (missing(participant)){
#     participant <- 'Group'
#   } else {
#     data = data[data$participant == participant,]
#     models = models[model$participant == participant,]
#   }
# }

setwd("~/git/sourcemem/EXPINT/analysis/plotting/output/resp_error")
individual_error <- ggplot() +
  geom_histogram(data = data, aes(x = source_error, y = ..density..), colour = 1, fill = 'white', bins = 30) +
  geom_density(data = models, aes(x = simulated_error, color = model), adjust = 1) +
  facet_wrap(~condition)

ggsave('indiv_error.png', plot = last_plot(), width = 40, height = 35, units = "cm")

group_error <- ggplot() +
  geom_histogram(data = data, aes(x = source_error, y = ..density..), colour = 1, fill = 'white', bins = 30) +
  geom_density(data = models, aes(x = simulated_error, color = model, size = 1.2), adjust = 1)
ggsave('group_error.png', plot = last_plot(), width = 40, height = 35, units = "cm")


# ggplot() + 
#   geom_histogram(data = recenter_data, aes(x = offset, y = ..density..), bins = 30) +
#   geom_density(data = recentered_models, aes(x = offset,  color = model), adjust = 1.2) +
#   ylim(0, 0.5)
# 
# ggplot() + 
#   geom_histogram(data = recenter_data, aes(x = offset, y = ..density..), bins = 30) +
#   geom_histogram(data = recenter_saturated, aes(x = offset, y = ..density..), fill = 'red', alpha = 0.3, bins = 30) +
#   facet_grid(~orthographic) +
#   ylim(0, 0.5)


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
  setwd("~/git/sourcemem/EXPINT/analysis/plotting/output/resp_error")
  for(i in participants){
    plot.temporal.recenter(recenter_data, recentered_models, i)
    plot.asymm.recenter(recenter_data, recentered_models,i)
    plot.spatial.recenter(recenter_data, recentered_models, i)
    plot.orthographic.recenter(recenter_data, recentered_models, i)
    plot.semantic.recenter(recenter_data, recentered_models, i)
  }
  plot.temporal.recenter(recenter_data, recentered_models)
  plot.asymm.recenter(recenter_data, recentered_models)
  plot.spatial.recenter(recenter_data, recentered_models)
  plot.orthographic.recenter(recenter_data, recentered_models)
  plot.semantic.recenter(recenter_data, recentered_models)
}

# ggplot() + 
#   geom_histogram(data = data[data$cond == 'unrelated', ], aes(x = offset, y = ..density..), bins = 30) +
#   geom_density(data = model[model$cond == 'unrelated', ], aes(x = offset,  color = model), adjust = 1.2) +
#   ylim(0, 0.5) + 
#   facet_grid(~orthographic)