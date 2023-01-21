# Model 9, "Spatial-Ortho"
# Intrusion probably based spatial and orthographic simiarity
# Overall intrusion coefficient differs between orthographic and unrelated conditions.

spatial_ortho <- function(data){
  # Sel vector: defines which parameters are freed, and which are fixed, in the optimisation process.
  #       prec.  guess      intrus.   context w   w.spac    w.sem    time asym   d.time              d.space    d.orth    d.sem
  Sel = c(1, 1,  1, 0, 0,   1, 1, 0,  1, 0, 0,  1, 0, 0,  0, 0, 0,  0, 0, 0,   0, 0, 0, 0, 0, 0,   1, 0, 0,  1, 0, 0,  0, 0, 0)
  
  # For the fixed parameters (P[Sel == 0], what value should parameter be fixed at? NA will be treated as "same as unrelated condition")
  beta2 <- NA
  beta3 <- NA
  
  gamma3 <- NA
  
  # intrusion weights
  chi2 <- NA
  chi3 <- NA
  
  phi1 <- 1 # Space vs. Time weight
  phi2 <- NA
  phi3 <- NA
  
  psi1 <- 0 # Semantic vs. Orthographic weight
  psi2 <- NA
  psi3 <- NA
  
  # intrusion similarity decays
  tau1 <- 0.5 # Temporal asymmetry (tau >0.5 means forwards are more similar)
  tau2 <- NA
  tau3 <- NA
  
  lambda_b1 <- 0
  lambda_f1 <- NA
  
  lambda_b2 <- NA # Similarity decay of backwards temporal lag
  lambda_f2 <- NA # Similarity decay of forwards temporal lag
  
  lambda_b3 <- NA # Similarity decay of backwards temporal lag
  lambda_f3 <- NA # Similarity decay of forwards temporal lag
  
  zeta2 <- NA
  zeta3 <- NA
  
  iota2 <- NA # Decay for orthography orthographic
  iota3 <- NA
  
  upsilon1 <- 0 # Similarity decay of semantic component unrelated
  upsilon2 <- NA # Decay for semantic orth
  upsilon3 <- NA
  
  Pfix = c(beta2, beta3, gamma3, chi2, chi3, phi1, phi2, phi3,
           psi1, psi2, psi3, tau1, tau2, tau3,
           lambda_b1, lambda_f1, lambda_b2, lambda_f2, lambda_b3, lambda_f3,
           zeta2, zeta3, iota2, iota3, upsilon1, upsilon2, upsilon3)
  
  # Boundaries for estimated parameters. DEoptim will sample uniformly between these bounds
  #          prec1, prec2, beta1, gamma1, gamma2, chi1,  zeta, iota1
  lower <- c(1,     1,     0.1,   0,      0,      0,     0,         0)
  upper <- c(20,    15,    0.8,   0.5,    0.5,    1,     5,        10)
  
  # Optimise
  this_fit <- DEoptim(intrusion_cond_model_x, lower, upper, control = DEoptim.control(itermax = 500), data, Pfix, Sel)
  
  # Calculate aic
  aic <- get_aic(this_fit$optim$bestval, length(upper))
  this_fit$optim$aic<-aic
  
  # Assemble estimated parameter vector
  Pest <- vector(mode = "numeric", length = 38)
  
  Pest[Sel == 1] <- this_fit$optim$bestmem # Estimated parameters
  Pest[Sel == 0] <- Pfix # Fixed parameters
  this_fit$optim$Pest <- Pest
  
  fit <- this_fit$optim
  # Pass out best fitting parameters
  return(fit)
}