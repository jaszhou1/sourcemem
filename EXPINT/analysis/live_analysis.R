## Live analyses to monitor how participants are tracking with each session

## Connection parameters
SERVER.BASE.URL <- "https://jzhou-sourcemem-online.appspot.com"
SERVER.PORT <- NULL
SERVER.MASTER.API.KEY <- "zjFdXfQ64sgAVwQMx84IhzqzUPygpSguUkeLKLqQBIyxo8kP3yphBqF9ysd4IQsA" # <-- This needs to be in agreement with
# whatever is on the server.
#####
setwd("~/git/sourcemem/EXPINT/analysis")
source("access-data.R")

library(stringdist)
library(rjson)
library(lsa)

# Load in semantic vectors
setwd("~/git/sourcemem/EXPINT/data")

# Load in word2vec semantic vectors
word2vec <- fromJSON(file = '~/git/sourcemem/EXPINT/experiment_stimuli/word2vec_final.json')

# Function to compute angular difference

cosine_distance <- function(theta, phi){
  distance <- 1 - cos(theta - phi)
  return(distance)
}

angle_diff <- function(a,b){
  diff <- atan2(sin(a-b), cos(a-b))
  return(diff)
}

## Get the started users
started.users <- get.started.users(SERVER.BASE.URL, SERVER.PORT,
                                   SERVER.MASTER.API.KEY)

completed.users <- get.completed.users(SERVER.BASE.URL, SERVER.PORT,
                                   SERVER.MASTER.API.KEY)
## GET DATA
get_session <- function(p,s){
  
  this.session.data <- get.session.data.by.user.id(SERVER.BASE.URL, p, s,
                                                   SERVER.PORT, SERVER.MASTER.API.KEY)
  ## Extract the required information for each stimuli across the trial types.
  data <- data.frame(matrix(ncol=15,nrow= 0, dimnames=list(NULL, c("participant", "session", "block", 
                                                                   "word", "condition", "present_trial",
                                                                   "is_stimulus", "recog_rating", "recognised", 
                                                                   "recog_RT","target_angle","response_angle", 
                                                                   "source_error","source_RT", "valid_RT"))))
  
  list.to.dataframe <- function(list){
    res <- data.frame(matrix(unlist(list), nrow=length(list), byrow=TRUE),stringsAsFactors=FALSE)
    column.names <- names(list[[1]])
    column.names <- column.names[!(column.names %in% 'key')]
    colnames(res) <- column.names
    return(res)
  }
  # Finding it a bit hard to index the list of lists, so transform each list of trial type into a separate dataframe
  present.trials <- list.to.dataframe(this.session.data$present_trials)
  recognition.trials <- list.to.dataframe(this.session.data$confidence_trials)
  recall.trials <- list.to.dataframe(this.session.data$recall_trials)
  
  blocks <- unique(present.trials$block)
  for(i in 1:length(blocks)){
    this.block.data <- data.frame(matrix(ncol=15,nrow= 0, dimnames=list(NULL, c("participant", "session", "block",
                                                                                "word", "condition", "present_trial",
                                                                                "is_stimulus", "recog_rating", "recognised",
                                                                                "recog_RT","target_angle","response_angle",
                                                                                "source_error","source_RT", "valid_RT"))),
                                  stringsAsFactors=FALSE)
    this.block <- blocks[i]
    this.block.present <- present.trials[present.trials$block == this.block,]
    this.block.recognition <- recognition.trials[recognition.trials$block == this.block,]
    this.block.recall <- recall.trials[recall.trials$block == this.block,]
    
    this.block.stim <- this.block.present$target_word
    this.block.foil <- this.block.recognition[this.block.recognition$stim == FALSE, 'stimulus']
    
    for(j in this.block.stim){
      # Get all the information across experimental phases for this trial stimulus
      this.trial.present <- this.block.present[this.block.present$target_word == j,]
      this.trial.recognition <- this.block.recognition[this.block.recognition$stimulus == j,]
      this.trial.recall <- this.block.recall[this.block.recall$target_word == j,]
      
      # Transform recognition input into categories
      if(this.trial.recognition$response %in% c(1,2,3)){
        this.recog <- FALSE
      } else if (this.trial.recognition$response %in% c(8,9,0)){
        this.recog <- TRUE
      }
      
      # Determine if this trial source RT was valid
      this.trial.valid <- (this.trial.recall$num_fast_attempts == 0 &&
                             this.trial.recall$num_slow_attempts == 0)
      
      this.block.data[nrow(this.block.data)+1, ] <- c(p, s, this.trial.present$block, 
                                                      this.trial.present$target_word, 
                                                      this.trial.present$cond,
                                                      this.trial.present$trial,
                                                      this.trial.present$stim,
                                                      this.trial.recognition$response,
                                                      this.recog,
                                                      this.trial.recognition$rt,
                                                      this.trial.recall$target_angle,
                                                      this.trial.recall$hitting_angle,
                                                      this.trial.recall$angular_error,
                                                      this.trial.recall$response_time,
                                                      this.trial.valid)
    }
    # Now do foils
    for(j in this.block.foil){
      this.trial.recognition <- this.block.recognition[this.block.recognition$stimulus == j,]
      # Transform recognition input into categories
      if(this.trial.recognition$response %in% c(1,2,3)){
        this.recog <- FALSE
      } else if (this.trial.recognition$response %in% c(8,9,0)){
        this.recog <- TRUE
      }
      this.block.data[nrow(this.block.data)+1, ] <- c(p, s, this.trial.recognition$block, 
                                                      this.trial.recognition$stimulus, 
                                                      this.trial.recognition$cond,
                                                      NA,
                                                      this.trial.recognition$stim,
                                                      this.trial.recognition$response,
                                                      this.recog,
                                                      this.trial.recognition$rt,
                                                      NA,
                                                      NA,
                                                      NA,
                                                      NA,
                                                      NA)
    }
    
    data <- rbind(data, this.block.data)
  }
  data$participant <- as.integer(data$participant)
  data$session <- as.integer(data$session)
  data$block <- as.integer(data$block)
  data$present_trial <- as.integer(data$present_trial)
  data$is_stimulus <- as.logical(data$is_stimulus)
  data$recog_rating <- as.integer(data$recog_rating)
  data$recognised <- as.logical(data$recognised)
  data$recog_RT <- as.numeric(data$recog_RT)
  data$target_angle <- as.numeric(data$target_angle)
  data$response_angle <- as.numeric(data$response_angle)
  data$source_error <- as.numeric(data$source_error)
  data$source_RT <- as.numeric(data$source_RT)
  data$valid_RT <- as.logical(data$valid_RT)
  
  #Line to account for dumb typo i made, remove these for the actual data analyses
  data[data$condition == 'orthographicr','condition'] <- 'orthographic'
  data[data$word == 'LUNGER', 'word'] <- 'LUNGED'
  
  data$word <- tolower(data$word)
  return(data)
}

# Append intrusion offsets and similarity information to the dataframe
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

## COMPARE HIT RATES AND FALSE ALARMS ACROSS CONDITIONS
get.user.recognition <- function(data){
  conditions <- c('unrelated', 'orthographic', 'semantic')
  is_stim <- unique(data$is_stimulus)
  res <- setNames(data.frame(matrix(ncol = 5, nrow = 3)), c("condition", "hit_rate", "misses","false_alarms", "correct_rejections"))
  idx <- 1
  for(i in conditions){
    this_stim <- data[(data$condition == i) & (data$is_stimulus == TRUE),]
    this_HR <- nrow(this_stim[this_stim$recognised == TRUE,])/nrow(this_stim)
    this_miss <- 1 - this_HR
    this_foil <- data[(data$condition == i) & (data$is_stimulus == FALSE),]
    this_FA <- nrow(this_foil[this_foil$recognised == TRUE,])/nrow(this_foil)
    this_CR <- 1- this_FA
    
    res$condition[idx] <- i
    res$hit_rate[idx] <- this_HR
    res$misses[idx] <- this_miss
    res$false_alarms[idx] <- this_FA
    res$correct_rejections[idx] <- this_CR
    idx <- idx + 1
  }
  return(res)
}

## RECENTER ERRORS
# Recenter Empirical Data
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
    for(j in 1:n_intrusions){1
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

plot_session <- function(p, sessions){
  data <- data.frame()
  for(i in sessions){
    this.data <- get_session(p, i)
    data <- rbind(data, this.data)
  }
  recog <- get.user.recognition(data)
  data <- data[(data$is_stimulus == TRUE) & 
                      (data$block != -1), ]
  data <- append_intrusions(data)
  recentered.data <- recenter_data(data)
  source.error <- hist(data$source_error, breaks = 30)
  return(source.error)
}

user_FA <- function(p, sessions){
  data <- data.frame()
  for(i in sessions){
    this.data <- get_session(p, i)
    data <- rbind(data, this.data)
  }
  recog <- get.user.recognition(data)
  return(recog)
}