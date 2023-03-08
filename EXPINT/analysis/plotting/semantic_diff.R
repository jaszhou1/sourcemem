# Plot the response error and recentered error across conditions for each participant
# Point is to illustrate how the semantic manipulation differs in how in impacts
# When averaged across participant, you would think there is no effect
# For most participants, this is true, but some participants have reversed effects.
# probably not a simple explanation, but can be modelled by alloweing for three gamma parameters
# Load in data
data <- read.csv("~/git/sourcemem/EXPINT/data/EXPINT_data.csv")
load("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/recentered_data.RData")
data <- data[data$block != -1,]
# Exclude foils
data <- data[data$is_stimulus, ]
# Exclude data with inalid RT
data <- data[data$valid_RT, ]

data <- data[data$recog_rating %in% c(0,8,9),]

# Get the indexing of the trial position consistent
data$target_position <- data$present_trial + 1

load("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/fitted_models/2023-03-08_sim_data.RData")
load("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/fitted_models/2023-03-08_simulated_recenter.RData")

recentered_sim_data$model_name <- recentered_sim_data$model

model_names <- unique(sim_data$model)

plot_participant <- function(p, model_list){
  sim_data <- sim_data[sim_data$model %in% model_names[model_list],]
  recentered_sim_data <- recentered_sim_data[recentered_sim_data$model %in% model_names[model_list],]
  if(missing(p)){
    p <- 'Group'
  } else{
    data <- data[data$participant == p,]
    recentered_data <- recentered_data[recentered_data$participant == p,]
    sim_data <- sim_data[sim_data$participant == p,]
    recentered_sim_data <- recentered_sim_data[recentered_sim_data$participant == p,]
  }
  
  response_error <- plot.response.error(data, sim_data)
  recentered_error <- plot.condition.recenter(recentered_data, recentered_sim_data)
  
  # Plot 1 shows the response error and recentered error split by experimental condition
  plot <- ggarrange(response_error, recentered_error, ncol = 1, nrow = 2, heights = c(1, 1))
  annotate_figure(plot, top = text_grob(as.character(p), 
                                        color = "red", face = "bold", size = 14))
  return(plot)
}

plot.condition.recenter <- function(data, model){
  plot <- ggplot() +
    geom_histogram(data = data, 
                   aes(x = offset, y = ..density..), colour = 1, fill = 'grey60', bins = 50) +
    # geom_histogram(data = model,
    #               aes(x = offset, y = ..density.., fill = model_name), bins = 50, alpha = 0.2) +
    stat_density(data = model,
                 aes(x = offset, color = model_name), kernel = 'epanechnikov', adjust = 1,
                 position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    ylim(0, 0.25) + 
    facet_grid(~cond) +
    xlab("Response Offset") + ylab("Density") +
    theme(strip.text.x = element_blank(),
          strip.background = element_blank(),
          plot.title = element_text(face = "bold", size = 12),
          legend.position = "none",
          axis.ticks = element_line(colour = "white", size = 0.2),
          axis.line.x = element_line(color="black", size = 0.2),
          axis.line.y = element_line(color="black", size = 0.2),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "white"))
  return(plot)
}


plot.response.error <- function(data, model){
  plot <- ggplot() +
    geom_histogram(data = data, aes(x = source_error, y = ..density..), colour = 1, fill = 'grey60', bins = 50) +
    # geom_histogram(data = model, aes(x = simulated_error, y = ..density.., fill = model_name), bins = 50, alpha = 0.2) +
    stat_density(data = model, aes(x = simulated_error, color = model_name), kernel = 'epanechnikov', adjust = 1,
                 position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    facet_grid(~condition) +
    xlab("Source Error") + ylab("Density") +
    theme(strip.text.x = element_text(size = 12),
          strip.background = element_blank(),
          plot.title = element_text(face = "bold", size = 12),
          legend.position = "bottom",
          axis.ticks = element_line(colour = "grey70", size = 0.2),
          axis.line.x = element_line(color="black", size = 0.2),
          axis.line.y = element_line(color="black", size = 0.2),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "white"))
  return(plot)
}

plot.response.error.position <- function(p, data, model, model_list){
  model <- model[sim_data$model_name %in% model_names[model_list],]
  if(missing(p)){
    p <- 'Group'
  } else{
    data <- data[data$participant == p,]
    model <- model[model$participant == p,]
  }
  plot <- ggplot() +
    geom_histogram(data = data, aes(x = source_error, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    #geom_histogram(data = model, aes(x = simulated_error, y = ..density..), fill = 'red', bins = 50, alpha = 0.2) +
    stat_density(data = model, aes(x = simulated_error, color = model_name), kernel = 'epanechnikov', adjust = 1,
                 position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    facet_grid(condition~target_position) + 
    labs(title = p, x = "Source Error", y = "Density") + 
    theme(strip.text.x = element_text(size = 16)) +
    theme(strip.text.x = element_text(size = 12),
          strip.background = element_blank(),
          plot.title = element_text(face = "bold", size = 12),
          legend.position = "bottom",
          axis.ticks = element_line(colour = "grey70", size = 0.2),
          axis.line.x = element_line(color="black", size = 0.2),
          axis.line.y = element_line(color="black", size = 0.2),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "white"))
  return(plot)
}

plot.orthographic.recenter <- function(data, model, model_list, participant){
  data <- data[data$orthographic < 5,]
  model <- model[model$orthographic < 5,]
  model <- model[model$model_name %in% model_names[model_list],]
  #If participant is not supplied, plot all the data at a group level
  if (missing(participant)){
    participant <- 'Group'
  } else {
    data = data[data$participant == participant,]
    model = model[model$participant == participant,]
  }
  p1 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'orthographic', ], aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 20) +
    stat_density(data = model[model$cond == 'orthographic', ], aes(x = offset,  color = model), adjust = 1, position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    ylim(0, 0.4) + 
    facet_grid(~orthographic) +
    ggtitle(sprintf('%s Condition, Recentered on orthographic', 'orth'))
  
  p2 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'unrelated', ], aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 20) +
    stat_density(data = model[model$cond == 'unrelated', ], aes(x = offset,  color = model), adjust = 1, position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    ylim(0, 0.4) + 
    facet_grid(~orthographic) +
    ggtitle(sprintf('%s Condition, Recentered on orthographic', 'unrelated'))
  
  p3 <- ggplot() + 
    geom_histogram(data = data, aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 20) +
    stat_density(data = model, aes(x = offset,  color = model), adjust = 1, position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    ylim(0, 0.4) + 
    facet_grid(~orthographic)  +
    ggtitle(sprintf('%s Condition, Recentered on orthographic', 'overall'))
  
  plot <- ggarrange(p1, p2, p3, ncol = 1, nrow = 3, heights = c(1, 1, 1))
  #filename <- sprintf('recenter_orthographic_%s.png', participant)
  #ggsave(filename, plot = last_plot(), width = 40, height = 45, units = "cm")
  return(plot)
}

plot.semantic.recenter <- function(data, model, model_list, participant){
  model <- model[model$model_name %in% model_names[model_list],]
  #If participant is not supplied, plot all the data at a group level
  if (missing(participant)){
    participant <- 'Group'
  } else {
    data = data[data$participant == participant,]
    model = model[model$participant == participant,]
  }
  p1 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'semantic', ], aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 20) +
    stat_density(data = model[model$cond == 'semantic', ], aes(x = offset,  color = model), adjust = 1, position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    ylim(0, 0.4) + 
    facet_grid(~semantic) +
    ggtitle(sprintf('%s Condition, Recentered on semantic', 'semantic'))
  
  p2 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'unrelated', ], aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 20) +
    stat_density(data = model[model$cond == 'unrelated', ], aes(x = offset,  color = model), adjust = 1, position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    ylim(0, 0.4) + 
    facet_grid(~semantic) +
    ggtitle(sprintf('%s Condition, Recentered on semantic', 'unrelated'))
  
  p3 <- ggplot() + 
    geom_histogram(data = data, aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 20) +
    stat_density(data = model, aes(x = offset,  color = model), adjust = 1, position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    ylim(0, 0.4) + 
    facet_grid(~semantic)  +
    ggtitle(sprintf('%s Condition, Recentered on semantic', 'overall'))
  
  plot <- ggarrange(p1, p2, p3, ncol = 1, nrow = 3, heights = c(1, 1, 1))
  #filename <- sprintf('recenter_orthographic_%s.png', participant)
  #ggsave(filename, plot = last_plot(), width = 40, height = 45, units = "cm")
  return(plot)
}


plot.spatial.recenter <- function(data, model, model_list, participant){
  model <- model[model$model_name %in% model_names[model_list],]
  if (missing(participant)){
    participant <- 'Group'
  } else {
    data = data[data$participant == participant,]
    model = model[model$participant == participant,]
  }
  p1 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'orthographic', ], aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    stat_density(data = model[model$cond == 'orthographic', ], aes(x = offset,  color = model), adjust = 1, position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    ylim(0, 0.5) + 
    facet_grid(~spatial_bin) +
    ggtitle('orthographic')

  p2 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'semantic', ], aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    stat_density(data = model[model$cond == 'semantic', ], aes(x = offset,  color = model), adjust = 1, position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    ylim(0, 0.5) + 
    facet_grid(~spatial_bin) +
    ggtitle('semantic')
  
  p3 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'unrelated', ], aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    stat_density(data = model[model$cond == 'unrelated', ], aes(x = offset,  color = model), adjust = 1, position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    ylim(0, 0.5) + 
    facet_grid(~spatial_bin) +
    ggtitle('unrelated')
  
  p4 <- ggplot() + 
    geom_histogram(data = data, aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    stat_density(data = model[model$cond == 'unrelated', ], aes(x = offset,  color = model), adjust = 1, position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    ylim(0, 0.5) + 
    facet_grid(~spatial_bin) +
    ggtitle('overall')
  
  plot <- ggarrange(p1,p2,p3,p4, ncol = 1, common.legend = TRUE, legend="bottom")
  plot <- annotate_figure(plot, top = text_grob("Spatial Recenter", 
                                                color = "black", face = "bold", size = 16))
  
  # filename <- sprintf('recenter_spatial_%s.png', participant)
  # ggsave(filename, plot = last_plot(), width = 40, height = 60, units = "cm")
  return(plot)
}

plot.temporal.recenter <- function(data, model, model_list, participant){
  data$abs_lag <- abs(data$lag)
  model$abs_lag <- abs(model$lag)
  data <- data[data$abs_lag < 5,]
  model <- model[model$abs_lag < 5,]
  model <- model[model$model_name %in% model_names[model_list],]
  if (missing(participant)){
    participant <- 'Group'
  } else {
    data = data[data$participant == participant,]
    model = model[model$participant == participant,]
  }
  p1 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'orthographic', ], aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    stat_density(data = model[model$cond == 'orthographic', ], aes(x = offset,  color = model), adjust = 1, position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    ylim(0, 0.3) + 
    facet_grid(~abs_lag) +
    ggtitle('orthographic')
  
  p2 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'semantic', ], aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    stat_density(data = model[model$cond == 'semantic', ], aes(x = offset,  color = model), adjust = 1, position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    ylim(0, 0.3) + 
    facet_grid(~abs_lag) +
    ggtitle('semantic')
  
  p3 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'unrelated', ], aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    stat_density(data = model[model$cond == 'unrelated', ], aes(x = offset,  color = model), adjust = 1, position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    ylim(0, 0.3) + 
    facet_grid(~abs_lag) +
    ggtitle('unrelated')
  
  p4 <- ggplot() + 
    geom_histogram(data = data, aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    stat_density(data = model[model$cond == 'unrelated', ], aes(x = offset,  color = model), adjust = 1, position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    ylim(0, 0.3) + 
    facet_grid(~abs_lag) +
    ggtitle('overall')
  
  plot <- ggarrange(p1,p2,p3,p4, ncol = 1,  common.legend = TRUE, legend="bottom")
  plot <- annotate_figure(plot, top = text_grob("Temporal Recenter", 
                                                color = "black", face = "bold", size = 16))
  # filename <- sprintf('recenter_temporal_%s.png', participant)
  # ggsave(filename, plot = last_plot(), width = 40, height = 60, units = "cm")
  return(plot)
}
