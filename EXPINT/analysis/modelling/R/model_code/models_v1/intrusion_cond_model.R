## INTRUSION_COND_MODEL.R
# Model code that fits three conditions simultaneously, with the option of the 
# following parameters differing between conditions:
# 1. Overall proportion of intrusions
# 2. Overall proportion of guesses
# 3. Weighting of temmporal similarity in determining intrusion probability
# 4. same, spatial
# 5. semantic
# 6. orthographic

library(extraDistr)
library(CircStats)
library(circular)

intrusion_cond_model <- function(Pvar, data, Pfix, Sel){
  
  n_trials <- 8
  n_intrusions <- n_trials - 1
  
  # Check number of parameters
  if(length(Pvar) + length(Pfix) != 35){
    print("Incorrect number of parameters")
    nLL <- 1e7
    return(nLL)
  }
  
  # Assemble parameter vector from the free (to be estimated) and fixed parameters
  P <- vector(mode = "numeric", length = 35)
  
  # Example Sel vector
  #         prec.       guess    intrus.      w.space   w.orth    w.sem       time asym   d.time              d.space   d.orth    d.sem
  # Sel = c(1, 1,       1, 1, 1,  1, 1, 1,    1, 1, 1,  1, 1, 1,  1, 1, 1,    1, 0, 0,    1, 1, 0, 0, 0, 0,   1, 0, 0,  1, 0, 0,  1, 0, 0)
  
  P[Sel == 1] <- Pvar # Estimated parameters
  P[Sel == 0] <- Pfix # Fixed parameters
  
  # Get parameters out from vector
  # MEMORY
  kappa1 <- P[1] # Precision, memory
  kappa2 <- P[2] # Precision, intrusion
  
  # GUESS
  beta1 <- P[3] # Proportion of guesses (weight vs. intrusion+memory)
  beta2 <- P[4] # Orth cond.
  beta3 <- P[5] # Sem cond.
  # INTRUSIONS
  gamma1 <- P[6] # Overall scaling of intrusions, this is not directly interpretable
  gamma2 <- P[7] # Orth cond,
  gamma3 <- P[8] # Sem cond.
  
  # intrusion weights
  # phi1 <- P[9] #temporal weight, unrelated condition
  # phi2 <- P[10] # orthographic
  # phi3 <- P[11] # semantic
  
  # Instead of estimating phi, we can assume the weights of similarity factors sum to 1,
  # such that phi = 1-(rho + chi + psi)
  
  rho1 <- P[9] # Spatial weight
  rho2 <- P[10]
  rho3 <- P[11]
  
  chi1 <- P[12] # Orthographic weight
  chi2 <- P[13]
  chi3 <- P[14]
  
  psi1 <- P[15] # Semantic weight
  psi2 <- P[16]
  psi3 <- P[17]
  
  # intrusion similarity decays
  tau1 <- P[18] # Temporal asymmetry (tau >0.5 means forwards are more similar)
  tau2 <- P[19]
  tau3 <- P[20]
  
  lambda_b1 <- P[21] # Similarity decay of backwards temporal lag
  lambda_f1 <- P[22] # Similarity decay of forwards temporal lag
  
  lambda_b2 <- P[23] # Similarity decay of backwards temporal lag
  lambda_f2 <- P[24] # Similarity decay of forwards temporal lag
  
  lambda_b3 <- P[25] # Similarity decay of backwards temporal lag
  lambda_f3 <- P[26] # Similarity decay of forwards temporal lag
  
  zeta1 <- P[27] # Similarity decay of spatial similarity
  zeta2 <- P[28]
  zeta3 <- P[29]
  
  iota1 <- P[30] # Similarity decay of orthographic component unrelated
  iota2 <- P[31] # Decay for orthography orthographic
  iota3 <- P[32]
  
  upsilon1 <- P[33] # Similarity decay of semantic component unrelated
  upsilon2 <- P[34] # Decay for semantic orth
  upsilon3 <- P[35]
  
  # Set some default values for condition-dependant parameters
  # i.e. if iota3 = NA, I don't want it to actually be treated as zero, I want it to be fixed at whatever the value of iota1 is.
  # reduces down to a simpler model. Maybe there is a better way to do this? I cant substitute the same default value, the value
  # has to be whatever the "unrelated" parameter value is
  
  # This is so cooked. Feels bad
  
  if(is.na(kappa2)){
    kappa2 <- kappa1
  }
  
  if(is.na(beta2)){
    beta2 <- beta1
  }
  
  if(is.na(beta3)){
    beta3 <- beta1
  }
  
  if(is.na(gamma2)){
    gamma2 <- gamma1
  }
  
  if(is.na(gamma3)){
    gamma3 <- gamma1
  }
  
  if(is.na(rho2)){
    rho2 <- rho1
  }
  
  if(is.na(rho3)){
    rho3 <- rho1
  }
  
  if(is.na(chi2)){
    chi2 <- chi1
  }
  
  if(is.na(chi3)){
    chi3 <- chi1
  }
  
  if(is.na(psi2)){
    psi2 <- psi1
  }
  
  if(is.na(psi3)){
    psi3 <- psi1
  }
  
  if(is.na(tau2)){
    tau2 <- tau1
  }
  
  if(is.na(tau3)){
    tau3 <- tau1
  }
  
  #extra one, let the decay be the same in both directions of time
  if(is.na(lambda_f1)){
    lambda_f1 <- lambda_b1
  }
  
  if(is.na(lambda_b2)){
    lambda_b2 <- lambda_b1
  }
  
  if(is.na(lambda_f2)){
    lambda_f2 <- lambda_f1
  }
  
  if(is.na(lambda_b3)){
    lambda_b3 <- lambda_b1
  }

  if(is.na(lambda_f3)){
    lambda_f3 <- lambda_f1
  }

  if(is.na(zeta2)){
    zeta2 <- zeta1
  }
  
  if(is.na(zeta3)){
    zeta3 <- zeta1
  }
  
  if(is.na(iota2)){
    iota2 <- iota1
  }
  
  if(is.na(iota3)){
    iota3 <- iota1
  }
  
  if(is.na(upsilon2)){
    upsilon2 <- upsilon1
  }
  
  if(is.na(upsilon3)){
    upsilon3 <- upsilon1
  }
  
  # Force precision for intrusions to be equal or less than precision for memory
  if(kappa2 > kappa1){
    nLL <- 1e7
    return(nLL)
  }
  
  # Define the weight for time in the intrusion weight calculation
  phi1 <- 1 - (rho1 + chi1 + psi1)
  phi2 <- 1 - (rho2 + chi2 + psi2)
  phi3 <- 1 - (rho3 + chi3 + psi3)
  
  if(any(c(phi1, phi2, phi3) < 0)){
    # print("Similarity weights do not sum to 1")
    nLL <- 1e7
    return(nLL)
  }
  
  data[,30:36] <- data[,30:36]/max(data[,30:36]) # Time, max is number of nontargets, 7
  data[,37:43] <- data[,37:43]/max(data[,37:43]) # Space, max is 2, cos metric
  data[,44:50] <- data[,44:50]/max(data[,44:50]) # Orthographic, max is equal to number of characters in word stimuli (6)
  data[,51:57] <- 1-data[,51:57] # Turn semantic cosine similarity into distance (big number means less similar), max is naturally 1.
  
  
  # Define a vector of raw temporal similarities
  # note: I don't know of an elegant way to do this separately for each condition, given that there are forward asymmetries so differences in rows and columns
  # Instead, I will just generate three copies of the entire temporal sim matrix and select rows as required by condition
  # lags <- setdiff(-7:7, 0)
  # temporal_gradient <- setNames(data.frame(matrix(ncol = n_intrusions*2, nrow = 3)), lags)
  # # Backwards intrusion slope, unrelated condition
  # temporal_gradient[1,1:n_intrusions] <- (1-tau1)*exp(-lambda_b1*(abs(-n_intrusions:-1)/max(data[,30:36])))
  # # Forwards intrusion slope
  # temporal_gradient[1,(n_intrusions+1):(n_intrusions*2)] <- tau1*exp(-lambda_f1*(abs(1:n_intrusions)/max(data[,30:36])))
  # 
  # # Backwards, orthographic condition 
  # temporal_gradient[2,1:n_intrusions] <- (1-tau2)*exp(-lambda_b2*(abs(-n_intrusions:-1)/max(data[,30:36])))
  # # Forwards 
  # temporal_gradient[2,(n_intrusions+1):(n_intrusions*2)] <- tau2*exp(-lambda_f2*(abs(1:n_intrusions)/max(data[,30:36])))
  # 
  # # Backwards, semantic condition
  # temporal_gradient[3,1:n_intrusions] <- (1-tau3)*exp(-lambda_b3*(abs(-n_intrusions:-1)/max(data[,30:36])))
  # # Forwards 
  # temporal_gradient[3,(n_intrusions+1):(n_intrusions*2)] <- tau3*exp(-lambda_f3*(abs(1:n_intrusions)/max(data[,30:36])))
  # 
  # # Normalise across serial positions
  # temporal_gradient_unrelated <- temporal_gradient[1,]/sum(temporal_gradient[1,])
  # temporal_gradient_orthographic <- temporal_gradient[2,]/sum(temporal_gradient[2,])
  # temporal_gradient_semantic <- temporal_gradient[3,]/sum(temporal_gradient[3,])
  # 
  # # Replace the intrusion lag positions with the normalised temporal similarities
  # temporal_similarity_unrelated <- data[,30:36]
  # temporal_similarity_orthographic <- data[,30:36]
  # temporal_similarity_semantic <- data[,30:36]
  # for(i in lags){
  #   temporal_similarity_unrelated[temporal_similarity_unrelated == i] <- temporal_gradient_unrelated[[as.character(i)]]
  #   temporal_similarity_orthographic[temporal_similarity_orthographic == i] <- temporal_gradient_orthographic[[as.character(i)]]
  #   temporal_similarity_semantic[temporal_similarity_semantic == i] <- temporal_gradient_semantic[[as.character(i)]]
  # }
  
  temporal_similarity <- data.frame(matrix(nrow = nrow(data), ncol = n_intrusions))
  temporal_similarity[data$condition=='unrelated',1:7] <- lapply(data[data$condition=='unrelated',30:36], 
                                                                 temporal_shepard,
                                                                 k1 = lambda_b1, k2 = lambda_f1, tau = tau1)
  
  temporal_similarity[data$condition=='orthographic',1:7] <- lapply(data[data$condition=='orthographic',30:36], 
                                                                    temporal_shepard,
                                                                    k1 = lambda_b2, k2 = lambda_f2, tau = tau2)
  
  temporal_similarity[data$condition=='semantic',1:7] <- lapply(data[data$condition=='semantic',30:36], 
                                                                temporal_shepard,
                                                                k1 = lambda_b3, k2 = lambda_f3, tau = tau3)
  
  
  # Turn cosine distances between target and intrusions into Shepard similarity
  spatial_similarity <- data.frame(matrix(nrow = nrow(data), ncol = n_intrusions))
  spatial_similarity[data$condition=='unrelated',1:7] <- lapply(data[data$condition=='unrelated',37:43], shepard_similarity, k = zeta1)
  spatial_similarity[data$condition=='orthographic',1:7] <- lapply(data[data$condition=='orthographic',37:43], shepard_similarity, k = zeta2)
  spatial_similarity[data$condition=='semantic',1:7] <- lapply(data[data$condition=='semantic',37:43], shepard_similarity, k = zeta3)
  
  ## Add different decays for the different conditions
  orthographic_similarity <- data.frame(matrix(nrow = nrow(data), ncol = n_intrusions))
  # When the condition is unrelated, use iota 1
  orthographic_similarity[data$condition=='unrelated',1:7] <- lapply(data[data$condition=='unrelated',44:50], shepard_similarity, k = iota1)
  # When the condition is orthographic, use iota 2
  orthographic_similarity[data$condition=='orthographic',1:7] <- lapply(data[data$condition=='orthographic',44:50], shepard_similarity, k = iota2)
  # When the condition is semantic, use iota 3
  orthographic_similarity[data$condition=='semantic',1:7] <- lapply(data[data$condition=='semantic',44:50], shepard_similarity, k = iota3)
  
  # Scale semantic cosine similarity
  semantic_similarity <- data.frame(matrix(nrow = nrow(data), ncol = n_intrusions))
  semantic_similarity[data$condition=='unrelated',1:7] <- lapply(data[data$condition=='unrelated',51:57], shepard_similarity, k = upsilon1)
  semantic_similarity[data$condition=='orthographic',1:7] <- lapply(data[data$condition=='orthographic',51:57], shepard_similarity, k = upsilon2) 
  semantic_similarity[data$condition=='semantic',1:7] <- lapply(data[data$condition=='semantic',51:57], shepard_similarity, k = upsilon3) 
  
  
  # Multiply the temporal similarities with corresponding spatial similarity to get a spatiotemporal gradient on each trial, for each condition
  intrusion_weights <- data.frame(matrix(nrow = nrow(data),ncol = n_intrusions))
  
  intrusion_weights[data$condition == 'unrelated',] <- gamma1 * temporal_similarity[data$condition == 'unrelated',]^phi1 * 
    spatial_similarity[data$condition == 'unrelated',]^rho1 * 
    orthographic_similarity[data$condition == 'unrelated',]^chi1 * 
    semantic_similarity[data$condition == 'unrelated',]^psi1
  
  intrusion_weights[data$condition == 'orthographic',] <- gamma2 * temporal_similarity[data$condition == 'orthographic',]^phi2 * 
    spatial_similarity[data$condition == 'orthographic',]^rho2 * 
    orthographic_similarity[data$condition == 'orthographic',]^chi2 * 
    semantic_similarity[data$condition == 'orthographic',]^psi2
  
  intrusion_weights[data$condition == 'semantic',] <- gamma3 * temporal_similarity[data$condition == 'semantic',]^phi3 * 
    spatial_similarity[data$condition == 'semantic',]^rho3 * 
    orthographic_similarity[data$condition == 'semantic',]^chi3 * 
    semantic_similarity[data$condition == 'semantic',]^psi3
  
  colnames(intrusion_weights) <- c("weight_1", "weight_2", "weight_3", "weight_4", "weight_5", "weight_6", "weight_7")
  
  target_weight <- 1 - rowSums(intrusion_weights)
  trial_weights <- cbind(target_weight, intrusion_weights)
  
  # Multiply all weights by 1-beta, the non-guessed responses, based on the serial position of the target
  # Allow different betas for different conditions
  
  # Unrelated condition
  trial_weights[data$condition == 'unrelated',] <- trial_weights[data$condition == 'unrelated',] * (1-beta1)
  trial_weights[data$condition == 'unrelated', length(trial_weights)+1] <- beta1
  
  trial_weights[data$condition == 'orthographic',] <- trial_weights[data$condition == 'orthographic',] * (1-beta2)
  trial_weights[data$condition == 'orthographic', length(trial_weights)] <- beta2
  
  trial_weights[data$condition == 'semantic',] <- trial_weights[data$condition == 'semantic',] * (1-beta3)
  trial_weights[data$condition == 'semantic', length(trial_weights)] <- beta3
  
  # Make sure all weights are positive numbers
  if(any(trial_weights < 0)){
    # print("Invalid: Negative weight")
    nLL <- 1e7
    return(nLL)
  }
  
  data <- cbind(data, intrusion_weights)
  # Get likelihoods of the response angle coming from a von Mises distribution centered on each of the angles in its block
  likelihoods <- data.frame(matrix(ncol=10,nrow=nrow(data), dimnames=list(NULL, c('position','target', 'intrusion_1','intrusion_2',
                                                                                  'intrusion_3','intrusion_4','intrusion_5',
                                                                                  'intrusion_6','intrusion_7', 'guess'))))
  # Save the study list position of each target 
  likelihoods$position <- data$present_trial
  
  # Memory component
  likelihoods$target <- dvm(data$response_angle, data$target_angle, kappa1)
  
  # Intrusion component (There must be a better way to do this? like likelihoods[2:10] or something)
  likelihoods$intrusion_1 <- dvm(data$response_angle, data$angle_1, kappa2)
  likelihoods$intrusion_2 <- dvm(data$response_angle, data$angle_2, kappa2)
  likelihoods$intrusion_3 <- dvm(data$response_angle, data$angle_3, kappa2)
  likelihoods$intrusion_4 <- dvm(data$response_angle, data$angle_4, kappa2)
  likelihoods$intrusion_5 <- dvm(data$response_angle, data$angle_5, kappa2)
  likelihoods$intrusion_6 <- dvm(data$response_angle, data$angle_6, kappa2)
  likelihoods$intrusion_7 <- dvm(data$response_angle, data$angle_7, kappa2)
  
  # Guessing component
  likelihoods$guess <- dcircularuniform(data$response_angle)
  
  likelihoods <- cbind(likelihoods, trial_weights)
  
  # Find the weighted likelihood of each single trial, given component likelihoods and weights
  likelihoods$weighted_likelihood <- rowSums(likelihoods[,2:10] * likelihoods[,11:19])
  
  nLL <- -sum(log(likelihoods$weighted_likelihood))
  return(nLL)
}



# P = temp[participant,5:9]

# Simulate data from fitted parameters of the temporal gradient model
simulate_intrusion_cond_model <- function(participant, data, P, model_name){
  
  # Check that trial numbers are 1-indexed
  if(min(data$present_trial) == 0){
    data$present_trial <- data$present_trial + 1
  }
  
  n_trials <- 8
  n_intrusions <- 7 
  
  # Parameters
  kappa1 <- P[[1]] # Precision, memory
  kappa2 <- P[[2]] # Precision, intrusion
  
  # GUESS
  beta1 <- P[[3]] # Proportion of guesses (weight vs. intrusion+memory)
  beta2 <- P[[4]] # Orth cond.
  beta3 <- P[[5]] # Sem cond.
  # INTRUSIONS
  gamma1 <- P[[6]] # Overall scaling of intrusions, this is not directly interpretable
  gamma2 <- P[[7]] # Orth cond,
  gamma3 <- P[[8]] # Sem cond.
  
  rho1 <- P[[9]] # Spatial weight
  rho2 <- P[[10]]
  rho3 <- P[[11]]
  
  chi1 <- P[[12]] # Orthographic weight
  chi2 <- P[[13]]
  chi3 <- P[[14]]
  
  psi1 <- P[[15]] # Semantic weight
  psi2 <- P[[16]]
  psi3 <- P[[17]]
  
  # intrusion similarity decays
  tau1 <- P[[18]] # Temporal asymmetry (tau >0.5 means forwards are more similar)
  tau2 <- P[[19]]
  tau3 <- P[[20]]
  
  lambda_b1 <- P[[21]] # Similarity decay of backwards temporal lag
  lambda_f1 <- P[[22]] # Similarity decay of forwards temporal lag
  
  lambda_b2 <- P[[23]] # Similarity decay of backwards temporal lag
  lambda_f2 <- P[[24]] # Similarity decay of forwards temporal lag
  
  lambda_b3 <- P[[25]] # Similarity decay of backwards temporal lag
  lambda_f3 <- P[[26]] # Similarity decay of forwards temporal lag
  
  zeta1 <- P[[27]] # Similarity decay of spatial similarity
  zeta2 <- P[[28]]
  zeta3 <- P[[29]]
  
  iota1 <- P[[30]] # Similarity decay of orthographic component unrelated
  iota2 <- P[[31]] # Decay for orthography orthographic
  iota3 <- P[[32]]
  
  upsilon1 <- P[[33]] # Similarity decay of semantic component unrelated
  upsilon2 <- P[[34]] # Decay for semantic orth
  upsilon3 <- P[[35]]
  
  if(is.na(kappa2)){
    kappa2 <- kappa1
  }
  
  if(is.na(beta2)){
    beta2 <- beta1
  }
  
  if(is.na(beta3)){
    beta3 <- beta1
  }
  
  if(is.na(gamma2)){
    gamma2 <- gamma1
  }
  
  if(is.na(gamma3)){
    gamma3 <- gamma1
  }
  
  if(is.na(rho2)){
    rho2 <- rho1
  }
  
  if(is.na(rho3)){
    rho3 <- rho1
  }
  
  if(is.na(chi2)){
    chi2 <- chi1
  }
  
  if(is.na(chi3)){
    chi3 <- chi1
  }
  
  if(is.na(psi2)){
    psi2 <- psi1
  }
  
  if(is.na(psi3)){
    psi3 <- psi1
  }
  
  if(is.na(tau2)){
    tau2 <- tau1
  }
  
  if(is.na(tau3)){
    tau3 <- tau1
  }
  
  #extra one, let the decay be the same in both directions of time
  if(is.na(lambda_f1)){
    lambda_f1 <- lambda_b1
  }
  
  if(is.na(lambda_b2)){
    lambda_b2 <- lambda_b1
  }
  
  if(is.na(lambda_f2)){
    lambda_f2 <- lambda_f1
  }
  
  if(is.na(lambda_b3)){
    lambda_b3 <- lambda_b1
  }
  
  if(is.na(lambda_f3)){
    lambda_f3 <- lambda_f1
  }
  
  if(is.na(zeta2)){
    zeta2 <- zeta1
  }
  
  if(is.na(zeta3)){
    zeta3 <- zeta1
  }
  
  if(is.na(iota2)){
    iota2 <- iota1
  }
  
  if(is.na(iota3)){
    iota3 <- iota1
  }
  
  if(is.na(upsilon2)){
    upsilon2 <- upsilon1
  }
  
  if(is.na(upsilon3)){
    upsilon3 <- upsilon1
  }
  
  phi1 <- 1 - (rho1 + chi1 + psi1)
  phi2 <- 1 - (rho2 + chi2 + psi2)
  phi3 <- 1 - (rho3 + chi3 + psi3)
  
  # Get an untransformed copy of the similarities
  similarities <- data[,30:57]
  
  # Rescale all target-nontarget distances so that the maximum distance is 1.
  data[,30:36] <- data[,30:36]/max(data[,30:36]) # Time
  data[,37:43] <- data[,37:43]/max(data[,37:43]) # Space
  data[,44:50] <- data[,44:50]/max(data[,44:50]) # Orthographic
  data[,51:57] <- 1-data[,51:57] # Turn semantic cosine similarity into distance (big number means less similar)
  
  
  temporal_similarity <- data.frame(matrix(nrow = nrow(data), ncol = n_intrusions))
  temporal_similarity[data$condition=='unrelated',1:7] <- lapply(data[data$condition=='unrelated',30:36], 
                                                                 temporal_shepard,
                                                                 k1 = lambda_b1, k2 = lambda_f1, tau = tau1)
  
  temporal_similarity[data$condition=='orthographic',1:7] <- lapply(data[data$condition=='orthographic',30:36], 
                                                                    temporal_shepard,
                                                                    k1 = lambda_b2, k2 = lambda_f2, tau = tau2)
  
  temporal_similarity[data$condition=='semantic',1:7] <- lapply(data[data$condition=='semantic',30:36], 
                                                                temporal_shepard,
                                                                k1 = lambda_b3, k2 = lambda_f3, tau = tau3)
  
  
  # Turn cosine distances between target and intrusions into Shepard similarity
  spatial_similarity <- data.frame(matrix(nrow = nrow(data), ncol = n_intrusions))
  spatial_similarity[data$condition=='unrelated',1:7] <- lapply(data[data$condition=='unrelated',37:43], shepard_similarity, k = zeta1)
  spatial_similarity[data$condition=='orthographic',1:7] <- lapply(data[data$condition=='orthographic',37:43], shepard_similarity, k = zeta2)
  spatial_similarity[data$condition=='semantic',1:7] <- lapply(data[data$condition=='semantic',37:43], shepard_similarity, k = zeta3)
  
  ## Add different decays for the different conditions
  orthographic_similarity <- data.frame(matrix(nrow = nrow(data), ncol = n_intrusions))
  # When the condition is unrelated, use iota 1
  orthographic_similarity[data$condition=='unrelated',1:7] <- lapply(data[data$condition=='unrelated',44:50], shepard_similarity, k = iota1)
  # When the condition is orthographic, use iota 2
  orthographic_similarity[data$condition=='orthographic',1:7] <- lapply(data[data$condition=='orthographic',44:50], shepard_similarity, k = iota2)
  # When the condition is semantic, use iota 3
  orthographic_similarity[data$condition=='semantic',1:7] <- lapply(data[data$condition=='semantic',44:50], shepard_similarity, k = iota3)
  
  # Scale semantic cosine similarity
  semantic_similarity <- data.frame(matrix(nrow = nrow(data), ncol = n_intrusions))
  semantic_similarity[data$condition=='unrelated',1:7] <- lapply(data[data$condition=='unrelated',51:57], shepard_similarity, k = upsilon1)
  semantic_similarity[data$condition=='orthographic',1:7] <- lapply(data[data$condition=='orthographic',51:57], shepard_similarity, k = upsilon2) 
  semantic_similarity[data$condition=='semantic',1:7] <- lapply(data[data$condition=='semantic',51:57], shepard_similarity, k = upsilon3) 
  
  
  # Multiply the temporal similarities with corresponding spatial similarity to get a spatiotemporal gradient on each trial, for each condition
  intrusion_weights <- data.frame(matrix(nrow = nrow(data),ncol = n_intrusions))
  
  intrusion_weights[data$condition == 'unrelated',] <- gamma1 * temporal_similarity[data$condition == 'unrelated',]^phi1 * 
    spatial_similarity[data$condition == 'unrelated',]^rho1 * 
    orthographic_similarity[data$condition == 'unrelated',]^chi1 * 
    semantic_similarity[data$condition == 'unrelated',]^psi1
  
  intrusion_weights[data$condition == 'orthographic',] <- gamma2 * temporal_similarity[data$condition == 'orthographic',]^phi2 * 
    spatial_similarity[data$condition == 'orthographic',]^rho2 * 
    orthographic_similarity[data$condition == 'orthographic',]^chi2 * 
    semantic_similarity[data$condition == 'orthographic',]^psi2
  
  intrusion_weights[data$condition == 'semantic',] <- gamma3 * temporal_similarity[data$condition == 'semantic',]^phi3 * 
    spatial_similarity[data$condition == 'semantic',]^rho3 * 
    orthographic_similarity[data$condition == 'semantic',]^chi3 * 
    semantic_similarity[data$condition == 'semantic',]^psi3
  
  colnames(intrusion_weights) <- c("weight_1", "weight_2", "weight_3", "weight_4", "weight_5", "weight_6", "weight_7")
  
  target_weight <- 1 - rowSums(intrusion_weights)
  trial_weights <- cbind(target_weight, intrusion_weights)
  
  # Multiply all weights by 1-beta, the non-guessed responses, based on the serial position of the target
  # Allow different betas for different conditions
  
  # Unrelated condition
  trial_weights[data$condition == 'unrelated',] <- trial_weights[data$condition == 'unrelated',] * (1-beta1)
  trial_weights[data$condition == 'unrelated', length(trial_weights)+1] <- beta1
  
  trial_weights[data$condition == 'orthographic',] <- trial_weights[data$condition == 'orthographic',] * (1-beta2)
  trial_weights[data$condition == 'orthographic', length(trial_weights)] <- beta2
  
  trial_weights[data$condition == 'semantic',] <- trial_weights[data$condition == 'semantic',] * (1-beta3)
  trial_weights[data$condition == 'semantic', length(trial_weights)] <- beta3
  
  # Empty dataframe to store simulated data
  sim_data <- data.frame(
    target_word = character(),
    target_angle = numeric(),
    target_position = integer(),
    intruding_angle = numeric(),
    trial_type = character(),
    simulated_response = numeric(),
    simulated_error = numeric(),
    offset_1 = numeric(),
    offset_2 = numeric(),
    offset_3 = numeric(),
    offset_4 = numeric(),
    offset_5 = numeric(),
    offset_6 = numeric(),
    offset_7 = numeric(),
    #angle_8 = numeric(),
    participant = integer(),
    lag_1 = numeric(),
    lag_2 = numeric(),
    lag_3 = numeric(),
    lag_4 = numeric(),
    lag_5 = numeric(),
    lag_6 = numeric(),
    lag_7 = numeric(),
    spatial_1 = numeric(),
    spatial_2 = numeric(),
    spatial_3 = numeric(),
    spatial_4 = numeric(),
    spatial_5 = numeric(),
    spatial_6 = numeric(),
    spatial_7 = numeric(),
    ortho_1 = numeric(),
    ortho_2 = numeric(),
    ortho_3 = numeric(),
    ortho_4 = numeric(),
    ortho_5 = numeric(),
    ortho_6 = numeric(),
    ortho_7 = numeric(),
    semantic_1 = numeric(),
    semantic_2 = numeric(),
    semantic_3 = numeric(),
    semantic_4 = numeric(),
    semantic_5 = numeric(),
    semantic_6 = numeric(),
    semantic_7 = numeric(),
    condition = character(),
    angle_1 = numeric(),
    angle_2 = numeric(),
    angle_3 = numeric(),
    angle_4 = numeric(),
    angle_5 = numeric(),
    angle_6 = numeric(),
    angle_7 = numeric(),
    angle_8 = numeric(),
    model = character(),
    stringsAsFactors = FALSE
  )
  
  nSims = 5
  this_data <- data
  # Get the angles for each trial
  block_angles <- cbind(this_data[,11], this_data[,16:22])
  intrusions <- this_data[,16:22]
  
  # Simulate each trial one by one
  for (i in 1:nrow(this_data)){
    
    # Stimulus identity
    word <- as.character(this_data$word[i])
    this_condition <- as.character(this_data$condition[i])
    target_angle <- this_data$target_angle[i]
    target_position <- this_data$present_trial[i]
    this_block_angles <- block_angles[i,]
    this_intrusions <- intrusions[i,]
    this_weights <- trial_weights[i,]
    
    this_similarities <- similarities[i,]
    
    positions <- 1:n_trials
    
    # Simulate each trial *nSims
    for (j in 1:nSims){
      sim_intrusion_position <- rmnom(1, 1, this_weights)
      # This line is a bit hacky, I'm taking the intrusion angles only [2:10], and inserting the target angle in its serial position
      no_offset_angles <- insert(as.vector(t(this_block_angles[2:8])), ats = target_position, values = target_angle)
      # See if this trial is a guess
      if(sim_intrusion_position[length(sim_intrusion_position)]){
        sim_angle <- NA
        sim_response <- runif(1, -pi, pi)
        sim_error <- angle_diff(target_angle, sim_response)
        sim_data[nrow(sim_data)+1,] <- c(word, target_angle, target_position, sim_angle, 'guess', sim_response, sim_error, this_intrusions, participant, this_similarities, this_condition, no_offset_angles, model_name)
      } else if (sim_intrusion_position[1]){
        # Decide which stimulus angle is the center of this retrieval
        sim_angle <- this_block_angles[sim_intrusion_position == 1]
        sim_response <- rvm(1, sim_angle, kappa1)
        sim_error <- angle_diff(target_angle, sim_response)
        sim_data[nrow(sim_data)+1,] <- c(word, target_angle, target_position, sim_angle, 'target', sim_response, sim_error, this_intrusions, participant, this_similarities, this_condition, no_offset_angles, model_name)
      } else {
        sim_angle <- this_block_angles[sim_intrusion_position == 1]
        sim_response <- rvm(1, sim_angle, kappa2)
        sim_error <- angle_diff(target_angle, sim_response)
        sim_data[nrow(sim_data)+1,] <- c(word, target_angle, target_position, sim_angle, 'intrusion', sim_response, sim_error, this_intrusions, participant, this_similarities, this_condition, no_offset_angles, model_name)
      }
      # Add on columns for the raw spatial, temporal, orthographic, semantic similarities for this trial
      
    }
  }
  return(sim_data)
}

# Function to compute angular difference

angle_diff <- function(a,b){
  diff <- atan2(sin(a-b), cos(a-b))
  return(diff)
}

shepard_similarity <- function(x, k){
  x <- exp(-k * x)
  return(x)
}

temporal_shepard <- function(x, k1, k2, tau){
  res <- ifelse(x < 0, x <- (1 - tau) * exp(-k1 * abs(x)), x <- tau * exp(-k2 * x))
  return(res)
}
