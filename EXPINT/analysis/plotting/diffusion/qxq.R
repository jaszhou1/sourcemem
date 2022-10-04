qxq <- function(data, rt_quantile, error_quantiles, model_string, participant){
  if(missing(participant)){
    participant <- 'Group'
  } else {
    data <- data[data$participant == participant,]
  }
  # Covert response error to absolute, because we dont care about asymmetry alone y axis
  data$source_error <- abs(data$source_error)
  # Order data by absolute response error
  data <- data[order(data$source_error),]
  # Find response error quantiles
  this_error_quantiles <- quantile(data$source_error, probs = error_quantiles)
  # Sort data into bins based on quantiles
  res <- data.frame()
  for (i in 1:length(this_error_quantiles)){
    this_qq <- data.frame(matrix(nrow = length(rt_quantiles), ncol = 5))
    colnames(this_qq) <- c('theta', 'rt', 'theta_q', 'rt_q', 'model')
    # Calculate RT quantiles for this bin of responses
    if(i == 1){
      this_bin <- data[data$source_error < this_error_quantiles[[i]],]
    } else{
      this_bin <- data[((data$source_error > this_error_quantiles[[i-1]])) & 
                         (data$source_error < this_error_quantiles[[i]]),]
    }
    this_rt_quantiles <- quantile(this_bin$source_RT, probs = rt_quantiles)
    # Populate dataframe with requisite information for plot
    this_qq[,1] <- this_error_quantiles[[i]]
    this_qq[,2] <- this_rt_quantiles
    this_qq[,3] <- error_quantiles[[i]]
    this_qq[,4] <- rt_quantiles
    this_qq[,5] <- model_string
    this_qq[,6] <- participant
    res <- rbind(res, this_qq)
  }
  return(res)
}

qxq.cond <- function(data, rt_quantile, error_quantiles, model_string, participant){
  if(missing(participant)){
    participant <- 'Group'
  } else {
    data <- data[data$participant == participant,]
  }
  # Covert response error to absolute, because we dont care about asymmetry alone y axis
  data$source_error <- abs(data$source_error)
  res <- data.frame()
  for(cond in unique(data$condition)){
    this_data <- data[data$condition == cond,]
    # Order data by absolute response error
    this_data <- this_data[order(this_data$source_error),]
    # Find response error quantiles
    this_error_quantiles <- quantile(this_data$source_error, probs = error_quantiles)
    # Sort data into bins based on quantiles
    for (i in 1:length(this_error_quantiles)){
      this_qq <- data.frame(matrix(nrow = length(rt_quantiles), ncol = 9))
      colnames(this_qq) <- c('theta', 'rt', 'theta_q', 'rt_q', 'rt_lower', 'rt_upper',
                             'model', 'cond', 'participant')
      # Calculate RT quantiles for this bin of responses
      if(i == 1){
        this_bin <- this_data[this_data$source_error < this_error_quantiles[[i]],]
      } else{
        this_bin <- this_data[((this_data$source_error > this_error_quantiles[[i-1]])) & 
                           (this_data$source_error < this_error_quantiles[[i]]),]
      }
      this_rt_quantiles <- quantile(this_bin$source_RT, probs = rt_quantiles)
      this_rt_CI <- bootstrap_quantiles(this_bin$source_RT, 1000)
      # Populate dataframe with requisite information for plot
      this_qq[,1] <- this_error_quantiles[[i]]
      this_qq[,2] <- this_rt_quantiles
      this_qq[,3] <- error_quantiles[[i]]
      this_qq[,4] <- rt_quantiles
      this_qq[,5] <- this_rt_CI[1]
      this_qq[,6] <- this_rt_CI[2]
      this_qq[,7] <- model_string
      this_qq[,8] <- cond
      this_qq[,9] <- participant
      res <- rbind(res, this_qq)
    }
  }
  return(res)
}


## Some jank confidence interval stuff
bootstrap_quantiles <- function(this_data, n){
  quantiles <- data.frame(matrix(nrow = n, ncol = length(rt_quantiles)))
  for(i in 1:n){
    # Sample with replacement and calculate RT quantiles for this sample
    boot <- sample(1:length(this_data), length(this_data), replace=TRUE)
    boot_sample <- this_data[boot]
    this_sample_quantile <- quantile(boot_sample, probs = rt_quantiles)
    quantiles[i, 1:length(rt_quantiles)] <- this_sample_quantile
  }
  colnames(quantiles) <- rt_quantiles
  
  # Find the 95% CI for each RT quantile
  CI <- data.frame(matrix(nrow = length(rt_quantiles), ncol = 2))
  for(i in 1:length(rt_quantiles)){
    this_quantile <- quantiles[,i]
    this_CI <- quantile(this_quantile, probs = c(0.05, 0.95))
    CI[i,] <- this_CI
  }
  return(CI)
}