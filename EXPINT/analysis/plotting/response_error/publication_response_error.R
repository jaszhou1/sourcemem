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
load("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/fitted_models/2023-03-08_fits.RData")
# Load simulated datasets
load("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/fitted_models/2023-03-08_sim_data.RData")
load("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/fitted_models/2023-03-08_simulated_recenter.RData")

participants <- unique(data$participant)
conds <- unique(data$condition)
models <- unique(sim_data$model_name)

# Set output folder
setwd("~/git/sourcemem/EXPINT/analysis/plotting/output/resp_error")
############################# PLOTTING #########################################
plot.all <- function(model_list){
  for(i in unique(data$participant)){
    this_plot <- plot.participant(i, model_list)
    filename <- sprintf('%s_resp_plot.png', i)
    ggsave(filename, plot = this_plot, width = 40, height = 35, units = "cm")
  }
  this_plot <- plot.participant(model_list = model_list)
  filename <- 'group_plot.png'
  ggsave(filename, plot = this_plot, width = 40, height = 35, units = "cm")
}

############################### LEVEL 2 ########################################

plot.participant <- function(p, model_list){
  models <- models[models$model %in% model_names[model_list],]
  #recentered_sim_data <- recentered_sim_data[recentered_sim_data$model %in% model_names[model_list],]
  if(missing(p)){
    p <- 'Group'
  } else{
    data <- data[data$participant == p,]
    recentered_data <- recentered_data[recentered_data$participant == p,]
    models <- models[models$participant == p,]
    recentered_sim_data <- recentered_sim_data[recentered_sim_data$participant == p,]
  }
  
  response_error <- plot.response.error(data, sim_data)
  recentered <- plot.recenter(recentered_data, recentered_sim_data)
  
  plot <- ggarrange(response_error,
                    recentered,
                    ncol = 1, nrow = 2, heights = c(1, 1))
  annotate_figure(plot, top = text_grob(as.character(p), 
                                        color = "red", face = "bold", size = 14))
  return(plot)
}

################################## LEVEL 3 #####################################
plot.response.error <- function(data, model){
  plot <- ggplot() +
    geom_histogram(data = data, aes(x = source_error, y = ..density..), colour = 1, fill = 'grey70', bins = 50) +
    # geom_histogram(data = model, aes(x = simulated_error, y = ..density.., fill = model_name), bins = 50, alpha = 0.2) +
    stat_density(data = model, aes(x = simulated_error, color = model_name), kernel = 'epanechnikov', adjust = 1,
                 position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    facet_grid(~condition) +
    xlab("Source Error") + ylab("Density") +
    theme(strip.text.x = element_text(size = 12),
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
    geom_histogram(data = recentered_data, aes(x = offset, y = ..density..), colour = 1, fill = 'grey70', bins = 50) +
    # geom_histogram(data = model, aes(x = simulated_error, y = ..density.., fill = model_name), bins = 50, alpha = 0.2) +
    stat_density(data = recentered_sim_data, aes(x = offset, color = model), kernel = 'epanechnikov', adjust = 1,
                 position="identity",geom="line", linewidth = 1.2, bounds = c(-3.14, 3.14)) +
    facet_grid(~cond) +
    xlab("Source Error") + ylab("Density") +
    theme(strip.text.x = element_text(size = 12),
          strip.background = element_blank(),
          plot.title = element_text(face = "bold", size = 12),
          axis.ticks = element_line(colour = "grey70", size = 0.2),
          axis.line.x = element_line(color="black", size = 0.2),
          axis.line.y = element_line(color="black", size = 0.2),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "white"),
          legend.key = element_rect(colour = "transparent", fill = "white"),
          legend.text=element_text(size= 14),
          legend.position = 'bottom',
          legend.box="vertical",
          legend.justification = "left",
          legend.margin=margin(),)
  return(plot)
}



