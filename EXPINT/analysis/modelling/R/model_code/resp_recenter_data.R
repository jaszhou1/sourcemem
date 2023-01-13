cosine_distance <- function(theta, phi){
  distance <- 1 - cos(theta - phi)
  return(distance)
}

angle_diff <- function(a,b){
  diff <- atan2(sin(a-b), cos(a-b))
  return(diff)
}

# Functions that recenter the data on intrusions
recenter.data <- function(data){
  data <- na.omit(data)
  n_intrusions <- 7
  recentered_errors <- data.frame(matrix(ncol=10,nrow=nrow(data)*n_intrusions, 
                                         dimnames=list(NULL, c('participant', 'cond',
                                                               'intruding_angle', 'offset', 
                                                               'lag', 'spatial', 
                                                               'orthographic', 'semantic',
                                                               'spatial_bin', 'semantic_bin'))))
  idx <- 1
  for (i in 1:nrow(data)){
    this_trial <- data[i,]$target_position
    this_response_angle <- data[i,]$response_angle
    this_target_angle <- data[i,]$target_angle
    this_intrusions <- data[i,16:22]
    temporal <- data[i,30:36]
    spatial <- data[i,37:43]
    orthographic <- data[i,44:50]
    semantic <- 1-data[i,51:57]
    for(j in 1:n_intrusions){
      recentered_errors[idx,1] <- data[i, 'participant']
      recentered_errors[idx,2] <- data[i, 'condition']
      recentered_errors[idx,3] <- this_intrusions[[j]]
      recentered_errors[idx,4] <- angle_diff(this_response_angle, this_intrusions[[j]])
      recentered_errors[idx,5] <- temporal[[j]]
      recentered_errors[idx,6] <- spatial[[j]] ##Note the "1-", for all others small number
      # means more similar, while its reverse for
      # semantic, which is a cosine similarity
      recentered_errors[idx,7] <- orthographic[[j]]
      recentered_errors[idx,8] <- semantic[[j]]
      idx <- idx + 1
    }
  }
  # Discretise the spatial and semantic columns for some rough plots
  n_bins <- 5
  sem_bins <- quantile(recentered_errors$semantic, seq(0, 1, length =n_bins), na.rm = TRUE)
  spatial_bins <- quantile(recentered_errors$spatial, seq(0, 1, length = n_bins), na.rm = TRUE)
  for(i in 1:(n_bins-1)){
    recentered_errors[(recentered_errors$spatial >= spatial_bins[[i]]&
                         recentered_errors$spatial <= spatial_bins[[i+1]]),
                      'spatial_bin'] <- i
    recentered_errors[(recentered_errors$semantic >= sem_bins[[i]]&
                         recentered_errors$semantic <= sem_bins[[i+1]]),
                      'semantic_bin'] <- i
  }
  return(recentered_errors)
}

# Different function for simulated dataset, because the indexing is different
recenter.trial <- function(x){
  recentered_errors <- data.frame(matrix(ncol=11,nrow=7, 
                                         dimnames=list(NULL, c('participant', 'cond',
                                                               'intruding_angle', 'offset', 
                                                               'lag', 'spatial', 
                                                               'orthographic', 'semantic',
                                                               'spatial_bin', 'semantic_bin',
                                                               'model'))))
  # This function takes in data for one trial, and calculates the difference between 
  # the response angle and each non-target angle, along with similarity measures
  this_response_angle <- as.numeric(x[6])
  this_target_angle <- as.numeric(x[2])
  this_intrusions <- as.numeric(x[8:14])
  temporal <- as.numeric(x[16:22])
  spatial <- as.numeric(x[23:29])
  orthographic <- as.numeric(x[30:36])
  semantic <- 1- as.numeric(x[37:43])
  for(i in 1:7){
    recentered_errors[i,1] <- as.integer(x[15])
    recentered_errors[i,2] <- x[44]
    recentered_errors[i,3] <- this_intrusions[[i]]
    recentered_errors[i,4] <- angle_diff(this_response_angle, this_intrusions[[i]])
    recentered_errors[i,5] <- temporal[[i]]
    recentered_errors[i,6] <- spatial[[i]] ##Note the "1-", for all others small number
    # means more similar, while its reverse for
    # semantic, which is a cosine similarity
    recentered_errors[i,7] <- orthographic[[i]]
    recentered_errors[i,8] <- semantic[[i]]
    # Leave out the bins, for semantics and space, calculate those after the rest have been assembled
    recentered_errors[i, 11] <- x[53]
  }
  return(recentered_errors)
}

recenter.model2 <- function(sim_data){
  recentered_errors <- do.call("rbind", apply(sim_data, MARGIN = 1, recenter.trial))
  # Discretise the spatial and semantic columns for some rough plots
  n_bins <- 5
  sem_bins <- quantile(recentered_errors$semantic, seq(0, 1, length =n_bins), na.rm = TRUE)
  spatial_bins <- quantile(recentered_errors$spatial, seq(0, 1, length = n_bins), na.rm = TRUE)
  for(i in 1:(n_bins-1)){
    recentered_errors[(recentered_errors$spatial >= spatial_bins[[i]]&
                         recentered_errors$spatial <= spatial_bins[[i+1]]),
                      'spatial_bin'] <- i
    recentered_errors[(recentered_errors$semantic >= sem_bins[[i]]&
                         recentered_errors$semantic <= sem_bins[[i+1]]),
                      'semantic_bin'] <- i
  }
  return(recentered_errors)
}


recenter.model <- function(data, model){
  n_intrusions <- 7
  recentered_errors <- data.frame(matrix(ncol=11,nrow=nrow(data)*n_intrusions, 
                                         dimnames=list(NULL, c('participant', 'cond',
                                                               'intruding_angle', 'offset', 
                                                               'lag', 'spatial', 
                                                               'orthographic', 'semantic',
                                                               'spatial_bin', 'semantic_bin',
                                                               'model'))))
  idx <- 1
  for (i in 1:nrow(data)){
    this_trial <- data[i, 5]
    # Response angle for model should be the simulated response
    # Because simulation is expressed as error, simply add error to the target angle
    # to get what the simulated response angle was, for the purposes of recentering.
    # IGNORE the "response angle" column, thats just the observed response for that trial
    # and will just replicate the data, obviously.
    
    ## Change these indices to reflect the response error model
    this_response_angle <- data[i,]$simulated_response
    this_target_angle <- data[i,]$target_angle
    this_intrusions <- data[i,8:14]
    temporal <- data[i,16:22]
    spatial <- data[i,23:29]
    orthographic <- data[i,30:36]
    semantic <- 1-data[i,37:43]
    for(j in 1:n_intrusions){
      recentered_errors[idx,1] <- data[i, 'participant']
      recentered_errors[idx,2] <- data[i, 'condition']
      recentered_errors[idx,3] <- this_intrusions[[j]]
      recentered_errors[idx,4] <- angle_diff(this_response_angle, this_intrusions[[j]])
      recentered_errors[idx,5] <- temporal[[j]]
      recentered_errors[idx,6] <- spatial[[j]] ##Note the "1-", for all others small number
      # means more similar, while its reverse for
      # semantic, which is a cosine similarity
      recentered_errors[idx,7] <- orthographic[[j]]
      recentered_errors[idx,8] <- semantic[[j]]
      idx <- idx + 1
    }
  }
  # Discretise the spatial and semantic columns for some rough plots
  n_bins <- 5
  sem_bins <- quantile(recentered_errors$semantic, seq(0, 1, length =n_bins), na.rm = TRUE)
  spatial_bins <- quantile(recentered_errors$spatial, seq(0, 1, length = n_bins), na.rm = TRUE)
  for(i in 1:(n_bins-1)){
    recentered_errors[(recentered_errors$spatial >= spatial_bins[[i]]&
                         recentered_errors$spatial <= spatial_bins[[i+1]]),
                      'spatial_bin'] <- i
    recentered_errors[(recentered_errors$semantic >= sem_bins[[i]]&
                         recentered_errors$semantic <= sem_bins[[i+1]]),
                      'semantic_bin'] <- i
  }
  recentered_errors$model <- model
  return(recentered_errors)
}


## Old code for comparison
# 
# recenter_model <- function(filter, this_data, model){
#   sim_errors <- data.frame()
#   idx <- 1
#   for (i in 1:nrow(this_data)){
#     this_trial <- as.numeric(this_data[i,]$target_position)
#     this_response_angle <- as.numeric(this_data[i,]$simulated_response)
#     this_intrusions <- this_data[i, 6:15]
#     for (j in 1:filter){
#       if (this_trial + filter <= n_intrusions){
#         this_intrusion <- as.numeric(this_intrusions[[this_trial+j]])
#         this_offset <- angle_diff(this_response_angle, this_intrusion)
#         sim_errors[idx,1] <- this_offset
#         sim_errors[idx,2] <- 'forwards'
#         sim_errors[idx,3] <- this_data[i,]$participant
#         idx <- idx + 1
#       }
#       if (this_trial - filter > 0){
#         this_intrusion <- as.numeric(this_intrusions[[this_trial-j]])
#         this_offset <- angle_diff(this_response_angle, this_intrusion)
#         sim_errors[idx,1] <- this_offset
#         sim_errors[idx,2] <- 'backwards'
#         sim_errors[idx,3] <- this_data[i,]$participant
#         idx <- idx + 1
#       }
#     }
#   }
#   colnames(sim_errors) <- c('error', 'direction')
#   sim_errors$model <- model
#   sim_errors$filter <- filter
#   return(sim_errors)
# }
# 
# generate_recentered_dataset <- function(data){
#   recentered_dataset <- data.frame()
#   for(i in 1:3){
#     # Filter 1 - 3
#     this_recenter_data <- recenter_data(i, data)
#     recentered_dataset <- rbind(recentered_dataset, this_recenter_data)  
#   }
#   return(recentered_dataset)
# }