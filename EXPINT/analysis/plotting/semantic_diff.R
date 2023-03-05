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

load("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/fitted_models/2023-03-04_sim_data.RData")
load("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/fitted_models/2023-03-04_simulated_recenter.RData")

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
                   aes(x = offset, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_histogram(data = model, 
                  aes(x = offset, y = ..density.., fill = model_name), bins = 50, alpha = 0.2) +
    geom_density(data = model,
                 aes(x = offset, color = model_name)) +
    ylim(0, 0.25) + 
    facet_grid(~cond) +
    theme(strip.text.x = element_text(size = 16))
  return(plot)
}


plot.response.error <- function(data, model){
  plot <- ggplot() +
    geom_histogram(data = data, aes(x = source_error, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_histogram(data = model, aes(x = simulated_error, y = ..density.., fill = model_name), bins = 50, alpha = 0.2) +
    geom_density(data = model, aes(x = simulated_error, color = model_name)) +
    facet_grid(~condition) +
    theme(strip.text.x = element_text(size = 16))
  return(plot)
}

plot.response.error.position <- function(data, model){
  plot <- ggplot() +
    geom_histogram(data = data, aes(x = source_error, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_histogram(data = model, aes(x = simulated_error, y = ..density..), fill = 'red', bins = 50, alpha = 0.2) +
    geom_density(data = model, aes(x = simulated_error), color = 'red') +
    facet_grid(condition~target_position) + 
    theme(strip.text.x = element_text(size = 16))
  return(plot)
}
