# MODEL 3: Assume no  difference between unrelated and semantic conditions, collapse all parameters related to semantic cond

two_cond <- function(data){
  # Sel vector: defines which parameters are freed, and which are fixed, in the optimisation process.
  #       prec.  guess      intrus.     w.space   w.orth    w.sem    time asym   d.time              d.space    d.orth    d.sem
  Sel = c(1, 1,  1, 0, 0,   1, 1, 0,    1, 1, 0,  1, 1, 0,  1, 1, 0,  1, 1, 0,    1, 1, 1, 1, 0, 0,   1, 1, 0,  1, 1, 0,  1, 1, 0)
  
  # For the fixed parameters (P[Sel == 0], what value should parameter be fixed at? NA will be treated as "same as unrelated condition")
  beta2 <- NA
  beta3 <- NA
  gamma3 <- NA
  # intrusion weights
  rho3 <- NA # Space, sem condition
  chi3 <- NA
  psi3 <- NA
  tau3 <- NA
  lambda_b3 <- NA # Similarity decay of backwards temporal lag
  lambda_f3 <- NA # Similarity decay of forwards temporal lag
  zeta3 <- NA
  iota3 <- NA
  upsilon3 <- NA

  Pfix = c(beta2, beta3, gamma3, rho3, chi3, psi3, tau3, lambda_b3, lambda_f3, zeta3, iota3, upsilon3)
  
  # Boundaries for estimated parameters. DEoptim will sample uniformly between these bounds
  Pbounds <- matrix(data = NA, nrow = 2, ncol = 23)
  #          prec1, prec2, beta1, beta2, beta3, gamma1, gamma2, gamma3, rho1, rho2, rho3, chi1, psi1, tau1, lambda_b1, lambda_f1, zeta1, iota1, upsilon1
  colnames(Pbounds) <- c('kappa1', 'kappa2', 'beta1', 'gamma1', 'gamma2', 'rho1', 'rho2', 'chi1', 'chi2', 'psi1', 'psi2', 'tau1', 'tau2', 'lambda_b1', 'lambda_f1', 'lambda_b2', 'lambda_f2', 'zeta1', 'zeta2',  'iota1', 'iota2', 'upsilon1', 'upsilon2')
  Pbounds[1,] <- c(1,  1,  0.2, 0.01,0.03,  0,   0,   0,   0,   0,   0,  0.5, 0.5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
  Pbounds[2,] <- c(20, 15, 0.6, 0.4, 0.4,  0.6, 0.6, 0.7, 0.7, 0.7, 0.7, 0.7, 0.7, 2, 2, 2, 2, 6, 6, 6, 6, 6, 6)
  
  
  # Optimise
  this_fit <- DEoptim(intrusion_cond_model, Pbounds[1,], Pbounds[2,], control = DEoptim.control(itermax = 500), data, Pfix, Sel)
  
  # Calculate aic
  aic <- get_aic(this_fit$optim$bestval, length(upper))
  this_fit$optim$aic<-aic
  
  # Assemble estimated parameter vector
  Pest <- vector(mode = "numeric", length = 35)
  
  Pest[Sel == 1] <- this_fit$optim$bestmem # Estimated parameters
  Pest[Sel == 0] <- Pfix # Fixed parameters
  this_fit$optim$Pest <- Pest
  
  fit <- this_fit$optim
  # Pass out best fitting parameters
  return(fit)
}
