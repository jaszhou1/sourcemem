source("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/gamma_beta_cond_model.R")

fit_gamma_beta <- function(data, participant){
  # Parameter Boundaries
  #         1    2    3    4    5   6     7     8   9   10   11   12   13  14  15    16  17  18  19  20  21  22
  lower <- c(1,  1,  0.2, 0.2, 0.2, 0.1, 0.1, 0.1, 0.2, 0.5, 0.5, 0.2, 0.2, 0,   0,   0,  0,  0,  0,  0,  0)
  upper <- c(20, 15, 0.6, 0.6, 0.6, 0.5, 0.5, 0.5, 0.7, 3,   3,   0.6, 0.6, 0.6, 0.7, 5,  5,  5,  5,  1,  1)
  
  # Optimise
  this_fit <- DEoptim(gamma_beta_cond_model, lower, upper, control = DEoptim.control(itermax = 500), data)
  
  # Calculate aic
  aic <- get_aic(this_fit$optim$bestval, length(upper[upper!=0]))
  this_fit$optim$aic<-aic
  fit <- this_fit$optim
  # Pass out best fitting parameters
  return(fit)
}