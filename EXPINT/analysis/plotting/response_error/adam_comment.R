# Need two plots to respond to Adam's suggestions, putting them here in a separate file
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

sim_data <- sim_data[!(sim_data$model_name %in% c('fourfactor_gamma', 'spatiotemporal_ortho_weight')),]

recentered_sim_data <- recentered_sim_data[!(recentered_sim_data$model %in% c('fourfactor_gamma', 'spatiotemporal_ortho_weight')),]

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


## Plotting

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
  
  plot <- plot.response.error(data, sim_data, model_list, p)
  # recentered <- plot.recenter(recentered_data, recentered_sim_data, model_list)
  # 
  # plot <- ggarrange(response_error,
  #                   recentered,
  #                   ncol = 1, nrow = 2, heights = c(1, 1))
  # plot <- annotate_figure(plot, fig.lab = sprintf('P%s', as.character(p)),
  #                         fig.lab.pos = "top.left")
  return(plot)
}

plot.response.error <- function(data, model, model_list, participant){
  plot <- ggplot() +
    geom_histogram(data = data, aes(x = source_error, y = ..density..), colour = 'grey80', fill = 'grey80', boundary = 0, binwidth = 1/5) +
    stat_density(data = model, aes(x = simulated_error,
                                   color = factor(model_name, levels = c('Spatiotemporal', 'Four Factor','Spatiotemporal-Orthographic',
                                                                         'Four Factor Gamma', 'Spatiotemporal-Orthographic Gamma',
                                                                         'Semantic Beta')),
                                   lty = factor(model_name, levels = c('Spatiotemporal', 'Four Factor','Spatiotemporal-Orthographic',
                                                                       'Four Factor Gamma', 'Spatiotemporal-Orthographic Gamma',
                                                                       'Semantic Beta'))),
                 kernel = 'epanechnikov', adjust = 1,
                 position="identity",geom="line", linewidth = 0.6, bounds = c(-3.14, 3.14)) +
    facet_grid(~condition) +
    scale_x_continuous(name = 'Source Error', breaks = c(-3.14, 0, 3.14), labels = c(expression(-pi), "0", expression(pi))) +
    #scale_y_continuous(name = 'Density', breaks = c(0, 0.5, 1), labels = (c('0', '0.5', '1'))) + 
    scale_color_manual(values = colours[c(model_list)]) +
    scale_linetype_manual(values = line.types[c(model_list)]) +
    ylab("Density") +
    theme(text = element_text(size=14),
          strip.background = element_blank(),
          strip.text.x = element_blank(),
          plot.title = element_text(face = "bold", size = 11),
          legend.position = "none",
          legend.title = element_blank(),
          axis.ticks = element_line(colour = "grey70", size = 0.6),
          axis.line.x = element_line(color="black", size = 0.2),
          axis.line.y = element_line(color="black", size = 0.2),
          #axis.text.x = element_blank(),
          axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "white")) +
    ggtitle(sprintf('P%s', as.character(participant)))
  return(plot)
}

plot.all.participant.cond <- function(model_list){
  p1 <- plot.participant(1, model_list)
  p2 <- plot.participant(2, model_list)
  p3 <- plot.participant(3, model_list)
  p4 <- plot.participant(4, model_list)
  p5 <- plot.participant(5, model_list)
  p6 <- plot.participant(6, model_list)
  p7 <- plot.participant(7, model_list)
  p8 <- plot.participant(8, model_list)
  p9 <- plot.participant(9, model_list)
  p10 <- plot.participant(10, model_list)
  plot <- ggarrange(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10,
                    ncol = 2, nrow = 5, heights = c(1, 1))
  
  return(plot)
}

plot <- plot.all.participant.cond(c(1:4))
ggsave('supp_fig1a.png', plot = plot, width = 7.5, height = 8, units = "in")