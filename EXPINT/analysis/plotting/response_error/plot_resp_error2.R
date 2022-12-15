# Same function as resp_error.R, but handles the additional models (e.g. gammbeta)

load("~/git/sourcemem/EXPINT/analysis/modelling/R/2022-11-03_response_error.RData")
#load("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/saturated.RData")
library(ggplot2)
library(ggpubr)

sim_spatiotemporal$model <- 'spatiotemporal'
sim_pure_orthosem$model <- 'orthographic-semantic'
sim_orthosem$model <- 'four-factor'
sim_mix_cond$model <- 'mixture_cond'
sim_gamma$model <- 'gamma'
sim_gammabeta$model <- 'gamma_beta'


models <- rbind(sim_spatiotemporal, sim_pure_orthosem, sim_orthosem, sim_mix_cond,  sim_gammabeta )
#recentered_models <- rbind(recenter_spatiotemporal, recenter_orthosem, recenter_saturated)

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
  geom_density(data = models, aes(x = simulated_error, color = model), lwd = 1.3, adjust = 1) +
  facet_wrap(~condition)

ggsave('indiv_error.png', plot = last_plot(), width = 40, height = 35, units = "cm")

group_error <- ggplot() +
  geom_histogram(data = data, aes(x = source_error, y = ..density..), colour = 1, fill = 'white', bins = 30) +
  geom_density(data = models, aes(x = simulated_error, color = model), adjust = 1)
ggsave('group_error.png', plot = last_plot(), width = 40, height = 35, units = "cm")
