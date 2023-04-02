library(ggplot2)
library(ggpubr)

# Load data
data <- read.csv("~/git/sourcemem/EXPINT/data/EXPINT_data.csv")

# Exclude data from practice blocks
data <- data[data$block != -1,]

# Get rid of foil data, and data with invalid RT
data <- data[(data$valid_RT) & (data$is_stimulus),]
data <- data[data$recog_rating %in% c(0,8,9),]

# recentered_data <- recenter.data(data)
# save(recentered_data, file = "~/git/sourcemem/EXPINT/data/recentered_data.RData")
load("~/git/sourcemem/EXPINT/data/recentered_data.RData")

# Load Model Predictions
load("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/fitted_models/2023-03-16_fits.RData")
# Load simulated datasets
load("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/fitted_models/2023-03-16_sim_data.RData")
load("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/fitted_models/2023-03-16_simulated_recenter.RData")

participants <- unique(data$participant)
conds <- unique(data$condition)
model_names <- unique(sim_data$model_name)

# Set output folder
setwd("~/git/sourcemem/EXPINT/analysis/plotting/output/resp_error")
############################# PLOTTING #########################################
plot.all <- function(model_list){
  for(i in unique(data$participant)){
    this_plot <- plot.participant(i, model_list)
    filename <- sprintf('%s_resp_plot.png', i)
    ggsave(filename, plot = this_plot, width = 20, height = 15, units = "cm")
  }
  this_plot <- plot.participant(model_list = model_list)
  filename <- 'group_plot.png'
  ggsave(filename, plot = this_plot, width = 20, height = 15, units = "cm")
}

cond_serial_pos <- function(data, sim_data, model_list){
  sim_data <- sim_data[sim_data$model_name %in% model_names[model_list],]
  plot <- ggplot(data) + 
    geom_histogram(aes(x = source_error, y = ..density..), colour = 'grey80', fill = 'grey80', bins = 50) +
    geom_density(data = sim_data, aes(x = simulated_error, colour = model_name), size = 1.2) +
    facet_wrap(~condition + present_trial, ncol = 8) +
    xlab("Source Error") + ylab("Density") +
    theme(text = element_text(size=20),
          strip.background = element_blank(),
          plot.title = element_text(face = "bold", size = 12),
          legend.position = "none",
          axis.ticks = element_line(colour = "grey70", size = 0.2),
          axis.line.x = element_line(color="black", size = 0.2),
          axis.line.y = element_line(color="black", size = 0.2),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "white"))
  filename <- 'group_serial_plot.png'
  ggsave(filename, plot = plot, width = 40, height = 35, units = "cm")
}

############################### LEVEL 2 ########################################

plot.participant <- function(p, model_list){
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
  recentered <- plot.recenter(recentered_data, recentered_sim_data)
  
  plot <- ggarrange(response_error,
                    recentered,
                    ncol = 1, nrow = 2, heights = c(1, 1))
  plot <- annotate_figure(plot, left = text_grob(sprintf('P%s', as.character(1)), 
                                        color = "black", face = "bold", size = 14))
  return(plot)
}

################################## LEVEL 3 #####################################
plot.response.error <- function(data, model){
  plot <- ggplot() +
    geom_histogram(data = data, aes(x = source_error, y = ..density..), colour = 'grey80', fill = 'grey80', bins = 50) +
    # geom_histogram(data = model, aes(x = simulated_error, y = ..density.., fill = model_name), bins = 50, alpha = 0.2) +
    stat_density(data = model, aes(x = simulated_error, color = model_name), kernel = 'epanechnikov', adjust = 1,
                 position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    facet_grid(~condition) +
    scale_x_continuous(name = 'Source Error', breaks = c(-3.14, 0, 3.14), labels = c(expression(-pi), "0", expression(pi))) +
    #ylab("Density") +
    theme(text = element_text(size=20),
          strip.background = element_blank(),
          plot.title = element_text(face = "bold", size = 12),
          legend.position = "none",
          axis.ticks = element_line(colour = "grey70", size = 0.2),
          axis.line.x = element_line(color="black", size = 0.2),
          axis.line.y = element_line(color="black", size = 0.2),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "white"))
  return(plot)
}

plot.recenter <- function(recentered_data, recentered_sim_data){
  plot <- ggplot() +
    geom_histogram(data = recentered_data, aes(x = offset, y = ..density..), colour = 'grey80', fill = 'grey80', bins = 50) +
    # geom_histogram(data = model, aes(x = simulated_error, y = ..density.., fill = model_name), bins = 50, alpha = 0.2) +
    stat_density(data = recentered_sim_data, aes(x = offset, color = model), kernel = 'epanechnikov', adjust = 1,
                 position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    facet_grid(~cond) +
    scale_x_continuous(name = 'Recentered Error', breaks = c(-3.14, 0, 3.14), labels = c(expression(-pi), "0", expression(pi))) +
    #ylab("Density") +
    theme(text = element_text(size=20),
          strip.background = element_blank(),
          plot.title = element_text(face = "bold", size = 12),
          axis.ticks = element_line(colour = "grey70", size = 0.2),
          axis.line.x = element_line(color="black", size = 0.2),
          axis.line.y = element_line(color="black", size = 0.2),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "white"),
          legend.key = element_rect(colour = "transparent", fill = "white"),
          legend.position = 'bottom',
          legend.box="vertical",
          legend.justification = "left",
          legend.margin=margin(),)
  return(plot)
}


################################################################################
#           Recentered plots conditions on levels of similarity                # 
################################################################################
plot.temporal.recenter <- function(data, model, model_list, participant){
  data$abs_lag <- abs(data$lag)
  model$abs_lag <- abs(model$lag)
  data <- data[data$abs_lag < 5,]
  model <- model[model$abs_lag < 5,]
  model <- model[model$model %in% model_names[model_list],]
  #If participant is not supplied, plot all the data at a group level
  if (missing(participant)){
    participant <- 'Group'
  } else {
    data = data[data$participant == participant,]
    model = model[model$participant == participant,]
  }
  
  p1 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'unrelated', ], aes(x = offset, y = ..density..), colour = 1, fill = 'grey70', bins = 20) +
    stat_density(data = model[model$cond == 'unrelated', ], aes(x = offset,  color = model), kernel = 'epanechnikov', adjust = 0.7,
                 position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    ylim(0, 0.3) + 
    facet_grid(~abs_lag) +
    scale_x_continuous(name = 'Source Error', breaks = c(-3.14, 0, 3.14), labels = c(expression(-pi), "0", expression(pi))) +
    ylab("Density") +
    theme(text = element_text(size=20),
          strip.background = element_blank(),
          plot.title = element_text(face = "bold", size = 12),
          legend.position = "none",
          axis.ticks = element_line(colour = "grey70", size = 0.2),
          axis.line.x = element_line(color="black", size = 0.2),
          axis.line.y = element_line(color="black", size = 0.2),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "white")) +
    ggtitle(sprintf('%s condition, recentered on lag', 'Unrelated'))
  
  p2 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'semantic', ], aes(x = offset, y = ..density..), colour = 1, fill = 'grey70', bins = 20) +
    geom_density(data = model[model$cond == 'semantic', ], aes(x = offset,  color = model), kernel = 'epanechnikov', adjust = 0.7,
                 position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    ylim(0, 0.3) + 
    facet_grid(~abs_lag) +
    scale_x_continuous(name = 'Source Error', breaks = c(-3.14, 0, 3.14), labels = c(expression(-pi), "0", expression(pi))) +
    ylab("Density") +
    theme(text = element_text(size=20),
          strip.background = element_blank(),
          plot.title = element_text(face = "bold", size = 12),
          legend.position = "none",
          axis.ticks = element_line(colour = "grey70", size = 0.2),
          axis.line.x = element_line(color="black", size = 0.2),
          axis.line.y = element_line(color="black", size = 0.2),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "white")) +
    ggtitle(sprintf('%s condition, recentered on lag', 'Semantic'))
  
  p3 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'orthographic', ], aes(x = offset, y = ..density..), colour = 1, fill = 'grey70', bins = 20) +
    geom_density(data = model[model$cond == 'orthographic', ], aes(x = offset,  color = model), kernel = 'epanechnikov', adjust = 0.7,
                 position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    ylim(0, 0.3) + 
    facet_grid(~abs_lag) +
    scale_x_continuous(name = 'Source Error', breaks = c(-3.14, 0, 3.14), labels = c(expression(-pi), "0", expression(pi))) +
    ylab("Density") +
    theme(text = element_text(size=20),
          strip.background = element_blank(),
          plot.title = element_text(face = "bold", size = 12),
          legend.position = "none",
          axis.ticks = element_line(colour = "grey70", size = 0.2),
          axis.line.x = element_line(color="black", size = 0.2),
          axis.line.y = element_line(color="black", size = 0.2),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "white")) +
    ggtitle(sprintf('%s condition, recentered on lag', 'Orthographic'))
  
  p4 <- ggplot() + 
    geom_histogram(data = data, aes(x = offset, y = ..density..), colour = 1, fill = 'grey70', bins = 20) +
    geom_density(data = model, aes(x = offset,  color = model), kernel = 'epanechnikov', adjust = 0.7,
                 position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    ylim(0, 0.3) + 
    facet_grid(~abs_lag)  +
    scale_x_continuous(name = 'Source Error', breaks = c(-3.14, 0, 3.14), labels = c(expression(-pi), "0", expression(pi))) +
    ylab("Density") +
    theme(text = element_text(size=20),
          strip.background = element_blank(),
          plot.title = element_text(face = "bold", size = 12),
          axis.ticks = element_line(colour = "grey70", size = 0.2),
          axis.line.x = element_line(color="black", size = 0.2),
          axis.line.y = element_line(color="black", size = 0.2),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "white"),
          legend.key = element_rect(colour = "transparent", fill = "white"),
          legend.position = 'bottom',
          legend.box="vertical",
          legend.justification = "left",
          legend.margin=margin(),) +
    ggtitle(sprintf('%s, recentered on lag', 'Overall'))
  
  plot <- ggarrange(p1, p2, p3, p4, ncol = 1, nrow = 4, heights = c(1, 1, 1, 1))
  filename <- sprintf('recenter_temporal_%s.png', participant)
  ggsave(filename, plot = last_plot(), width = 40, height = 40, units = "cm")
}

plot.spatial.recenter <- function(data, model, model_list, participant){
  model <- model[model$model %in% model_names[model_list],]
  #If participant is not supplied, plot all the data at a group level
  if (missing(participant)){
    participant <- 'Group'
  } else {
    data = data[data$participant == participant,]
    model = model[model$participant == participant,]
  }
  
  p1 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'unrelated', ], aes(x = offset, y = ..density..), colour = 1, fill = 'grey70', bins = 20) +
    stat_density(data = model[model$cond == 'unrelated', ], aes(x = offset,  color = model), kernel = 'epanechnikov', adjust = 0.7,
                 position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    ylim(0, 0.5) + 
    facet_grid(~spatial_bin) +
    scale_x_continuous(name = 'Source Error', breaks = c(-3.14, 0, 3.14), labels = c(expression(-pi), "0", expression(pi))) +
    ylab("Density") +
    theme(text = element_text(size=20),
          strip.background = element_blank(),
          plot.title = element_text(face = "bold", size = 12),
          legend.position = "none",
          axis.ticks = element_line(colour = "grey70", size = 0.2),
          axis.line.x = element_line(color="black", size = 0.2),
          axis.line.y = element_line(color="black", size = 0.2),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "white")) +
    ggtitle(sprintf('%s condition, recentered on space', 'Unrelated'))
  
  p2 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'semantic', ], aes(x = offset, y = ..density..), colour = 1, fill = 'grey70', bins = 20) +
    geom_density(data = model[model$cond == 'semantic', ], aes(x = offset,  color = model), kernel = 'epanechnikov', adjust = 0.7,
                 position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    ylim(0, 0.5) + 
    facet_grid(~spatial_bin) +
    scale_x_continuous(name = 'Source Error', breaks = c(-3.14, 0, 3.14), labels = c(expression(-pi), "0", expression(pi))) +
    ylab("Density") +
    theme(text = element_text(size=20),
          strip.background = element_blank(),
          plot.title = element_text(face = "bold", size = 12),
          legend.position = "none",
          axis.ticks = element_line(colour = "grey70", size = 0.2),
          axis.line.x = element_line(color="black", size = 0.2),
          axis.line.y = element_line(color="black", size = 0.2),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "white")) +
    ggtitle(sprintf('%s condition, recentered on space', 'Semantic'))
  
  p3 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'orthographic', ], aes(x = offset, y = ..density..), colour = 1, fill = 'grey70', bins = 20) +
    geom_density(data = model[model$cond == 'orthographic', ], aes(x = offset,  color = model), kernel = 'epanechnikov', adjust = 0.7,
                 position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    ylim(0, 0.5) + 
    facet_grid(~spatial_bin) +
    scale_x_continuous(name = 'Source Error', breaks = c(-3.14, 0, 3.14), labels = c(expression(-pi), "0", expression(pi))) +
    ylab("Density") +
    theme(text = element_text(size=20),
          strip.background = element_blank(),
          plot.title = element_text(face = "bold", size = 12),
          legend.position = "none",
          axis.ticks = element_line(colour = "grey70", size = 0.2),
          axis.line.x = element_line(color="black", size = 0.2),
          axis.line.y = element_line(color="black", size = 0.2),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "white")) +
    ggtitle(sprintf('%s condition, recentered on space', 'Orthographic'))
  
  p4 <- ggplot() + 
    geom_histogram(data = data, aes(x = offset, y = ..density..), colour = 1, fill = 'grey70', bins = 20) +
    geom_density(data = model, aes(x = offset,  color = model), kernel = 'epanechnikov', adjust = 0.7,
                 position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    ylim(0, 0.5) + 
    facet_grid(~spatial_bin)  +
    scale_x_continuous(name = 'Source Error', breaks = c(-3.14, 0, 3.14), labels = c(expression(-pi), "0", expression(pi))) +
    ylab("Density") +
    theme(text = element_text(size=20),
          strip.background = element_blank(),
          plot.title = element_text(face = "bold", size = 12),
          axis.ticks = element_line(colour = "grey70", size = 0.2),
          axis.line.x = element_line(color="black", size = 0.2),
          axis.line.y = element_line(color="black", size = 0.2),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "white"),
          legend.key = element_rect(colour = "transparent", fill = "white"),
          legend.position = 'bottom',
          legend.box="vertical",
          legend.justification = "left",
          legend.margin=margin(),) +
    ggtitle(sprintf('%s, recentered on space', 'Overall'))
  
  plot <- ggarrange(p1, p2, p3, p4, ncol = 1, nrow = 4, heights = c(1, 1, 1, 1))
  filename <- sprintf('recenter_spatial_%s.png', participant)
  ggsave(filename, plot = last_plot(), width = 40, height = 40, units = "cm")
}


plot.orthographic.recenter <- function(data, model, model_list, participant){
  data <- data[data$orthographic < 5,]
  model <- model[model$orthographic < 5,]
  model <- model[model$model %in% model_names[model_list],]
  #If participant is not supplied, plot all the data at a group level
  if (missing(participant)){
    participant <- 'Group'
  } else {
    data = data[data$participant == participant,]
    model = model[model$participant == participant,]
  }
  p1 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'orthographic', ], aes(x = offset, y = ..density..), colour = 1, fill = 'grey70', bins = 20) +
    stat_density(data = model[model$cond == 'orthographic', ], aes(x = offset,  color = model), kernel = 'epanechnikov', adjust = 0.7,
                 position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    ylim(0, 0.5) + 
    facet_grid(~orthographic) +
    scale_x_continuous(name = 'Source Error', breaks = c(-3.14, 0, 3.14), labels = c(expression(-pi), "0", expression(pi))) +
    ylab("Density") +
    theme(text = element_text(size=20),
          strip.background = element_blank(),
          plot.title = element_text(face = "bold", size = 12),
          legend.position = "none",
          axis.ticks = element_line(colour = "grey70", size = 0.2),
          axis.line.x = element_line(color="black", size = 0.2),
          axis.line.y = element_line(color="black", size = 0.2),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "white")) +
    ggtitle(sprintf('%s Condition, Recentered on orthographic', 'orth'))
  
  p2 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'unrelated', ], aes(x = offset, y = ..density..), colour = 1, fill = 'grey70', bins = 20) +
    geom_density(data = model[model$cond == 'unrelated', ], aes(x = offset,  color = model), kernel = 'epanechnikov', adjust = 0.7,
                 position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    ylim(0, 0.3) + 
    facet_grid(~orthographic) +
    scale_x_continuous(name = 'Source Error', breaks = c(-3.14, 0, 3.14), labels = c(expression(-pi), "0", expression(pi))) +
    ylab("Density") +
    theme(text = element_text(size=20),
          strip.background = element_blank(),
          plot.title = element_text(face = "bold", size = 12),
          legend.position = "none",
          axis.ticks = element_line(colour = "grey70", size = 0.2),
          axis.line.x = element_line(color="black", size = 0.2),
          axis.line.y = element_line(color="black", size = 0.2),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "white")) +
    ggtitle(sprintf('%s Condition, Recentered on orthographic', 'unrelated'))
  
  p3 <- ggplot() + 
    geom_histogram(data = data, aes(x = offset, y = ..density..), colour = 1, fill = 'grey70', bins = 20) +
    geom_density(data = model, aes(x = offset,  color = model), kernel = 'epanechnikov', adjust = 0.7,
                 position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    ylim(0, 0.3) + 
    facet_grid(~orthographic)  +
    scale_x_continuous(name = 'Source Error', breaks = c(-3.14, 0, 3.14), labels = c(expression(-pi), "0", expression(pi))) +
    ylab("Density") +
    theme(text = element_text(size=20),
          strip.background = element_blank(),
          plot.title = element_text(face = "bold", size = 12),
          axis.ticks = element_line(colour = "grey70", size = 0.2),
          axis.line.x = element_line(color="black", size = 0.2),
          axis.line.y = element_line(color="black", size = 0.2),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "white"),
          legend.key = element_rect(colour = "transparent", fill = "white"),
          legend.position = 'bottom',
          legend.box="vertical",
          legend.justification = "left",
          legend.margin=margin(),) +
    ggtitle(sprintf('%s Condition, Recentered on orthographic', 'overall'))
  
  plot <- ggarrange(p1, p2, p3, ncol = 1, nrow = 3, heights = c(1, 1, 1))
  filename <- sprintf('recenter_orthographic_%s.png', participant)
  ggsave(filename, plot = last_plot(), width = 40, height = 30, units = "cm")
}

plot.semantic.recenter <- function(data, model, model_list, participant){
  model <- model[model$model %in% model_names[model_list],]
  #If participant is not supplied, plot all the data at a group level
  if (missing(participant)){
    participant <- 'Group'
  } else {
    data = data[data$participant == participant,]
    model = model[model$participant == participant,]
  }
  p1 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'semantic', ], aes(x = offset, y = ..density..), colour = 1, fill = 'grey70', bins = 20) +
    stat_density(data = model[model$cond == 'semantic', ], aes(x = offset,  color = model), kernel = 'epanechnikov', adjust = 0.7,
                 position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    ylim(0, 0.3) + 
    facet_grid(~semantic_bin) +
    scale_x_continuous(name = 'Source Error', breaks = c(-3.14, 0, 3.14), labels = c(expression(-pi), "0", expression(pi))) +
    ylab("Density") +
    theme(text = element_text(size=20),
          strip.background = element_blank(),
          plot.title = element_text(face = "bold", size = 12),
          legend.position = "none",
          axis.ticks = element_line(colour = "grey70", size = 0.2),
          axis.line.x = element_line(color="black", size = 0.2),
          axis.line.y = element_line(color="black", size = 0.2),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "white")) +
    ggtitle(sprintf('%s Condition, Recentered on semantic', 'semantic'))
  
  p2 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'unrelated', ], aes(x = offset, y = ..density..), colour = 1, fill = 'grey70', bins = 20) +
    geom_density(data = model[model$cond == 'unrelated', ], aes(x = offset,  color = model), kernel = 'epanechnikov', adjust = 0.7,
                 position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    ylim(0, 0.3) + 
    facet_grid(~semantic_bin) +
    scale_x_continuous(name = 'Source Error', breaks = c(-3.14, 0, 3.14), labels = c(expression(-pi), "0", expression(pi))) +
    ylab("Density") +
    theme(text = element_text(size=20),
          strip.background = element_blank(),
          plot.title = element_text(face = "bold", size = 12),
          legend.position = "none",
          axis.ticks = element_line(colour = "grey70", size = 0.2),
          axis.line.x = element_line(color="black", size = 0.2),
          axis.line.y = element_line(color="black", size = 0.2),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "white")) +
    ggtitle(sprintf('%s Condition, Recentered on semantic', 'semantic'))
  
  p3 <- ggplot() + 
    geom_histogram(data = data, aes(x = offset, y = ..density..), colour = 1, fill = 'grey70', bins = 20) +
    geom_density(data = model, aes(x = offset,  color = model), kernel = 'epanechnikov', adjust = 0.7,
                 position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    ylim(0, 0.3) + 
    facet_grid(~semantic_bin)  +
    scale_x_continuous(name = 'Source Error', breaks = c(-3.14, 0, 3.14), labels = c(expression(-pi), "0", expression(pi))) +
    ylab("Density") +
    theme(text = element_text(size=20),
          strip.background = element_blank(),
          plot.title = element_text(face = "bold", size = 12),
          axis.ticks = element_line(colour = "grey70", size = 0.2),
          axis.line.x = element_line(color="black", size = 0.2),
          axis.line.y = element_line(color="black", size = 0.2),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "white"),
          legend.key = element_rect(colour = "transparent", fill = "white"),
          legend.position = 'bottom',
          legend.box="vertical",
          legend.justification = "left",
          legend.margin=margin(),) +
    ggtitle(sprintf('%s Condition, Recentered on semantic', 'overall'))
  
  plot <- ggarrange(p1, p2, p3, ncol = 1, nrow = 3, heights = c(1, 1, 1))
  filename <- sprintf('recenter_semantic_%s.png', participant)
  ggsave(filename, plot = last_plot(), width = 40, height = 30, units = "cm")
}