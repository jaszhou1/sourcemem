# MODEL 1: Saturated model, different conditions all with different weights, slopes and overall coefficient for intrusions

source("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/intrusion_cond_model.R")

saturated <- function(data){
  # Sel vector: defines which parameters are freed, and which are fixed, in the optimisation process.
  #       prec.  guess      intrus.     w.space   w.orth    w.sem    time asym   d.time              d.space    d.orth    d.sem
  Sel = c(1, 1,  1, 1, 1,   1, 1, 1,    1, 1, 1,  1, 1, 1,  1, 1, 1,  1, 1, 1,    1, 1, 1, 1, 1, 1,   1, 1, 1,  1, 1, 1,  1, 1, 1)
  
  Pfix = NULL
  
  # Boundaries for estimated parameters. DEoptim will sample uniformly between these bounds
  Pbounds <- matrix(data = NA, nrow = 2, ncol = 35)
  #          prec1, prec2, beta1, beta2, beta3, gamma1, gamma2, gamma3, rho1, rho2, rho3, chi1, psi1, tau1, lambda_b1, lambda_f1, zeta1, iota1, upsilon1
  colnames(Pbounds) <- c('kappa1', 'kappa2', 'beta1', 'beta2', 'beta3', 'gamma1', 'gamma2', 'gamma3', 'rho1', 'rho2', 'rho3', 'chi1', 'chi2', 'chi3', 'psi1', 'psi2', 'psi3', 'tau1', 'tau2', 'tau3', 'lambda_b1', 'lambda_f1', 'lambda_b2', 'lambda_f2', 'lambda_b3', 'lambda_f3','zeta1', 'zeta2', 'zeta3', 'iota1', 'iota2', 'iota3', 'upsilon1', 'upsilon2', 'upsilon3')
  Pbounds[1,] <- c(1, 1, 0.2, 0.2, 0.2, 0.01, 0.03, 0.01, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0.5, 0.5, 0.5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
  Pbounds[2,] <- c(20, 15, 0.6, 0.6, 0.6, 0.4, 0.4, 0.4, 0.6, 0.6, 0.6, 0.7, 0.7, 0.7, 0.7,  0.7, 0.7,  0.7,   0.7,   0.7,   2, 2, 2, 2, 2, 2, 6, 6, 6, 6, 6, 6, 6, 6, 6)
  
  
  # Optimise
  this_fit <- DEoptim(intrusion_cond_model, Pbounds[1,], Pbounds[2,], control = DEoptim.control(itermax = 500), data, Pfix, Sel)
  
  # Calculate aic
  aic <- get_aic(this_fit$optim$bestval, length(upper))
  this_fit$optim$aic<-aic
  fit <- this_fit$optim
  # Pass out best fitting parameters
  return(fit)
}
