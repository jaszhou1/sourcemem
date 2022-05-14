## Live analyses to monitor how participants are tracking with each session

## Connection parameters
SERVER.BASE.URL <- "https://jzhou-sourcemem-online.appspot.com"
SERVER.PORT <- NULL
SERVER.MASTER.API.KEY <- "zjFdXfQ64sgAVwQMx84IhzqzUPygpSguUkeLKLqQBIyxo8kP3yphBqF9ysd4IQsA" # <-- This needs to be in agreement with
# whatever is on the server.
#####
setwd("~/git/sourcemem/EXPINT/analysis")
source("access-data.R")

# Function to compute angular difference

angle_diff <- function(a,b){
  diff <- atan2(sin(a-b), cos(a-b))
  return(diff)
}

## Get the started users
started.users <- get.started.users(SERVER.BASE.URL, SERVER.PORT,
                                   SERVER.MASTER.API.KEY)

get.user.data <- function(p, s){
  this.session.data <- get.session.data.by.user.id(SERVER.BASE.URL, p, s,
                                                   SERVER.PORT, SERVER.MASTER.API.KEY)
  
  data <- data.frame(matrix(ncol=7,nrow=length(this.session.data$confidence_trials), dimnames=list(NULL, c("word", "is_stimulus", "condition",
                                                                                                           "list_position", "recog_rating","recog_RT",
                                                                                                           "recognised")
  )
  )
  )
  
  ## Extract presentation data
  for(i in 1:length(this.session.data$confidence_trials)){
    data$word[i] <- this.session.data$confidence_trials[[i]]$stimulus
    data$is_stimulus[i] <- this.session.data$confidence_trials[[i]]$stim
    data$condition[i] <- this.session.data$confidence_trials[[i]]$cond
    data$list_position[i] <- this.session.data$confidence_trials[[i]]$trial
    data$recog_rating[i] <- this.session.data$confidence_trials[[i]]$response
    data$recog_RT[i] <- this.session.data$confidence_trials[[i]]$rt
    if(data$recog_rating[i] %in% c(1,2,3)){
      data$recognised[i] <- FALSE
    } else if (data$recog_rating[i] %in% c(8,9,0)){
      data$recognised[i] <- TRUE
    }
  }
  conditions <- c('unrelated', 'semantic', 'orthographic')
  return(data)
}

get.user.recognition <- function(data){
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


