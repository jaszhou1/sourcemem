# Same function as resp_error.R, but handles the additional models (e.g. gammbeta)

load("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/2022-11-03_response_error.RData")
#load("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/saturated.RData")
library(ggplot2)
library(ggpubr)

sim_spatiotemporal <- 'spatiotemporal'
sim_pure_orthosem <- 'orthographic-semantic'
sim_orthosem <- 'four-factor'
sim_mix_cond <- 'mixture_cond'
sim_gamma$model <- 'gamma'
sim_gammabeta$model <- 'gamma_beta'