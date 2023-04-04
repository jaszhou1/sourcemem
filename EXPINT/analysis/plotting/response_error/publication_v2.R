# Trimmed down script to generate the model fitting plots for manuscript
library(ggplot2)
library(ggpubr)
library(stringr)
library(paletteer)
library(dplyr)

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

# Some data massaging to make the plots look the way I want (in terms of ordering of panels etc.)
sim_data$model_name <- recode(sim_data$model_name, spatiotemporal = 'Spatiotemporal', four_factor = 'Four Factor', 
                              three_factor = 'Spatiotemporal-Orthographic', fourfactor_gamma = 'Four Factor Gamma', 
                              spatiotemporal_ortho_gamma = 'Spatiotemporal-Orthographic Gamma', semantic_beta = 'Semantic Beta')
recentered_sim_data$model <- recode(recentered_sim_data$model, spatiotemporal = 'Spatiotemporal', four_factor = 'Four Factor', 
                                    three_factor = 'Spatiotemporal-Orthographic', fourfactor_gamma = 'Four Factor Gamma', 
                                    spatiotemporal_ortho_gamma = 'Spatiotemporal-Orthographic Gamma', semantic_beta = 'Semantic Beta')
# model_names <- factor(unique(sim_data$model_name), levels = c('spatiotemporal', 'four_factor', 'three_factor', 'fourfactor_gamma', 'spatiotemporal_ortho_gamma', 'spatiotemporal_ortho_weight', 'semantic_beta'))
model_names <- factor(unique(sim_data$model_name), levels = c('Spatiotemporal', 'Four Factor','Spatiotemporal-Orthographic',
                                                              'Four Factor Gamma', 'Spatiotemporal-Orthographic Gamma', 'Semantic Beta'))

data$condition <- factor(str_to_title(data$condition), levels = c('Unrelated', 'Semantic', 'Orthographic'))
sim_data$condition <- factor(str_to_title(sim_data$condition), levels = c('Unrelated', 'Semantic', 'Orthographic'))
recentered_data$cond <- factor(str_to_title(recentered_data$cond), levels = c('Unrelated', 'Semantic', 'Orthographic'))
recentered_sim_data$cond <- factor(str_to_title(recentered_sim_data$cond), levels = c('Unrelated', 'Semantic', 'Orthographic'))

# Manually specify a colour palette (useful for picking the 2nd, and 4th, say, if i dont want to plot the 1st and 3rd model)
#           spatiotemp   4f,        STO,       STOG,       SEMB
colours <- c('#e6194B', '#f032e6', '#4363d8', '#f58231', '#42d4f4')
line.types <- c('solid', 'dotted', 'longdash', 'twodash', 'dotted')

# Set output folder
setwd("~/git/sourcemem/EXPINT/analysis/plotting/output/resp_error")


############################### GROUP COND PLOT ###################################

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
  
  response_error <- plot.response.error(data, sim_data, model_list)
  recentered <- plot.recenter(recentered_data, recentered_sim_data, model_list)
  
  plot <- ggarrange(response_error,
                    recentered,
                    ncol = 1, nrow = 2, heights = c(1, 1))
  # plot <- annotate_figure(plot, left = text_grob(sprintf('P%s', as.character(p)), 
  #                                       color = "black", face = "bold", size = 14))
  return(plot)
}

plot.response.error <- function(data, model, model_list){
  plot <- ggplot() +
    geom_histogram(data = data, aes(x = source_error, y = ..density..), colour = 'grey80', fill = 'grey80', boundary = 0, binwidth = 1/5) +
    # geom_histogram(data = model, aes(x = simulated_error, y = ..density.., fill = model_name), bins = 50, alpha = 0.2) +
    stat_density(data = model, aes(x = simulated_error, 
                                   color = factor(model_name, levels = c('Spatiotemporal', 'Four Factor','Spatiotemporal-Orthographic',
                                                                         'Four Factor Gamma', 'Spatiotemporal-Orthographic Gamma', 
                                                                         'Semantic Beta')), 
                                   lty = factor(model_name, levels = c('Spatiotemporal', 'Four Factor','Spatiotemporal-Orthographic',
                                                                       'Four Factor Gamma', 'Spatiotemporal-Orthographic Gamma', 
                                                                       'Semantic Beta'))), 
                 kernel = 'epanechnikov', adjust = 1,
                 position="identity",geom="line", linewidth = 1, bounds = c(-3.14, 3.14)) +
    facet_grid(~condition) +
    scale_x_continuous(name = 'Source Error', breaks = c(-3.14, 0, 3.14), labels = c(expression(-pi), "0", expression(pi))) +
    scale_y_continuous(name = 'Density', breaks = c(0, 0.75), labels = (c('0', '0.75'))) + 
    scale_color_manual(values = colours[c(model_list)]) +
    scale_linetype_manual(values = line.types[c(model_list)]) +
    ylab("Density") +
    theme(text = element_text(size=14),
          strip.background = element_blank(),
          plot.title = element_text(face = "bold", size = 11),
          legend.position = "none",
          legend.title = element_blank(),
          axis.ticks = element_line(colour = "grey70", size = 0.2),
          axis.line.x = element_line(color="black", size = 0.2),
          axis.line.y = element_line(color="black", size = 0.2),
          axis.text.x = element_blank(),
          axis.title.x = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "white"))
  return(plot)
}

plot.recenter <- function(recentered_data, recentered_sim_data, model_list){
  plot <- ggplot() +
    geom_histogram(data = recentered_data, aes(x = offset, y = ..density..), colour = 'grey80', fill = 'grey80', boundary = 0, binwidth = 1/5) +
    # geom_histogram(data = model, aes(x = simulated_error, y = ..density.., fill = model_name), bins = 50, alpha = 0.2) +
    stat_density(data = recentered_sim_data, aes(x = offset, 
                                                 color = factor(model, levels = c('Spatiotemporal', 'Four Factor','Spatiotemporal-Orthographic',
                                                                                  'Four Factor Gamma', 'Spatiotemporal-Orthographic Gamma', 
                                                                                  'Semantic Beta')), 
                                                 lty = factor(model, levels = c('Spatiotemporal', 'Four Factor','Spatiotemporal-Orthographic',
                                                                                'Four Factor Gamma', 'Spatiotemporal-Orthographic Gamma', 
                                                                                'Semantic Beta'))), 
                 kernel = 'epanechnikov', adjust = 1,
                 position="identity",geom="line", linewidth = 1, bounds = c(-3.14, 3.14)) +
    facet_grid(~cond) +
    scale_x_continuous(name = 'Source Error', breaks = c(-3.14, 0, 3.14), labels = c(expression(-pi), "0", expression(pi))) +
    scale_y_continuous(name = 'Density', breaks = c(0, 0.2), labels = (c('0', '0.20'))) + 
    scale_color_manual(values = colours[c(model_list)]) +
    scale_linetype_manual(values = line.types[c(model_list)]) +
    ylab("Density") +
    theme(text = element_text(size=14),
          strip.background = element_blank(),
          strip.text = element_blank(),
          plot.title = element_text(face = "bold", size = 11),
          axis.ticks = element_line(colour = "grey70", size = 0.2),
          axis.line.x = element_line(color="black", size = 0.2),
          axis.line.y = element_line(color="black", size = 0.2),
          axis.text.x = element_text(size = 14),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "white"),
          legend.title = element_blank(),
          legend.key = element_rect(colour = "transparent", fill = "white"),
          legend.position = 'bottom',
          legend.box="vertical",
          legend.justification = "left",
          legend.margin=margin(),)
  return(plot)
}

# this_plot <- plot.participant(model_list = c(1,3))
# filename <- 'fig4.png'
# ggsave(filename, plot = this_plot, width = 20, height = 15, units = "cm")

########################################################################################################
recenter_semantic <- function(recentered_data, recentered_sim_data, model_list){
  recentered_sim_data <- recentered_sim_data[recentered_sim_data$model %in% model_names[model_list],]
  plot <- ggplot() + 
    geom_histogram(data = recentered_data, aes(x = offset, y = ..density..), colour = 'grey80', fill = 'grey80', boundary = 0, binwidth = 1/4) +
    stat_density(data = recentered_sim_data, aes(x = offset, 
                                                 color = factor(model, levels = c('Spatiotemporal', 'Four Factor','Spatiotemporal-Orthographic',
                                                                                  'Four Factor Gamma', 'Spatiotemporal-Orthographic Gamma', 
                                                                                  'Semantic Beta')), 
                                                 lty = factor(model, levels = c('Spatiotemporal', 'Four Factor','Spatiotemporal-Orthographic',
                                                                                'Four Factor Gamma', 'Spatiotemporal-Orthographic Gamma', 
                                                                                'Semantic Beta'))), 
                 kernel = 'epanechnikov', adjust = 0.6,
                 position="identity",geom="line", linewidth = 1.1, bounds = c(-3.14, 3.14)) +
    facet_grid(~semantic_bin)  +
    scale_x_continuous(name = 'Source Error', breaks = c(-3.14, 0, 3.14), labels = c(expression(-pi), "0", expression(pi))) +
    scale_y_continuous(name = 'Density', limits = c(0, 0.3), breaks = c(0, 0.3), labels = (c('0', '0.3'))) + 
    scale_color_manual(values = colours[c(model_list)]) +
    scale_linetype_manual(values = line.types[c(model_list)]) +
    ylab("Density") +
    theme(text = element_text(size=14),
          strip.background = element_blank(),
          strip.text = element_blank(),
          plot.title = element_text(face = "bold", size = 11),
          axis.ticks = element_line(colour = "grey70", size = 0.2),
          axis.line.x = element_line(color="black", size = 0.2),
          axis.line.y = element_line(color="black", size = 0.2),
          axis.text.x = element_text(size = 14),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "white"),
          legend.position = "none",
          axis.title.x = element_blank()) +
          # legend.title = element_blank(),
          # legend.key = element_rect(colour = "transparent", fill = "white"),
          # legend.position = 'bottom',
          # legend.box="vertical",
          # legend.justification = "left",
          # legend.margin=margin()) +
    ggtitle('Recentered Error Conditioned on Semantics')
  return(plot)
}

recenter_orthographic <- function(recentered_data, recentered_sim_data, model_list){
  recentered_sim_data <- recentered_sim_data[recentered_sim_data$model %in% model_names[model_list],]
  recentered_data <- recentered_data[recentered_data$orthographic < 5,]
  recentered_sim_data <- recentered_sim_data[recentered_sim_data$orthographic < 5,]
  plot <- ggplot() + 
    geom_histogram(data = recentered_data, aes(x = offset, y = ..density..), colour = 'grey80', fill = 'grey80', boundary = 0, binwidth = 1/4) +
    stat_density(data = recentered_sim_data, aes(x = offset, 
                                                 color = factor(model, levels = c('Spatiotemporal', 'Four Factor','Spatiotemporal-Orthographic',
                                                                                  'Four Factor Gamma', 'Spatiotemporal-Orthographic Gamma', 
                                                                                  'Semantic Beta')), 
                                                 lty = factor(model, levels = c('Spatiotemporal', 'Four Factor','Spatiotemporal-Orthographic',
                                                                                'Four Factor Gamma', 'Spatiotemporal-Orthographic Gamma', 
                                                                                'Semantic Beta'))), 
                 kernel = 'epanechnikov', adjust = 0.6,
                 position="identity",geom="line", linewidth = 1.1, bounds = c(-3.14, 3.14)) +
    facet_grid(~orthographic)  +
    scale_x_continuous(name = 'Source Error', breaks = c(-3.14, 0, 3.14), labels = c(expression(-pi), "0", expression(pi))) +
    scale_y_continuous(name = 'Density', limits = c(0, 0.3), breaks = c(0, 0.3), labels = (c('0', '0.3'))) + 
    scale_color_manual(values = colours[c(model_list)]) +
    scale_linetype_manual(values = line.types[c(model_list)]) +
    ylab("Density") +
    theme(text = element_text(size=14),
          strip.background = element_blank(),
          strip.text = element_blank(),
          plot.title = element_text(face = "bold", size = 11),
          axis.ticks = element_line(colour = "grey70", size = 0.2),
          axis.line.x = element_line(color="black", size = 0.2),
          axis.line.y = element_line(color="black", size = 0.2),
          axis.text.x = element_text(size = 14),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "white"),
          legend.title = element_blank(),
          legend.key = element_rect(colour = "transparent", fill = "white"),
          legend.position = 'bottom',
          legend.box="vertical",
          legend.justification = "left",
          legend.margin=margin(),) +
    ggtitle('Recentered Error Conditioned on Orthography')
  return(plot)
}

plot.recenter <- function(model_list){
 p1 <- recenter_semantic(recentered_data, recentered_sim_data, model_list)
 p2 <- recenter_orthographic(recentered_data, recentered_sim_data, model_list)
 this.plot <- ggarrange(p1, p2, ncol = 1, nrow = 2, heights = c(1, 1.2))
 return(this.plot)
}

this_plot <- plot.recenter(c(2,3))
filename <- 'fig5.png'
ggsave(filename, plot = this_plot, width = 20, height = 15, units = "cm")

########################################################################################################
# Super-participant plot

plot.super.error <- function(data, model, model_list, superparticipant){
  model <- model[model$model %in% model_names[model_list],]
  plot <- ggplot() +
    geom_histogram(data = data, aes(x = source_error, y = ..density..), colour = 'grey80', fill = 'grey80', boundary = 0, binwidth = 1/7) +
    # geom_histogram(data = model, aes(x = simulated_error, y = ..density.., fill = model_name), bins = 50, alpha = 0.2) +
    stat_density(data = model, aes(x = simulated_error, 
                                   color = factor(model_name, levels = c('Spatiotemporal', 'Four Factor','Spatiotemporal-Orthographic',
                                                                         'Four Factor Gamma', 'Spatiotemporal-Orthographic Gamma', 
                                                                         'Semantic Beta')), 
                                   lty = factor(model_name, levels = c('Spatiotemporal', 'Four Factor','Spatiotemporal-Orthographic',
                                                                       'Four Factor Gamma', 'Spatiotemporal-Orthographic Gamma', 
                                                                       'Semantic Beta'))), 
                 kernel = 'epanechnikov', adjust = 1,
                 position="identity",geom="line", linewidth = 1, bounds = c(-3.14, 3.14)) +
    facet_grid(~condition) +
    scale_x_continuous(name = 'Source Error', breaks = c(-3.14, 0, 3.14), labels = c(expression(-pi), "0", expression(pi))) +
    scale_y_continuous(name = 'Density', limits = c(0, 1.2), breaks = c(0, 1.2), labels = (c('0', '1.2'))) + 
    scale_color_manual(values = colours[c(model_list)]) +
    scale_linetype_manual(values = line.types[c(model_list)]) +
    ylab("Density") +
    theme(text = element_text(size=14),
          strip.background = element_blank(),
          plot.title = element_text(face = "bold", size = 11),
          axis.ticks = element_line(colour = "grey70", size = 0.2),
          axis.line.x = element_line(color="black", size = 0.2),
          axis.line.y = element_line(color="black", size = 0.2),
          axis.text.x = element_text(size = 14),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "white"),
          legend.title = element_blank(),
          legend.key = element_rect(colour = "transparent", fill = "white"),
          legend.position = 'bottom',
          legend.box="vertical",
          legend.justification = "left",
          legend.margin=margin(),) +
    ggtitle(superparticipant)
  return(plot)
}

plot.superparticipants <- function(model_list){
  sp1_data <- data[data$participant %in% c(1, 2, 5, 6),] 
  sp1_model <- sim_data[sim_data$participant %in% c(1, 2, 4, 5, 6),] 
  
  sp2_data <- data[data$participant %in% c(3, 4, 9),] 
  sp2_model <- sim_data[sim_data$participant %in% c(4, 3, 9),]
  
  sp3_data <- data[data$participant %in% c(7, 8, 10),] 
  sp3_model <- sim_data[sim_data$participant %in% c(7, 8, 10),] 
  
  p1 <- plot.super.error(sp1_data, sp1_model, model_list, 'Semantics ≈ Unrelated (1, 2, 5, 6)')
  p2 <- plot.super.error(sp2_data, sp2_model, model_list, 'Semantics > Unrelated (3, 4, 9)')
  p3 <- plot.super.error(sp3_data, sp3_model, model_list, 'Semantics < Unrelated (7, 8, 10)')
  
  plot <- ggarrange(p1, p2, p3, ncol = 1, nrow = 3, heights = c(1, 1, 1), common.legend = TRUE, legend = 'bottom')
  return(plot)
}

super_plot <- plot.superparticipants(c(3,4))
filename <- 'fig6.png'
ggsave(filename, plot = super_plot, width = 20, height = 22, units = "cm")
