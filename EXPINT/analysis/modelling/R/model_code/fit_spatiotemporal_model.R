# Function to fit the spatiotemporal model
# We do this by using the generalised intrusion gradient model, and fix the orthographic & semantic components at 0
# for DEoptim, I think the easiest way to do this is to simply set the upperbound as 0. We will manually enter
# the number of parameters to calculate the AIC/BIC.

# # MEMORY
# 1. kappa1 <- params[1] # Precision, memory
# 2. kappa2 <- params[2] # Precision, intrusion

# # GUESS
# 3. beta <- params[3] # Proportion of guesses (weight vs. intrusion+memory)

# # INTRUSIONS
# 4. gamma <- params[4] # Overall scaling of intrusions, this is not directly interpretable

# # Spatiotemporal
# 5. tau <- params[5] # Temporal asymmetry (tau >0.5 means forwards are more similar)
# 6. lambda_b <- params[6] # Similarity decay of backwards temporal lag
# 7. lambda_f <- params[7] # Similarity decay of forwards temporal lag
# 8. zeta <- params[8] # Similarity decay of spatial similarity
# 9. rho <- params[9] # Weight of spatial vs temporal in spatiotemporal component
# 10. chi <- params[10] # Weight of item vs spatiotemporal similarity component

# # Item
# 11. iota <- params[11] # Similarity decay of orthographic component
# 12. upsilon <- params[12] # Similarity decay of semantic component
# 13. psi <- params[13] # Weight of semantic vs orthographic in item component

source('intrusion_gradient_model.R')

fit_spatiotemporal <- function(data, participant){
  # Set some starting parameters
  
  
  # Parameter Boundaries
  #         1    2    3   4     5   6     7     8      9   10  11  12 13
  lower <- c(1,  1,  0.2, 0.3, 0.5, 0.5, 0.1,   0.1,  0.1,  0,   0, 0, 0)
  upper <- c(20, 15, 0.6, 5,   0.99, 5,   5,    5,    0.9,  0,   0, 0, 0)
  
  # Optimise
  this_fit <- DEoptim(intrusion_model, lower, upper, control = DEoptim.control(itermax = 200), data)
  
  # Calculate aic
  aic <- get_aic(this_fit$optim$bestval, length(upper[upper!=0]))
  this_fit$optim$aic<-aic
  fit <- this_fit$optim
  # Pass out best fitting parameters
  return(fit)
}