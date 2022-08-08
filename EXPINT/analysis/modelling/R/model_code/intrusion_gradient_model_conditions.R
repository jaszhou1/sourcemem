library(extraDistr)
library(CircStats)
library(circular)
## This model is identical to the intrusion gradient model, except that it handles
# data from different conditions which affects the weighting of the different similarity
# factors, as with EXPINT (Jason's final PhD experiment).

intrusion_cond_model <- function(params, data){
  
  n_trials <- 10
  n_intrusions <- 9
  # Get parameters out from vector
  # MEMORY
  kappa1 <- params[1] # Precision, memory
  kappa2 <- params[2] # Precision, intrusion
  # GUESS
  beta <- params[3] # Proportion of guesses (weight vs. intrusion+memory)
  # INTRUSIONS
  gamma <- params[4] # Overall scaling of intrusions, this is not directly interpretable
  # Spatiotemporal
  tau <- params[5] # Temporal asymmetry (tau >0.5 means forwards are more similar)
  lambda_b <- params[6] # Similarity decay of backwards temporal lag
  lambda_f <- params[7] # Similarity decay of forwards temporal lag
  zeta <- params[8] # Similarity decay of spatial similarity
  rho <- params[9] # Weight of spatial vs temporal in spatiotemporal component
  chi1 <- params[10] # Weight of item vs spatiotemporal similarity component LOW
  chi2 <- params[11] # Weight of item HIGH
  # Item
  iota1 <- params[12] # Similarity decay of orthographic component LOW (unrelated/semantic)
  iota2 <- params[13] # Decay for orthography HIGH 
  upsilon1 <- params[14] # Similarity decay of semantic component LOW
  upsilon2 <- params[15] # Decay for semantic HIGH
  psi1 <- params[16] # Weight of semantic vs orthographic in item component BASE (unrelated)
  psi2 <- params[17] # Weight of semantic vs orthographic in item component LOW (for orthographic)
  psi3 <- params[18] # Weight of semantic HIGH (for semantic list)
  
  # Function to compute angular difference
  
  angle_diff <- function(a,b){
    diff <- atan2(sin(a-b), cos(a-b))
    return(diff)
  }
  
  shepard_similarity <- function(x, k){
    x <- exp(-k * x)
    return(x)
  }
  
  # Rescale all target-nontarget distances so that the maximum distance is 1.
  data[,30:36] <- data[,30:36]/max(data[,30:36]) # Time
  data[,37:43] <- data[,37:43]/max(data[,37:43]) # Space
  data[,44:50] <- data[,44:50]/max(data[,44:50]) # Orthographic
  data[,51:57] <- 1-data[,51:57] # Turn semantic cosine similarity into distance (big number means less similar)
  
  
  # Define a vector of raw temporal similarities
  temporal_gradient <- setNames(data.frame(matrix(ncol = n_intrusions*2, nrow = 0)), (setdiff(seq(-n_intrusions, n_intrusions), 0)/7))
  # Backwards intrusion slope
  temporal_gradient[1,1:n_intrusions] <- (1-tau)*exp(-lambda_b*(abs(-n_intrusions:-1)/max(data[,30:36])))
  # Forwards intrusion slope
  temporal_gradient[1,(n_intrusions+1):(n_intrusions*2)] <- tau*exp(-lambda_f*(abs(1:n_intrusions)/max(data[,30:36])))
  # Normalise across serial positions
  temporal_gradient <- temporal_gradient/sum(temporal_gradient)
  
  # Replace the intrusion lag positions with the normalised temporal similarities
  temporal_similarity <- data[,30:36]
  for(i in (setdiff(seq(-n_intrusions, n_intrusions), 0)/7)){
    temporal_similarity[temporal_similarity == i] <- temporal_gradient[[as.character(i)]]
  }
  
  # Turn cosine distances between target and intrusions into Shepard similarity
  spatial_similarity <- data.frame(matrix(nrow = nrow(data), ncol = n_intrusions))
  spatial_similarity[,1:7] <- lapply(data[,37:43], shepard_similarity, k = zeta)
  
  ## Add different decays for the different conditions
  orthographic_similarity <- data.frame(matrix(nrow = nrow(data), ncol = n_intrusions))
  # When the condition is NOT orthographic, use iota 1
  orthographic_similarity[data$condition!='orthographic',1:7] <- lapply(data[,44:50], shepard_similarity, k = iota1)
  # When the condition is orthographic, use iota 2
  orthographic_similarity[data$condition=='orthographic',1:7] <- lapply(data[,44:50], shepard_similarity, k = iota2)
  
  # Scale semantic cosine similarity
  semantic_similarity <- data.frame(matrix(nrow = nrow(data), ncol = n_intrusions))
  semantic_similarity[data$condition!='semantic',1:7] <- lapply(data[,51:57], shepard_similarity, k = upsilon1)
  semantic_similarity[data$condition=='semantic',1:7] <- lapply(data[,51:57], shepard_similarity, k = upsilon2) 
  
  
  # Multiply the temporal similarities with corresponding spatial similarity to get a spatiotemporal gradient on each trial
  intrusion_weights <- data.frame(matrix(nrow = nrow(data),ncol = n_intrusions))
  
  intrusion_weights[data$condition == 'unrelated',] <- ((temporal_similarity^(1-rho)) * (spatial_similarity^rho))^(1-chi1) * ((orthographic_similarity^(1-psi1)) * (semantic_similarity^psi1))^(chi1)
  intrusion_weights[data$condition == 'orthographic',] <- ((temporal_similarity^(1-rho)) * (spatial_similarity^rho))^(1-chi2) * ((orthographic_similarity^(1-psi2)) * (semantic_similarity^psi2))^(chi2)
  intrusion_weights[data$condition == 'semantic',] <- ((temporal_similarity^(1-rho)) * (spatial_similarity^rho))^(1-chi2) * ((orthographic_similarity^(1-psi3)) * (semantic_similarity^psi3))^(chi2)
  # Multiply all intrusion weights with overall intrusion scaling parameter
  intrusion_weights <- gamma*intrusion_weights
  
  colnames(intrusion_weights) <- c("weight_1", "weight_2", "weight_3", "weight_4", "weight_5", "weight_6", "weight_7")
  
  target_weight <- 1 - rowSums(intrusion_weights)
  trial_weights <- cbind(target_weight, intrusion_weights)
  
  # Multiply all weights by 1-beta, the non-guessed responses, based on the serial position of the target
  # Different betas for primacy and recency items
  
  trial_weights <- trial_weights * (1-beta)
  trial_weights[, length(trial_weights)+1] <- beta
  
  
  # Make sure all weights are positive numbers
  if(any(trial_weights < 0)){
    print("Invalid: Negative weight")
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
  
  # This is still a loop, cant figure out how to use lapply using the columns 12:21 (weights) as an argument for weighted.mean function
  # I think vectorising this part of the code is the limiting factor in making this code run much faster
  likelihoods$weighted_likelihood <- NA
  for(i in 1:nrow(likelihoods)){
    weighted_like <- weighted.mean(likelihoods[i,2:10], likelihoods[i, 11:19])
    if (weighted_like < 1e-10){
      weighted_like <- 1e-10
    }
    likelihoods$weighted_likelihood[i] <- weighted_like
  }
  
  nLL <- -sum(log(likelihoods$weighted_likelihood))
  return(nLL)
}



# pest = temp[participant,5:9]

# Simulate data from fitted parameters of the temporal gradient model
simulate_intrusion_cond_model <- function(participant, data, pest){
  
  # Check that trial numbers are 1-indexed
  if(min(data$present_trial) == 0){
    data$present_trial <- data$present_trial + 1
  }
  
  n_trials <- 10
  n_intrusions <- 9 
  
  # Parameters
  kappa1 <- params[[1]] # Precision, memory
  kappa2 <- params[[2]] # Precision, intrusion
  beta <- params[[3]] # Proportion of guesses (weight vs. intrusion+memory)
  gamma <- params[[4]] # Overall scaling of intrusions, this is not directly interpretable
  tau <- params[[5]] # Temporal asymmetry (tau >0.5 means forwards are more similar)
  lambda_b <- params[[6]] # Similarity decay of backwards temporal lag
  lambda_f <- params[[7]] # Similarity decay of forwards temporal lag
  zeta <- params[[8]] # Similarity decay of spatial similarity
  rho <- params[[9]] # Weight of spatial vs temporal in spatiotemporal component
  chi <- params[[10]] # Weight of item vs spatiotemporal similarity component
  iota <- params[[11]] # Similarity decay of orthographic component
  upsilon <- params[[12]] # Similarity decay of semantic component
  psi <- params[[13]] # Weight of semantic vs orthographic in item component
  
  
  shepard_similarity <- function(x, k){
    x <- exp(-k * x)
    return(x)
  }
  
  # Rescale all target-nontarget distances so that the maximum distance is 1.
  data[,30:36] <- data[,30:36]/max(data[,30:36]) # Time
  data[,37:43] <- data[,37:43]/max(data[,37:43]) # Space
  data[,44:50] <- data[,44:50]/max(data[,44:50]) # Orthographic
  data[,51:57] <- 1-data[,51:57] # Turn semantic cosine similarity into distance (big number means less similar)
  
  
  # Define a vector of raw temporal similarities
  temporal_gradient <- setNames(data.frame(matrix(ncol = n_intrusions*2, nrow = 0)), (setdiff(seq(-n_intrusions, n_intrusions), 0)/7))
  # Backwards intrusion slope
  temporal_gradient[1,1:n_intrusions] <- (1-tau)*exp(-lambda_b*(abs(-n_intrusions:-1)/max(data[,30:36])))
  # Forwards intrusion slope
  temporal_gradient[1,(n_intrusions+1):(n_intrusions*2)] <- tau*exp(-lambda_f*(abs(1:n_intrusions)/max(data[,30:36])))
  # Normalise across serial positions
  temporal_gradient <- temporal_gradient/sum(temporal_gradient)
  
  # Replace the intrusion lag positions with the normalised temporal similarities
  temporal_similarity <- data[,30:36]
  for(i in (setdiff(seq(-n_intrusions, n_intrusions), 0)/7)){
    temporal_similarity[temporal_similarity == i] <- temporal_gradient[[as.character(i)]]
  }
  
  # Turn cosine distances between target and intrusions into Shepard similarity
  spatial_similarity <- data.frame(matrix(nrow = nrow(data), ncol = n_intrusions))
  spatial_similarity[,1:7] <- lapply(data[,37:43], shepard_similarity, k = zeta)
  
  # Turn levenshtein distance into similarity
  orthographic_similarity <- data.frame(matrix(nrow = nrow(data), ncol = n_intrusions))
  orthographic_similarity[,1:7] <- lapply(data[,44:50], shepard_similarity, k = iota)
  
  # Scale semantic cosine similarity
  semantic_similarity <- data.frame(matrix(nrow = nrow(data), ncol = n_intrusions))
  semantic_similarity[,1:7] <- lapply(data[,51:57], shepard_similarity, k = upsilon) 
  
  
  # Multiply the temporal similarities with corresponding spatial similarity to get a spatiotemporal gradient on each trial
  intrusion_weights <- ((temporal_similarity^(1-rho)) * (spatial_similarity^rho))^(1-chi) * ((orthographic_similarity^(1-psi)) * (semantic_similarity^psi))^(chi)
  
  # Multiply all intrusion weights with overall intrusion scaling parameter
  intrusion_weights <- gamma*intrusion_weights
  
  colnames(intrusion_weights) <- c("weight_1", "weight_2", "weight_3", "weight_4", "weight_5", "weight_6", "weight_7")
  
  target_weight <- 1 - rowSums(intrusion_weights)
  trial_weights <- cbind(target_weight, intrusion_weights)
  
  # Make sure all weights are positive numbers
  if(any(trial_weights < 0)){
    print("Invalid: Negative weight")
    nLL <- 1e7
    return(nLL)
  }
  # Multiply all weights by 1-beta, the non-guessed responses, based on the serial position of the target
  # Different betas for primacy and recency items
  
  trial_weights <- trial_weights * (1-beta)
  trial_weights[, length(trial_weights)+1] <- beta
  
  # Empty dataframe to store simulated data
  sim_data <- data.frame(
    target_word = character(),
    target_angle = numeric(),
    target_position = integer(),
    simulated_response = numeric(),
    simulated_error = numeric(),
    angle_1 = numeric(),
    angle_2 = numeric(),
    angle_3 = numeric(),
    angle_4 = numeric(),
    angle_5 = numeric(),
    angle_6 = numeric(),
    angle_7 = numeric(),
    angle_8 = numeric(),
    participant = integer(),
    stringsAsFactors = FALSE
  )
  
  nSims = 20
  this_data <- data
  # Get the angles for each trial
  block_angles <- cbind(this_data[,11], this_data[,16:22])
  
  # Simulate each trial one by one
  for (i in 1:nrow(this_data)){
    
    # Stimulus identity
    word <- as.character(this_data$word[i])
    target_angle <- this_data$target_angle[i]
    target_position <- this_data$present_trial[i]
    this_block_angles <- block_angles[i,]
    this_weights <- trial_weights[i,]
    
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
        sim_data[nrow(sim_data)+1,] <- c(word, target_angle, target_position, sim_response, sim_error, no_offset_angles, participant)
      } else if (sim_intrusion_position[1]){
        # Decide which stimulus angle is the center of this retrieval
        sim_angle <- this_block_angles[sim_intrusion_position == 1]
        sim_response <- rvm(1, sim_angle, kappa1)
        sim_error <- angle_diff(target_angle, sim_response)
        sim_data[nrow(sim_data)+1,] <- c(word, target_angle, target_position, sim_response, sim_error, no_offset_angles, participant)
      } else {
        sim_angle <- this_block_angles[sim_intrusion_position == 1]
        sim_response <- rvm(1, sim_angle, kappa2)
        sim_error <- angle_diff(target_angle, sim_response)
        sim_data[nrow(sim_data)+1,] <- c(word, target_angle, target_position, sim_response, sim_error, no_offset_angles, participant)
      }
    }
  }
  sim_data[2:13]  <- lapply(sim_data[2:13], as.numeric)
  return(sim_data)
}
