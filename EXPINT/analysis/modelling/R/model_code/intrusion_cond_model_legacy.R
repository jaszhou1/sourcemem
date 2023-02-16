## INTRUSION_COND_MODEL_X.R
# The problem with how I parameterised the original model (intrusion_cond_model.R)
# is that time weight (phi) is defined as 1 - the other factors. That means that
# When 

library(extraDistr)
library(CircStats)
library(circular)

intrusion_cond_model_x <- function(Pvar, data, Pfix, Sel){
  
  n_trials <- 8
  n_intrusions <- n_trials - 1
  
  # Check number of parameters
  if(length(Pvar) + length(Pfix) != 35){
    stop("Incorrect number of parameters")
  }
  
  # Assemble parameter vector from the free (to be estimated) and fixed parameters
  P <- vector(mode = "numeric", length = 35)
  
  # Example Sel vector
  #         prec.       guess    intrus.     w.time        w.space   w.orth    w.sem       time asym   d.time              d.space   d.orth    d.sem
  # Sel = c(1, 1,       1, 1, 1,  1, 1, 1,    1, 1, 1,     1, 1, 1,  1, 1, 1,  1, 1, 1,    1, 0, 0,    1, 1, 0, 0, 0, 0,   1, 0, 0,  1, 0, 0,  1, 0, 0)
  
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
  chi1 <- P[9] # item vs context, unrelated condition
  chi2 <- P[10] # orthographic
  chi3 <- P[11] # semantic
  
  phi1 <- P[12] # space vs time
  phi2 <- P[13]
  phi3 <- P[14]
  
  psi1 <- P[15] # semantic vs orthographic
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
  
  if(is.na(phi2)){
    phi2 <- phi1
  }
  
  if(is.na(phi3)){
    phi3 <- phi1
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
    lambda_f2 <- lambda_b2
  }
  
  if(is.na(lambda_b3)){
    lambda_b3 <- lambda_b1
  }
  
  if(is.na(lambda_f3)){
    lambda_f3 <- lambda_b3
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
  
  # Rescale all target-nontarget distances so that the maximum distance is 1.
  data[,30:36] <- data[,30:36]/max(data[,30:36]) # Time
  data[,37:43] <- data[,37:43]/max(data[,37:43]) # Space
  data[,44:50] <- data[,44:50]/max(data[,44:50]) # Orthographic
  data[,51:57] <- 1-data[,51:57] # Turn semantic cosine similarity into distance (big number means less similar)
  
  
  temporal_similarity <- data.frame(matrix(nrow = nrow(data), ncol = n_intrusions))
  temporal_similarity[data$condition=='unrelated',1:7] <- apply(data[data$condition=='unrelated',30:36],
                                                                c(1,2),
                                                                temporal_shepard,
                                                                k1 = lambda_b1, k2 = lambda_f1, tau = tau1) 
  
  temporal_similarity[data$condition=='orthographic',1:7] <- apply(data[data$condition=='orthographic',30:36],
                                                                   c(1,2),
                                                                   temporal_shepard,
                                                                   k1 = lambda_b2, k2 = lambda_f2, tau = tau2) 
  
  temporal_similarity[data$condition=='semantic',1:7] <- apply(data[data$condition=='semantic',30:36],
                                                               c(1,2),
                                                               temporal_shepard,
                                                               k1 = lambda_b3, k2 = lambda_f3, tau = tau3) 
  
  
  # Turn cosine distances between target and intrusions into Shepard similarity
  spatial_similarity <- data.frame(matrix(nrow = nrow(data), ncol = n_intrusions))
  spatial_similarity[data$condition=='unrelated',1:7] <- apply(data[data$condition=='unrelated',37:43],
                                                               c(1,2),
                                                               shepard_similarity, 
                                                               k = zeta1) 
  
  spatial_similarity[data$condition=='orthographic',1:7] <- apply(data[data$condition=='orthographic',37:43],
                                                                  c(1,2),
                                                                  shepard_similarity, 
                                                                  k = zeta2) 
  
  spatial_similarity[data$condition=='semantic',1:7] <- apply(data[data$condition=='semantic',37:43],
                                                              c(1,2),
                                                              shepard_similarity, 
                                                              k = zeta3) 
  
  ## Add different decays for the different conditions
  orthographic_similarity <- data.frame(matrix(nrow = nrow(data), ncol = n_intrusions))
  # When the condition is unrelated, use iota 1
  orthographic_similarity[data$condition=='unrelated',1:7] <- apply(data[data$condition=='unrelated',44:50],
                                                                    c(1,2),
                                                                    shepard_similarity, 
                                                                    k = iota1) 
  # When the condition is orthographic, use iota 2
  orthographic_similarity[data$condition=='orthographic',1:7] <- apply(
    data[data$condition=='orthographic',44:50], 
    c(1,2),
    shepard_similarity, 
    k = iota2) 
  
  # When the condition is semantic, use iota 3
  orthographic_similarity[data$condition=='semantic',1:7] <- apply(data[data$condition=='semantic',44:50], 
                                                                   c(1,2),
                                                                   shepard_similarity, 
                                                                   k = iota3) 
  
  # Scale semantic cosine similarity
  semantic_similarity <- data.frame(matrix(nrow = nrow(data), ncol = n_intrusions))
  semantic_similarity[data$condition=='unrelated',1:7] <- apply(data[data$condition=='unrelated',51:57], 
                                                                c(1,2),
                                                                shepard_similarity, 
                                                                k = upsilon1) 
  
  semantic_similarity[data$condition=='orthographic',1:7] <- apply(data[data$condition=='orthographic',51:57], 
                                                                   c(1,2),
                                                                   shepard_similarity, 
                                                                   k = upsilon2)
  
  semantic_similarity[data$condition=='semantic',1:7] <- apply(data[data$condition=='semantic',51:57], 
                                                               c(1,2),
                                                               shepard_similarity, 
                                                               k = upsilon3)
  
  
  # Normalise similarity values
  temporal_similarity <- temporal_similarity/max(temporal_similarity)
  spatial_similarity <- spatial_similarity/max(spatial_similarity)
  orthographic_similarity <- orthographic_similarity/max(orthographic_similarity)
  semantic_similarity <- semantic_similarity/max(semantic_similarity)
  
  # Multiply the temporal similarities with corresponding spatial similarity to get a spatiotemporal gradient on each trial, for each condition
  intrusion_weights <- data.frame(matrix(nrow = nrow(data),ncol = n_intrusions))
  
  intrusion_weights[data$condition == 'unrelated',] <- gamma1 * ( 
    (temporal_similarity[data$condition == 'unrelated',]^(1-phi1) * 
       spatial_similarity[data$condition == 'unrelated',]^phi1)^(1-chi1) * 
      (orthographic_similarity[data$condition == 'unrelated',]^(1-psi1) * 
         semantic_similarity[data$condition == 'unrelated',]^psi1)^chi1
  )
  
  intrusion_weights[data$condition == 'orthographic',] <- gamma2 * ( 
    (temporal_similarity[data$condition == 'orthographic',]^(1-phi2) * 
       spatial_similarity[data$condition == 'orthographic',]^phi2)^(1-chi2) * 
      (orthographic_similarity[data$condition == 'orthographic',]^(1-psi2) * 
         semantic_similarity[data$condition == 'orthographic',]^psi2)^chi2
  )
  
  intrusion_weights[data$condition == 'semantic',] <- gamma3 * ( 
    (temporal_similarity[data$condition == 'semantic',]^(1-phi3) * 
       spatial_similarity[data$condition == 'semantic',]^phi3)^(1-chi3) * 
      (orthographic_similarity[data$condition == 'semantic',]^(1-psi3) * 
         semantic_similarity[data$condition == 'semantic',]^psi3)^chi3
  )
  
  colnames(intrusion_weights) <- c("weight_1", "weight_2", "weight_3", "weight_4", "weight_5", "weight_6", "weight_7")
  
  target_weight <- 1 - rowSums(intrusion_weights)
  # Filter out zeroes, set target weight to very small
  if(any(target_weight < 0)){
    target_weight[target_weight < 0] <- 1e-7
  }
  trial_weights <- cbind(target_weight, intrusion_weights)
  trial_weights <- as.data.frame(t(apply(trial_weights,1, function(x) x/sum(x))))
  # Multiply all weights by 1-beta, the non-guessed responses, based on the serial position of the target
  # Allow different betas for different conditions
  
  # Unrelated condition
  trial_weights[data$condition == 'unrelated',] <- trial_weights[data$condition == 'unrelated',] * (1-beta1)
  trial_weights[data$condition == 'unrelated', ncol(trial_weights)+1] <- beta1
  
  trial_weights[data$condition == 'orthographic',] <- trial_weights[data$condition == 'orthographic',] * (1-beta2)
  trial_weights[data$condition == 'orthographic', ncol(trial_weights)] <- beta2
  
  trial_weights[data$condition == 'semantic',] <- trial_weights[data$condition == 'semantic',] * (1-beta3)
  trial_weights[data$condition == 'semantic', ncol(trial_weights)] <- beta3
  
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
simulate_intrusion_cond_model_x <- function(participant, data, P, model_name){
  
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
  
  chi1 <- P[[9]] # Item vs. Context weight
  chi2 <- P[[10]]
  chi3 <- P[[11]]
  
  phi1 <- P[[12]] # Space vs. Time weight
  phi2 <- P[[13]]
  phi3 <- P[[14]]
  
  psi1 <- P[[15]] # Semantic vs. Orthographic weight
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
  
  if(is.na(phi2)){
    phi2 <- phi1
  }
  
  if(is.na(phi3)){
    phi3 <- phi1
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
    lambda_f2 <- lambda_b2
  }
  
  if(is.na(lambda_b3)){
    lambda_b3 <- lambda_b1
  }
  
  if(is.na(lambda_f3)){
    lambda_f3 <- lambda_b3
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
  
  # Get an untransformed copy of the similarities
  similarities <- data[,30:57]
  
  # Rescale all target-nontarget distances so that the maximum distance is 1.
  data[,30:36] <- data[,30:36]/max(data[,30:36]) # Time
  data[,37:43] <- data[,37:43]/max(data[,37:43]) # Space
  data[,44:50] <- data[,44:50]/max(data[,44:50]) # Orthographic
  data[,51:57] <- 1-data[,51:57] # Turn semantic cosine similarity into distance (big number means less similar)
  
  
  temporal_similarity <- data.frame(matrix(nrow = nrow(data), ncol = n_intrusions))
  temporal_similarity[data$condition=='unrelated',1:7] <- apply(data[data$condition=='unrelated',30:36],
                                                                c(1,2),
                                                                temporal_shepard,
                                                                k1 = lambda_b1, k2 = lambda_f1, tau = tau1) 
  
  temporal_similarity[data$condition=='orthographic',1:7] <- apply(data[data$condition=='orthographic',30:36],
                                                                   c(1,2),
                                                                   temporal_shepard,
                                                                   k1 = lambda_b2, k2 = lambda_f2, tau = tau2) 
  
  temporal_similarity[data$condition=='semantic',1:7] <- apply(data[data$condition=='semantic',30:36],
                                                               c(1,2),
                                                               temporal_shepard,
                                                               k1 = lambda_b3, k2 = lambda_f3, tau = tau3) 
  
  
  # Turn cosine distances between target and intrusions into Shepard similarity
  spatial_similarity <- data.frame(matrix(nrow = nrow(data), ncol = n_intrusions))
  spatial_similarity[data$condition=='unrelated',1:7] <- apply(data[data$condition=='unrelated',37:43],
                                                               c(1,2),
                                                               shepard_similarity, 
                                                               k = zeta1) 
  
  spatial_similarity[data$condition=='orthographic',1:7] <- apply(data[data$condition=='orthographic',37:43],
                                                                  c(1,2),
                                                                  shepard_similarity, 
                                                                  k = zeta2) 
  
  spatial_similarity[data$condition=='semantic',1:7] <- apply(data[data$condition=='semantic',37:43],
                                                              c(1,2),
                                                              shepard_similarity, 
                                                              k = zeta3) 
  
  ## Add different decays for the different conditions
  orthographic_similarity <- data.frame(matrix(nrow = nrow(data), ncol = n_intrusions))
  # When the condition is unrelated, use iota 1
  orthographic_similarity[data$condition=='unrelated',1:7] <- apply(data[data$condition=='unrelated',44:50],
                                                                    c(1,2),
                                                                    shepard_similarity, 
                                                                    k = iota1) 
  # When the condition is orthographic, use iota 2
  orthographic_similarity[data$condition=='orthographic',1:7] <- apply(data[data$condition=='orthographic',44:50], 
                                                                       c(1,2),
                                                                       shepard_similarity, 
                                                                       k = iota2) 
  # When the condition is semantic, use iota 3
  orthographic_similarity[data$condition=='semantic',1:7] <- apply(data[data$condition=='semantic',44:50], 
                                                                   c(1,2),
                                                                   shepard_similarity, 
                                                                   k = iota3) 
  
  # Scale semantic cosine similarity
  semantic_similarity <- data.frame(matrix(nrow = nrow(data), ncol = n_intrusions))
  semantic_similarity[data$condition=='unrelated',1:7] <- apply(data[data$condition=='unrelated',51:57], 
                                                                c(1,2),
                                                                shepard_similarity, 
                                                                k = upsilon1) 
  
  semantic_similarity[data$condition=='orthographic',1:7] <- apply(data[data$condition=='orthographic',51:57], 
                                                                   c(1,2),
                                                                   shepard_similarity, 
                                                                   k = upsilon2)
  
  semantic_similarity[data$condition=='semantic',1:7] <- apply(data[data$condition=='semantic',51:57], 
                                                               c(1,2),
                                                               shepard_similarity, 
                                                               k = upsilon3)
  
  
  # Normalise similarity values
  temporal_similarity <- temporal_similarity/max(temporal_similarity)
  spatial_similarity <- spatial_similarity/max(spatial_similarity)
  orthographic_similarity <- orthographic_similarity/max(orthographic_similarity)
  semantic_similarity <- semantic_similarity/max(semantic_similarity)
  
  # Multiply the temporal similarities with corresponding spatial similarity to get a spatiotemporal gradient on each trial, for each condition
  intrusion_weights <- data.frame(matrix(nrow = nrow(data),ncol = n_intrusions))
  
  intrusion_weights[data$condition == 'unrelated',] <- gamma1 * ( 
    (temporal_similarity[data$condition == 'unrelated',]^(1-phi1) * 
       spatial_similarity[data$condition == 'unrelated',]^phi1)^(1-chi1) * 
      (orthographic_similarity[data$condition == 'unrelated',]^(1-psi1) * 
         semantic_similarity[data$condition == 'unrelated',]^psi1)^chi1
  )
  
  intrusion_weights[data$condition == 'orthographic',] <- gamma2 * ( 
    (temporal_similarity[data$condition == 'orthographic',]^(1-phi2) * 
       spatial_similarity[data$condition == 'orthographic',]^phi2)^(1-chi2) * 
      (orthographic_similarity[data$condition == 'orthographic',]^(1-psi2) * 
         semantic_similarity[data$condition == 'orthographic',]^psi2)^chi2
  )
  
  intrusion_weights[data$condition == 'semantic',] <- gamma3 * ( 
    (temporal_similarity[data$condition == 'semantic',]^(1-phi3) * 
       spatial_similarity[data$condition == 'semantic',]^phi3)^(1-chi3) * 
      (orthographic_similarity[data$condition == 'semantic',]^(1-psi3) * 
         semantic_similarity[data$condition == 'semantic',]^psi3)^chi3
  )
  
  colnames(intrusion_weights) <- c("weight_1", "weight_2", "weight_3", "weight_4", "weight_5", "weight_6", "weight_7")
  
  target_weight <- 1 - rowSums(intrusion_weights)
  # Filter out zeroes, set target weight to very small
  if(any(target_weight < 0)){
    target_weight[target_weight < 0] <- 1e-7
  }
  trial_weights <- cbind(target_weight, intrusion_weights)
  trial_weights <- as.data.frame(t(apply(trial_weights,1, function(x) x/sum(x))))
  
  # Multiply all weights by 1-beta, the non-guessed responses, based on the serial position of the target
  # Allow different betas for different conditions
  
  # Unrelated condition
  trial_weights[data$condition == 'unrelated',] <- trial_weights[data$condition == 'unrelated',] * (1-beta1)
  trial_weights[data$condition == 'unrelated', length(trial_weights)+1] <- beta1
  
  trial_weights[data$condition == 'orthographic',] <- trial_weights[data$condition == 'orthographic',] * (1-beta2)
  trial_weights[data$condition == 'orthographic', length(trial_weights)] <- beta2
  
  trial_weights[data$condition == 'semantic',] <- trial_weights[data$condition == 'semantic',] * (1-beta3)
  trial_weights[data$condition == 'semantic', length(trial_weights)] <- beta3
  
  nSims = 2
  this_data <- data
  # Get the angles for each trial
  block_angles <- cbind(this_data[,11], this_data[,16:22])
  
  this_data <- cbind(this_data, block_angles, trial_weights, similarities, model_name)
  this_data <- this_data[rep(seq_len(nrow(this_data)), each = nSims), ]
  # Simulate each trial one by one
  sim_data <- do.call("rbind", apply(this_data, MARGIN = 1, simulate_trial, kappa1, kappa2, model_name))
  sim_data <- as.data.frame(sim_data)
  
  return(sim_data)
}

simulate_trial <- function(x, kappa1, kappa2, model_name){
  word <- as.character(x[4])
  this_condition <- as.character(x[5])
  target_angle <- as.numeric(x[11])
  target_position <- as.integer(x[6])
  this_block_angles <- as.numeric(x[58:65])
  this_intrusions <- as.numeric(x[59:65])
  this_weights <- as.numeric(x[66:74])
  this_similarities <- as.numeric(x[75:102])
  participant <- as.integer(x[1])
  positions <- 1:8
  
  sim_intrusion_position <- rmnom(1, 1, this_weights)
  # This line is a bit hacky, I'm taking the intrusion angles only [2:10], and inserting the target angle in its serial position
  no_offset_angles <- insert(as.vector(t(this_block_angles[2:8])), ats = target_position, values = target_angle)
  # See if this trial is a guess
  if(sim_intrusion_position[length(sim_intrusion_position)]){
    sim_angle <- NA
    sim_response <- runif(1, -pi, pi)
    sim_error <- angle_diff(target_angle, sim_response)
    trial_type <- 'guess'
  } else if (sim_intrusion_position[1]){
    # Decide which stimulus angle is the center of this retrieval
    sim_angle <- this_block_angles[sim_intrusion_position == 1]
    sim_response <- rvm(1, sim_angle, kappa1)
    sim_error <- angle_diff(target_angle, sim_response)
    trial_type <- 'target'
  } else {
    sim_angle <- this_block_angles[sim_intrusion_position == 1]
    sim_response <- rvm(1, sim_angle, kappa2)
    sim_error <- angle_diff(target_angle, sim_response)
    trial_type <- 'intrusion'
  }
  res <- list(word, target_angle, target_position, sim_angle, trial_type, sim_response, sim_error, this_intrusions, participant, this_similarities, this_condition, no_offset_angles, model_name)
  
  res <- data.frame(lapply(res, function(x) t(data.frame(x))))
  
  cols <- c('target_word', 'target_angle', 'target_position', 'intruding_angle', 'trial_type',
            'simulated_response', 'simulated_error', 'offset_1', 'offset_2', 'offset_3',
            'offset_4', 'offset_5', 'offset_6', 'offset_7', 'participant',
            'lag_1', 'lag_2', 'lag_3', 'lag_4', 'lag_5', 'lag_6', 'lag_7',
            'spatial_1', 'spatial_2', 'spatial_3', 'spatial_4', 'spatial_5', 'spatial_6', 'spatial_7',
            'ortho_1', 'ortho_2', 'ortho_3', 'ortho_4', 'ortho_5', 'ortho_6', 'ortho_7',
            'semantic_1', 'semantic_2', 'semantic_3', 'semantic_4', 'semantic_5', 'semantic_6', 'semantic_7',
            'condition', 'angle_1', 'angle_2', 'angle_3', 'angle_4', 'angle_5', 'angle_6', 'angle_7', 'angle_8',
            'model_name')
  
  colnames(res) <- cols
  return(res)
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
