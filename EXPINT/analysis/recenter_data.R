recenter_data <- function(data){
  n_intrusions <- 7
  recentered_errors <- data.frame(matrix(ncol=8,nrow=nrow(data)*n_intrusions, 
                                         dimnames=list(NULL, c('intruding_angle', 'offset', 'lag', 'spatial', 'orthographic', 'semantic', 'participant', 'type'))))
  idx <- 1
  for (i in 1:nrow(data)){
    this_trial <- data[i,]$present_trial
    this_response_angle <- data[i,]$response_angle
    this_target_angle <- data[i,]$target_angle
    this_intrusions <- data[i,16:22]
    temporal <- data[i,30:36]
    spatial <- data[i,37:43]
    orthographic <- data[i,44:50]
    semantic <- data[i,51:57]
    for(j in 1:n_intrusions){
      recentered_errors[idx,1] <- this_intrusions[[j]]
      recentered_errors[idx,2] <- angle_diff(this_response_angle, this_intrusions[[j]])
      recentered_errors[idx,3] <- temporal[[j]]
      recentered_errors[idx,4] <- spatial[[j]]
      recentered_errors[idx,5] <- orthographic[[j]]
      recentered_errors[idx,6] <- semantic[[j]]
      recentered_errors[idx,7] <- data[i, 'participant']
      recentered_errors[idx,8] <- data[i, 'condition']
      idx <- idx + 1
    }
  }
  return(recentered_errors)
}

# Function to compute angular difference

cosine_distance <- function(theta, phi){
  distance <- 1 - cos(theta - phi)
  return(distance)
}

angle_diff <- function(a,b){
  diff <- atan2(sin(a-b), cos(a-b))
  return(diff)
}