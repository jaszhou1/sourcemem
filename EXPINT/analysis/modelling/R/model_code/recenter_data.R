cosine_distance <- function(theta, phi){
  distance <- 1 - cos(theta - phi)
  return(distance)
}

angle_diff <- function(a,b){
  diff <- atan2(sin(a-b), cos(a-b))
  return(diff)
}

# Functions that recenter the data on intrusions
recenter_data <- function(data){
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

# RECENTER_MODEL
# functions identically to recenter_data, but handles the different column indexing
# associated with the model simulation functions

recenter_model <- function(data, model){
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
  return(recentered_errors)
}

