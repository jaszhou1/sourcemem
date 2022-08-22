source("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/intrusion_gradient_model_conditions.R")
# Testing the equivalence of the saturated and base spatiotemporal model by constraining additional parameters
# so that in the end, the likelihood of the model should be equal

P <- c(kappa1, kappa2, beta, gamma, tau, lambda_b, lambda_f, zeta, rho, chi1, chi2, iota1, iota2,
       upsilon1, upsilon2, psi1, psi2)

fit_constrained_saturated <- function(data, participant){
  # Set some starting parameters
  
  
  # Parameter Boundaries
  #         1    2    3    4    5   6     7     8   9   10   11   12  13  14  15  16  17  
  lower <- c(1,  1,  0.2, 0.2, 0.2, 0.5, 0.5, 0.2, 0.2, 0,   0,   0,  0,  0,  0,  0,  0)
  upper <- c(20, 15, 0.6, 0.4, 0.7, 3,   3,   0.6, 0.6, 0.6, 0.7, 5,  5,  5,  5,  1,  1)
  
  # Number of population members in DE, recommended 10*length of parameter vector
  NP <- length(upper[upper!=0]) * 10
  initialpop <- t(as.matrix(P))
  initialpop <-  matrix(rep(initialpop, 5), ncol=ncol(initialpop), byrow = TRUE) # DEoptim wants starting points as a matrix for each pop.
  # could have different starting parameters for each population member? Am i making it worse than default NA
  
  # Optimise
  this_fit <- DEoptim(intrusion_constrain_model, lower, upper, control = DEoptim.control(itermax = 200), data)
  
  # Calculate aic
  aic <- get_aic(this_fit$optim$bestval, length(upper[upper!=0]))
  this_fit$optim$aic<-aic
  fit <- this_fit$optim
  # Pass out best fitting parameters
  return(fit)
}