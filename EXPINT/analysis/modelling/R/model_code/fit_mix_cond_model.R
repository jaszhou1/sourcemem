source("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/intrusion_gradient_model_conditions.R")
# Starting values for parameters
kappa1 <- 14    # 1. Precision, memory
kappa2 <- 12    # 2. Precision, intrusion
# GUESS
beta <- 0.5     # 3. Proportion of guesses (weight vs. intrusion+memory)
# INTRUSIONS
gamma <- 0.1    # 4. Overall scaling of intrusions, this is not directly interpretable
# Spatiotemporal
tau <- 0.6      # 5. Temporal asymmetry (tau >0.5 means forwards are more similar)
lambda_b <- 1.5 # 6. Similarity decay of backwards temporal lag
lambda_f <- 1.5 # 7. Similarity decay of forwards temporal lag
zeta <- 0.5     # 8. Similarity decay of spatial similarity
rho <- 0.4      # 9. Weight of spatial vs temporal in spatiotemporal component
chi1 <- 0.3     # 10. Weight of item vs spatiotemporal similarity component LOW
chi2 <- 0.4     # 11. Weight of item HIGH
# Item
iota1 <- 0.5    # 12. Similarity decay of orthographic component LOW (unrelated/semantic)
iota2 <- 0.5    # 13. Decay for orthography HIGH 
upsilon1 <- 0.5 # 14. Similarity decay of semantic component LOW
upsilon2 <- 0.5 # 15. Decay for semantic HIGH
psi1 <- 0.2     # 16. Weight of semantic vs orthographic in item component LOW (orth/unrelated)
psi2 <- 0.5     # 18. Weight of semantic HIGH (for semantic list)

P <- c(kappa1, kappa2, beta, gamma, tau, lambda_b, lambda_f, zeta, rho, chi1, chi2, iota1, iota2,
       upsilon1, upsilon2, psi1, psi2)

fit_saturated <- function(data, participant){
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
  this_fit <- DEoptim(intrusion_cond_model, lower, upper, control = DEoptim.control(itermax = 200), data)
  
  # Calculate aic
  aic <- get_aic(this_fit$optim$bestval, length(upper[upper!=0]))
  this_fit$optim$aic<-aic
  fit <- this_fit$optim
  # Pass out best fitting parameters
  return(fit)
}