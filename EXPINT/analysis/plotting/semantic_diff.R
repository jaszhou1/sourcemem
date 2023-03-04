# Plot the response error and recentered error across conditions for each participant
# Point is to illustrate how the semantic manipulation differs in how in impacts
# When averaged across participant, you would think there is no effect
# For most participants, this is true, but some participants have reversed effects.
# probably not a simple explanation, but can be modelled by alloweing for three gamma parameters
# Load in data
data <- read.csv("~/git/sourcemem/EXPINT/data/EXPINT_data.csv")
data <- data[data$block != -1,]
# Exclude foils
data <- data[data$is_stimulus, ]
# Exclude data with inalid RT
data <- data[data$valid_RT, ]

# Get the indexing of the trial position consistent
data$target_position <- data$present_trial + 1

load("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/fitted_models/2023-02-18_sim_data.RData")

response_error <- plot.response.error(data, sim$sim_data)
recentered_error <- plot.condition.recenter(recentered_data, sim$recentered_sim_data)

# Plot 1 shows the response error and recentered error split by experimental condition
plot <- ggarrange(response_error, recentered_error, ncol = 1, nrow = 2, heights = c(1, 1))

plot.response.error <- function(data, model){
  plot <- ggplot() +
    geom_histogram(data = data, aes(x = source_error, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_histogram(data = model, aes(x = simulated_error, y = ..density..), fill = 'red', bins = 50, alpha = 0.2) +
    geom_density(data = model, aes(x = simulated_error), color = 'red') +
    facet_grid(~condition)
  return(plot)
}

plot.response.error.position <- function(data, model){
  plot <- ggplot() +
    geom_histogram(data = data, aes(x = source_error, y = ..density..), colour = 1, fill = 'white', bins = 50) +
    geom_histogram(data = model, aes(x = simulated_error, y = ..density..), fill = 'red', bins = 50, alpha = 0.2) +
    geom_density(data = model, aes(x = simulated_error), color = 'red') +
    facet_grid(condition~target_position)
  return(plot)
}
