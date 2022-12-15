# This one is a bit of a yardstick to compare the others to, no spatiotemporal component
# although we know that should be important. Just a sanity check, this should miss all
# those spatiotemporal recentering patterns.
source('pure_orthosem_model.R')

fit_pure_orthosem <- function(data, participant){
  # Set some starting parameters

  # Parameter Boundaries
  #         1   2     3   4       5  6 7
  lower <- c(1,  1,  0.2, 0.3,    0, 0, 0)
  upper <- c(20, 15, 0.6, 5,      5, 5, 1)
  
  # Optimise
  this_fit <- DEoptim(orthosem_model, lower, upper, control = DEoptim.control(itermax = 200), data)
  
  # Calculate aic
  aic <- get_aic(this_fit$optim$bestval, length(upper[upper!=0]))
  this_fit$optim$aic<-aic
  fit <- this_fit$optim
  # Pass out best fitting parameters
  return(fit)
}