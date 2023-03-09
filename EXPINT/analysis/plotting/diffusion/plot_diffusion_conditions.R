# plot_diffusion_conditions
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
spatiotemp <- read.csv("~/git/sourcemem/EXPINT/analysis/modelling/MATLAB/v2/sim_spatiotemp.csv")
ortho <- read.csv("~/git/sourcemem/EXPINT/analysis/modelling/MATLAB/v2/sim_ortho.csv")
# temp_w <- read.csv("~/git/sourcemem/EXPINT/analysis/modelling/MATLAB/v2/sim_temp_ortho_w.csv")
# temp_d <- read.csv("~/git/sourcemem/EXPINT/analysis/modelling/MATLAB/v2/sim_temp_ortho_d.csv")
spatiotemp_w <- read.csv("~/git/sourcemem/EXPINT/analysis/modelling/MATLAB/v2/sim_spatiotemp_ortho_w.csv")

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
  response_times <- plot.RT(data, sim_data)
  qq <- plot.qq(data, sim_data)
  recentered_error <- plot.condition.recenter(recentered_data, recentered_sim_data)
  
  # Plot 1 shows the response error and recentered error split by experimental condition
  plot <- ggarrange(response_error,
                    response_times,
                    qq,
                    recentered_error, 
                    ncol = 1, nrow = 4, heights = c(1, 1))
  annotate_figure(plot, top = text_grob(as.character(p), 
                                        color = "red", face = "bold", size = 14))
  return(plot)
}

