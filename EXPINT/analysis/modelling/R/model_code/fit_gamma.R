source("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/gamma_cond_model.R")
# # Starting values for parameters
# kappa1 <- 14    # 1. Precision, memory
# kappa2 <- 12    # 2. Precision, intrusion
# # GUESS
# beta <- 0.5     # 3. Proportion of guesses (weight vs. intrusion+memory)
# # INTRUSIONS
# gamma1 <- 0.1    # 4. Overall scaling of intrusions, this is not directly interpretable
# gamma2 <- 0.3
# gamma3 <- 0.1
# # Spatiotemporal
# tau <- 0.6      # 7. Temporal asymmetry (tau >0.5 means forwards are more similar)
# lambda_b <- 1.5 # 8. Similarity decay of backwards temporal lag
# lambda_f <- 1.5 # 9. Similarity decay of forwards temporal lag
# zeta <- 0.5     # 10. Similarity decay of spatial similarity
# rho <- 0.4      # 11. Weight of spatial vs temporal in spatiotemporal component
# chi1 <- 0.3     # 12. Weight of item vs spatiotemporal similarity component LOW
# chi2 <- 0.4     # 13. Weight of item HIGH
# # Item
# iota1 <- 0.5    # 14. Similarity decay of orthographic component LOW (unrelated/semantic)
# iota2 <- 0.5    # 15. Decay for orthography HIGH 
# upsilon1 <- 0.5 # 16. Similarity decay of semantic component LOW
# upsilon2 <- 0.5 # 17. Decay for semantic HIGH
# psi1 <- 0.2     # 18. Weight of semantic vs orthographic in item component LOW (orth/unrelated)
# psi2 <- 0.5     # 19. Weight of semantic HIGH (for semantic list)

fit_gamma <- function(data, participant){
  # Parameter Boundaries
  #         1    2    3    4    5   6     7     8   9   10   11   12  13  14  15  16  17   18  19
  lower <- c(1,  1,  0.2, 0.1, 0.1, 0.1, 0.2, 0.5, 0.5, 0.2, 0.2, 0,   0,   0,  0,  0,  0,  0,  0)
  upper <- c(20, 15, 0.6, 0.5, 0.5, 0.5, 0.7, 3,   3,   0.6, 0.6, 0.6, 0.7, 5,  5,  5,  5,  1,  1)
  
  # Optimise
  this_fit <- DEoptim(gamma_cond_model, lower, upper, control = DEoptim.control(itermax = 500), data)
  
  # Calculate aic
  aic <- get_aic(this_fit$optim$bestval, length(upper[upper!=0]))
  this_fit$optim$aic<-aic
  fit <- this_fit$optim
  # Pass out best fitting parameters
  return(fit)
}