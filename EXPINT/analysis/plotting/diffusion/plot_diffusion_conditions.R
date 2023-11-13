# plot_diffusion_conditions
library(stringr)
library(ggplot2)
library(ggpubr)
library(dplyr)
# Produce a 4x3 panel plot that shows a few facets of the data for one participant (or group)
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

# Load in models
spatiotemp <- read.csv("~/git/sourcemem/EXPINT/analysis/plotting/diffusion/sim_spatiotemp.csv")
fourfactor <- read.csv("~/git/sourcemem/EXPINT/analysis/plotting/diffusion/sim_fourfactor.csv")
sto <- read.csv("~/git/sourcemem/EXPINT/analysis/plotting/diffusion/sim_spatiotemp_ortho.csv")
sto_gamma <- read.csv("~/git/sourcemem/EXPINT/analysis/plotting/diffusion/sim_sto_gamma.csv")
sto_weight <- read.csv("~/git/sourcemem/EXPINT/analysis/plotting/diffusion/sim_sto_weight.csv")
sto_criterion <- read.csv("~/git/sourcemem/EXPINT/analysis/plotting/diffusion/sim_sto_criterion.csv")

spatiotemp[,50] <- 'Spatiotemporal'
fourfactor[,50] <- 'Four Factor'
sto[,50] <- 'Spatiotemporal-Orthographic'
sto_gamma[,50] <- 'Spatiotemporal-Orthographic Gamma'
sto_weight[,50] <- 'Spatiotemporal-Orthographic Weight'
sto_criterion[,50] <- 'Spatiotemporal-Orthographic Criterion'


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

colnames(spatiotemp) <- col.names
colnames(fourfactor) <- col.names
colnames(sto) <- col.names
colnames(sto_gamma) <- col.names
colnames(sto_weight) <- col.names
colnames(sto_criterion) <- col.names

models <- rbind(spatiotemp, fourfactor, sto, sto_gamma, sto_weight, sto_criterion)
models[,50] <- factor(models[,50], levels = c('Spatiotemporal', 'Four Factor',
                                              'Spatiotemporal-Orthographic',
                                              'Spatiotemporal-Orthographic Gamma',
                                              'Spatiotemporal-Orthographic Weight',
                                              'Spatiotemporal-Orthographic Criterion'))

models$condition[models$cond==1] <- "Unrelated"
models$condition[models$cond==2] <- "Orthographic"
models$condition[models$cond==3] <- "Semantic"

model_names <- unique(models$model)
# Convert the column to a factor
models$condition <- factor(models$condition, levels = c('Unrelated', 'Semantic', 'Orthographic'))
data$condition <- factor(str_to_title(data$condition), levels = c('Unrelated', 'Semantic', 'Orthographic'))
# Plotting
setwd("~/git/sourcemem/EXPINT/analysis/plotting/output/diffusion")

colours <- c('#e6194B', '#f032e6', '#4363d8', '#f58231', '#42d4f4', '#e6194B')
line.types <- c('solid', 'dotted', 'longdash', 'twodash', 'dotted', 'dotted')

plot.all <- function(model_list){
  for(i in unique(data$participant)){
    this_plot <- plot.participant(i, model_list)
    filename <- sprintf('%s_diffusion_plot.png', i)
    ggsave(filename, plot = this_plot, width = 40, height = 30, units = "cm")
  }
  this_plot <- plot.participant(model_list = model_list)
  filename <- 'group_diffusion_plot.png'
  ggsave(filename, plot = this_plot, width = 40, height = 30, units = "cm")
}

############################### LEVEL 2 ########################################

plot.participant <- function(p, model_list){
  models <- models[models$model %in% model_names[model_list],]
  #recentered_sim_data <- recentered_sim_data[recentered_sim_data$model %in% model_names[model_list],]
  if(missing(p)){
    p <- 'Group'
  } else{
    data <- data[data$participant == p,]
    #recentered_data <- recentered_data[recentered_data$participant == p,]
    models <- models[models$participant == p,]
    #recentered_sim_data <- recentered_sim_data[recentered_sim_data$participant == p,]
  }
  
  response_error <- plot.response.error(data, models, model_list)
  response_times <- plot.RT(data, models, model_list)
  #qq <- plot.qq(data, models, model_list)
  #recentered_error <- plot.condition.recenter(recentered_data, recentered_sim_data)
  plot <- ggarrange(response_error,
                    NULL,
                    response_times,
                    #recentered_error,
                    ncol = 1, nrow = 3, heights = c(1, 0.1, 1))
  
  # Plot 1 shows the response error and recentered error split by experimental condition
  # plot <- ggarrange(response_error,
  #                   NULL,
  #                   response_times,
  #                   NULL,
  #                   qq,
  #                   #recentered_error, 
  #                   ncol = 1, nrow = 5, heights = c(1, 0.1, 1, 0.1, 2))
  # annotate_figure(plot, top = text_grob(as.character(p), 
  #                                       color = "red", face = "bold", size = 14))
  return(plot)
}

################################## LEVEL 3 #####################################
plot.response.error <- function(data, model, model_list){
  plot <- ggplot() +
    geom_histogram(data = data, aes(x = source_error, y = ..density..), colour = 'grey80', fill = 'grey80', boundary = 0, binwidth = 1/5) +
    # geom_histogram(data = model, aes(x = simulated_error, y = ..density.., fill = model_name), bins = 50, alpha = 0.2) +
    stat_density(data = model, aes(x = error, 
                                   color = factor(model, levels = c('Spatiotemporal', 'Four Factor',
                                                                         'Spatiotemporal-Orthographic',
                                                                         'Spatiotemporal-Orthographic Gamma',
                                                                         'Spatiotemporal-Orthographic Weight',
                                                                         'Spatiotemporal-Orthographic Criterion'
                                                                         )), 
                                   lty = factor(model, levels = c('Spatiotemporal', 'Four Factor',
                                                                       'Spatiotemporal-Orthographic',
                                                                       'Spatiotemporal-Orthographic Gamma',
                                                                       'Spatiotemporal-Orthographic Weight',
                                                                       'Spatiotemporal-Orthographic Criterion'
                                   ))), 
                 kernel = 'epanechnikov', adjust = 0.65,
                 position="identity",geom="line", linewidth = 0.8, bounds = c(-3.14, 3.14)) +
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
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "white"))
  return(plot)
}

plot.RT <- function(data, model, model_list){
  plot <- ggplot() +
    geom_histogram(data = data, aes(x = source_RT, y = ..density..), colour = 'grey80', fill = 'grey80', boundary = 0, binwidth = 1/7) +
    # geom_histogram(data = model, aes(x = simulated_error, y = ..density.., fill = model_name), bins = 50, alpha = 0.2) +
    stat_density(data = model, aes(x = rt, 
                                   color = factor(model, levels = c('Spatiotemporal', 'Four Factor',
                                                                    'Spatiotemporal-Orthographic',
                                                                    'Spatiotemporal-Orthographic Gamma',
                                                                    'Spatiotemporal-Orthographic Weight',
                                                                    'Spatiotemporal-Orthographic Criterion'
                                   )), 
                                   lty = factor(model, levels = c('Spatiotemporal', 'Four Factor',
                                                                  'Spatiotemporal-Orthographic',
                                                                  'Spatiotemporal-Orthographic Gamma',
                                                                  'Spatiotemporal-Orthographic Weight',
                                                                  'Spatiotemporal-Orthographic Criterion'
                                   ))), 
                 kernel = 'epanechnikov', adjust = 1,
                 position="identity",geom="line", linewidth = 0.8, bounds = c(0, 5)) +
    facet_grid(~condition) +
    scale_x_continuous(name = 'Source RT', limits = c(0, 5), breaks = c(0, 5), labels = c('0','5')) +
    scale_y_continuous(name = 'Density', limits = c(0, 1.5), breaks = c(0, 1.5), labels = (c('0', '1.5'))) + 
    scale_color_manual(values = colours[c(model_list)]) +
    scale_linetype_manual(values = line.types[c(model_list)]) +
    ylab("Density") +
    theme(text = element_text(size=14),
          strip.background = element_blank(),
          strip.text = element_blank(),
          plot.title = element_text(face = "bold", size = 11),
          legend.position = "none",
          legend.title = element_blank(),
          axis.ticks = element_line(colour = "grey70", size = 0.2),
          axis.line.x = element_line(color="black", size = 0.2),
          axis.line.y = element_line(color="black", size = 0.2),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "white"))
  return(plot)
}

plot.qq <- function(data, model, model_list){
  data_qq <- qxq.cond(data, c(0.1, 0.3, 0.5, 0.9), c(0.1, 0.5, 0.9), 'data')
  model_names <- unique(model$model)
  model_qq <- data.frame()
  # Need to rename the model columns and condition coding to match data
  model$source_RT <- model$rt
  model$source_error <- model$error
  for(i in model_names){
    this_model_qq <- qxq.cond(model[model$model == i, ], c(0.1, 0.3, 0.5, 0.9), c(0.1, 0.5, 0.9), i)
    model_qq <- rbind(model_qq, this_model_qq)
  }
  plot <- ggplot() +
    geom_point(data=data_qq, size = 3, aes(x= theta, y = rt, shape = factor(rt_q))) +
    # geom_segment(data = data_qq, linetype = "solid", size = 1, alpha = 0.4, 
    #              aes(x = theta, xend = theta, y = rt_lower, yend = rt_upper, group = rt_q)) +
    geom_point(data=model_qq, size = 3, alpha = 0.7, aes(x= theta, y = rt, shape = factor(rt_q), color = model)) +
    geom_line(data = model_qq, alpha = 0.7, size = 1, aes(x = theta, y = rt,
                                                                             color = model, linetype = model, group = interaction(model, rt_q))) +
    facet_grid(~factor(cond, levels = c('Unrelated', 'Semantic', 'Orthographic'))) +
    scale_x_continuous(name = 'Absolute Error (rad)', breaks = c(0, pi), limits = c(0, pi),
                       labels = c(0, expression(pi))) +
    scale_y_continuous(name = 'Response Time (s)', limits = c(0, 3), breaks = c(0.5, 1.5, 3.0)) +
    scale_color_manual(values = colours[c(model_list)]) +
    scale_linetype_manual(values = line.types[c(model_list)]) +
    scale_shape_manual(values = c(15, 16, 17, 18)) +
    guides(size = "none",
           color= guide_legend(title="Model"),
           linetype = guide_legend(title = "Model"),
           shape= guide_legend(title="Response Time Quantile")) +
    theme(
      text = element_text(size=14),
      strip.text.x = element_blank(),
      strip.background = element_blank(),
      plot.title = element_blank(),
      plot.background = element_rect(fill = "white"),
      panel.grid.major = element_blank(), 
      panel.grid.minor = element_blank(),
      panel.background = element_blank(),
      legend.key = element_rect(colour = "transparent", fill = "white"),
      legend.position = 'bottom',
      legend.box="vertical",
      legend.justification = "left",
      legend.margin=margin(),
      axis.line = element_line(colour = "black")
    )
}

###################### LEVEL 4 ####################################
# Auxiliary functions for QQ construction
qxq.cond <- function(data, rt_quantiles, error_quantiles, model_string){
  # Covert response error to absolute, because we dont care about asymmetry alone y axis
  data$source_error <- abs(data$source_error)
  res <- data.frame()
  for(cond in unique(data$condition)){
    this_data <- data[data$condition == cond,]
    # Order data by absolute response error
    this_data <- this_data[order(this_data$source_error),]
    # Find response error quantiles
    this_error_quantiles <- quantile(this_data$source_error, probs = error_quantiles)
    # Sort data into bins based on quantiles
    for (i in 1:length(this_error_quantiles)){
      this_qq <- data.frame(matrix(nrow = length(rt_quantiles), ncol = 8))
      colnames(this_qq) <- c('theta', 'rt', 'theta_q', 'rt_q', 'rt_lower', 'rt_upper',
                             'model', 'cond')
      # Calculate RT quantiles for this bin of responses
      if(i == 1){
        this_bin <- this_data[this_data$source_error < this_error_quantiles[[i]],]
      } else{
        this_bin <- this_data[((this_data$source_error > this_error_quantiles[[i-1]])) & 
                                (this_data$source_error < this_error_quantiles[[i]]),]
      }
      this_rt_quantiles <- quantile(this_bin$source_RT, probs = rt_quantiles)
      this_rt_CI <- bootstrap_quantiles(this_bin$source_RT, 1000, rt_quantiles)
      # Populate dataframe with requisite information for plot
      this_qq[,1] <- this_error_quantiles[[i]]
      this_qq[,2] <- this_rt_quantiles
      this_qq[,3] <- error_quantiles[[i]]
      this_qq[,4] <- rt_quantiles
      this_qq[,5] <- this_rt_CI[1]
      this_qq[,6] <- this_rt_CI[2]
      this_qq[,7] <- model_string
      this_qq[,8] <- cond
      res <- rbind(res, this_qq)
    }
  }
  return(res)
}


## Some jank confidence interval stuff
bootstrap_quantiles <- function(this_data, n, rt_quantiles){
  quantiles <- data.frame(matrix(nrow = n, ncol = length(rt_quantiles)))
  for(i in 1:n){
    # Sample with replacement and calculate RT quantiles for this sample
    boot <- sample(1:length(this_data), length(this_data), replace=TRUE)
    boot_sample <- this_data[boot]
    this_sample_quantile <- quantile(boot_sample, probs = rt_quantiles)
    quantiles[i, 1:length(rt_quantiles)] <- this_sample_quantile
  }
  colnames(quantiles) <- rt_quantiles
  
  # Find the 95% CI for each RT quantile
  CI <- data.frame(matrix(nrow = length(rt_quantiles), ncol = 2))
  for(i in 1:length(rt_quantiles)){
    this_quantile <- quantiles[,i]
    this_CI <- quantile(this_quantile, probs = c(0.05, 0.95))
    CI[i,] <- this_CI
  }
  return(CI)
}