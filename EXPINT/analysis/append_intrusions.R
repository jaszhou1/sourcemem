# Append intrusion offsets and similarity information to the dataframe
# Load in word2vec semantic vectors
word2vec <- fromJSON(file = '~/git/sourcemem/EXPINT/experiment_stimuli/word2vec_final.json')


append_intrusions <- function(data){
  num_intrusions <- 7 # This is n-1 where n is number of trials per block
  
  intrusion_labels <- vector()
  for (i in 1:num_intrusions){
    intrusion_labels[i] <- sprintf('angle_%i',i)
  }
  
  intrusion_offset_labels <- vector()
  for (i in 1:num_intrusions){
    intrusion_offset_labels[i] <- sprintf('offset%i',i)
  }
  
  intrusion_lag_labels <- vector()
  for (i in 1:num_intrusions){
    intrusion_lag_labels[i] <- sprintf('lag%i',i)
  }
  
  spatial_labels <- vector()
  for (i in 1:num_intrusions){
    spatial_labels[i] <- sprintf('spatial%i',i)
  }
  
  ortho_labels <- vector()
  for (i in 1:num_intrusions){
    ortho_labels[i] <- sprintf('ortho%i',i)
  }
  
  semantic_labels <- vector()
  for (i in 1:num_intrusions){
    semantic_labels[i] <- sprintf('semantic%i',i)
  }
  
  intrusions <- data.frame(matrix(ncol=num_intrusions,nrow=nrow(data)))
  colnames(intrusions) <- intrusion_labels
  
  intrusion_offsets <- data.frame(matrix(ncol=num_intrusions,nrow=nrow(data)))
  colnames(intrusion_offsets) <- intrusion_offset_labels
  
  intrusion_lags <- data.frame(matrix(ncol=num_intrusions,nrow=nrow(data)))
  colnames(intrusion_lags) <- intrusion_lag_labels
  
  intrusion_spatial <- data.frame(matrix(ncol=num_intrusions,nrow=nrow(data)))
  colnames(intrusion_spatial) <- spatial_labels
  
  intrusion_ortho <- data.frame(matrix(ncol=num_intrusions,nrow=nrow(data)))
  colnames(intrusion_ortho) <- ortho_labels
  
  intrusion_semantic <- data.frame(matrix(ncol=num_intrusions,nrow=nrow(data)))
  colnames(intrusion_semantic) <- semantic_labels
  
  for (i in 1:nrow(data)){
    if(data$is_stimulus[i] == FALSE){
      intrusions[i,] <- NA
      intrusion_offsets[i,] <- NA
      intrusion_lags[i,] <- NA
      intrusion_spatial[i,] <- NA
      intrusion_ortho[i,] <- NA
      intrusion_semantic[i,] <- NA
    } else {
      this_block_data <- data[data$block == data$block[i],]
      # The possible intrusions are items in the same block as this trial, but do not have the same stimulus word
      this_block_intrusions <- this_block_data[(this_block_data$word != data$word[i]) & 
                                                 (this_block_data$is_stimulus == TRUE),]
      this_intrusions <- this_block_intrusions$target_angle
      this_intrusion_offsets <- angle_diff(data$target_angle[i], this_intrusions)
      this_intrusion_lags <- this_block_intrusions$present_trial - data$present_trial[i]
      this_trial_spatial <- cosine_distance(data$target_angle[i], this_intrusions)
      ## Have to handle orthographic and semantic similarity differently- functions not vectorised
      idx <- 1
      this_trial_orthographic <- c()
      this_trial_semantic <- c()
      for(j in 1:nrow(this_block_intrusions)){
        this_intruding_word <- this_block_intrusions$word[j]
        
        # Find the levenshtein distance between the target word and intruding word
        # Since all stimuli are 4 letters, the maximum distance is 4 (swapping all letters)
        str_dist = stringdist(data$word[i], this_intruding_word, method = 'dl')
        this_trial_orthographic[idx] <- str_dist
        if (is.null(word2vec[[tolower(this_intruding_word)]])){
          browser()
        }
        semantic_dist = cosine(word2vec[[tolower(data$word[i])]], word2vec[[tolower(this_intruding_word)]])
        
        # Truncate semantic similarity at 0, per Adam's email (alternative is to shift all values by largest minimum value)
        if (semantic_dist < 0){
          semantic_dist <- 0
        }
        
        this_trial_semantic[idx] <- semantic_dist
        idx <- idx + 1
      }
      
      if (data$block[i] == -1){
        this_intrusions <- c(this_intrusions, NA, NA, NA, NA)
        this_intrusion_offsets <- c(this_intrusion_offsets, NA, NA, NA, NA) # Filling up with NAs for practice block
        this_intrusion_lags <- c(this_intrusion_lags, NA, NA, NA, NA)
        this_trial_spatial <- c(this_trial_spatial, NA, NA, NA, NA)
        this_trial_orthographic <- c(this_trial_orthographic, NA, NA, NA, NA)
        this_trial_semantic <- c(this_trial_semantic, NA, NA, NA, NA)
      }
      intrusions[i,] <- this_intrusions
      intrusion_offsets[i,] <- this_intrusion_offsets
      intrusion_lags[i,] <- this_intrusion_lags
      intrusion_spatial[i,] <- this_trial_spatial
      intrusion_ortho[i,] <- this_trial_orthographic
      intrusion_semantic[i,] <- this_trial_semantic
    }
  }
  data <- cbind(data,intrusions, intrusion_offsets, intrusion_lags, intrusion_spatial, intrusion_ortho, intrusion_semantic)
  return(data)
}