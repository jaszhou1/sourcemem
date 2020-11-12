## mixtureModel.R
##
## This script fits the Zhang and Luck (2008) Mixture Model to 
## source memory data conditioned on recognition confidence.

# Load required packages
library(CircStats)
library(DEoptim)
library(ggplot2)


# Load in data
setwd("~/GitHub/sourcemem/EXPIMG/analysis/data")
data <- read.csv('dataFiltered3.csv')
data <- data[,-1]
# valid_ps <- c(3,4,6,7,9,12,13,15,17)
# data <- data[data$participant %in% valid_ps,]


# Define recognition bands in data
data$recog_band <- ifelse(data$recog_rating >= 0 & data$recog_rating <= 3, 'Unrecognized',
                          ifelse(data$recog_rating >=4 & data$recog_rating <=5, 'Low',
                                 ifelse(data$recog_rating ==6, 'High','N/A')
                          )
)


low_data <- data[data$condition == 1,]
high_data <- data[data$condition == 2,]


## Mixture Model Function
mix <- function(params, in_data){
  # Data
  error <- in_data
  error <- error + pi # CircStats seems to want angles from 0 to 2pi, not -pi to pi
  
  prec <- params[1] # Precision of Memory Distribution
  lmbda <- params[2] # Proportion of Memory Responses to Guesses
  
  # Likelihoods for each data point from memory
  memory <- dvm(error, pi, prec)
  
  # Likelihoods for each data point from guesses
  guess <- dunif(error, 0, 2*pi, FALSE)
  
  # Weight the memory and guessing processes
  like <- (lmbda * memory) + ((1-lmbda) * guess)
  like[like < 1e-10] = 1e-10 # to avoid likelihoods of zero, substitute with a minimum value
  
  # Joint probability by summing logs (easier on computers than multiplying), and make negative for optimisation
  nLL <- -1*sum(log(like))
  return(nLL)
}


## Optimisation Function
fit_mix <- function(participant, condition, recognition){
  
  # Define the data to fit the model to
  # Participant -1 is the entire group
  if (participant == -1){
    this_data <- data[data$recog_band == recognition,]
    this_data <- this_data[this_data$condition == condition,]
    in_data <- this_data$response_error
  } else {
    this_data <- data[data$recog_band == recognition,]
    this_data <- this_data[this_data$participant == participant,]
    this_data <- this_data[this_data$condition == condition,]
    in_data <- this_data$response_error
  }
  
  
  # Parameter Boundaries
  lower <- c(0.001, 0.001)
  upper <- c(250, 1)
  
  # Optimise
  this_fit <- DEoptim(mix, lower, upper, control = DEoptim.control(itermax = 500), in_data)
  
  # Extract best fitting parameters
  # this_prec <- this_fit$optim$bestmem[1]
  # this_lmbda <- this_fit$optim$bestmem[2]
  
  # Pass out best fitting parameters
  return(this_fit$optim$bestmem)
}

# Participant Loop

fit_participant <- function(){
  # Empty dataframe to store fitted parameters
  fits <- data.frame(
    participant = integer(),
    condition = integer(),
    recognition = character(),
    prec = numeric(),
    lmbda = numeric(),
    stringsAsFactors = FALSE
  )
  
  participants <- unique(data$participant)
  conditions <- unique(data$condition)
  recog_bands <- unique(data$recog_band)
  
  for (i in 1:length(participants)){
    for (j in 1:length(conditions)){
      for (k in 1:length(recog_bands)){
        this_participant <- fit_mix(participants[i], j, recog_bands[k])
        this_fit <- c(participants[i],j,recog_bands[k],this_participant[1],this_participant[2])
        fits[nrow(fits)+1, ] <- this_fit
      }
    }
  }
  fits$prec <- as.numeric(fits$prec)
  fits$lmbda <- as.numeric(fits$lmbda)
}

fit_group <- function(){
  fits <- data.frame(
    participant = integer(),
    condition = integer(),
    recognition = character(),
    prec = numeric(),
    lmbda = numeric(),
    stringsAsFactors = FALSE
  )
  
  conditions <- unique(data$condition)
  recog_bands <- unique(data$recog_band)
  
  for (j in 1:length(conditions)){
    for (k in 1:length(recog_bands)){
      this_participant <- fit_mix(-1, j, recog_bands[k])
      this_fit <- c(-1,j,recog_bands[k],this_participant[1],this_participant[2])
      fits[nrow(fits)+1, ] <- this_fit
    }
  }
  
  fits$prec <- as.numeric(fits$prec)
  fits$lmbda <- as.numeric(fits$lmbda)
  return(fits)
}

## Plotting Function
plot_fit <- function(this_prec, this_lmbda){
  nSims = 1000000
  mem <- rvm(nSims, pi, this_prec)
  guess <- runif(nSims, 0, 2*pi)
  weight <- rbinom(nSims, 1, this_lmbda)
  
  model <- numeric(nSims)
  model[weight == 1] <- mem[weight == 1]
  model[weight == 0] <- guess[weight == 0]
  
  return(model)
}


plot_model <- function(participant, condition, recognition){
  
  # Get data
  if (participant == -1){
    this_data <- data[(data$condition == condition)&
                        (data$recog_band == recognition),]$response_error
  } else {
    this_data <- data[(data$participant == participant)&
                        (data$condition == condition)&
                        (data$recog_band == recognition),]$response_error
  } 
  this_data <- this_data + pi # Shift by pi to be between 0 and 2pi
  
  # Get Model
  if (participant == -1){
    this_prec <- fits[(fits$condition == condition)&
                        (fits$recognition == recognition),]$prec
    
    this_lmbda <- fits[(fits$condition == condition)&
                         (fits$recognition == recognition),]$lmbda
    
  } else {
    this_prec <- fits[(fits$participant == participant)&
                        (fits$condition == condition)&(
                          fits$recognition == recognition),]$prec
    
    this_lmbda <- fits[(fits$participant == participant)&
                         (fits$condition == condition)&
                         (fits$recognition == recognition),]$lmbda
  }
  this_model <- plot_fit(this_prec,this_lmbda)
  
  ggplot() +
    geom_histogram(aes(x=this_data, y=..density..), alpha=0.6, 
                   position="identity", lwd=0.2) +
    geom_density(aes(x=this_model, colour='red'), alpha=0.6, 
                 position="identity", lwd=1) +
    labs(title= recognition,
          x ="Response Outcome", y = "Density", colour = "model")
}

unrecog <- matrix(nrow = 19, ncol = 4)
unrecog[,1] <- fits[(fits$condition == 1) & (fits$recognition == "Unrecognized"),]$prec
unrecog[,2] <- fits[(fits$condition == 1) & (fits$recognition == "Unrecognized"),]$lmbda
unrecog[,3] <- fits[(fits$condition == 2) & (fits$recognition == "Unrecognized"),]$prec
unrecog[,4] <- fits[(fits$condition == 2) & (fits$recognition == "Unrecognized"),]$lmbda

low <- matrix(nrow = 19, ncol = 4)
low[,1] <- fits[(fits$condition == 1) & (fits$recognition == "Low"),]$prec
low[,2] <- fits[(fits$condition == 1) & (fits$recognition == "Low"),]$lmbda
low[,3] <- fits[(fits$condition == 2) & (fits$recognition == "Low"),]$prec
low[,4] <- fits[(fits$condition == 2) & (fits$recognition == "Low"),]$lmbda

high <- matrix(nrow = 19, ncol = 4)
high[,1] <- fits[(fits$condition == 1) & (fits$recognition == "High"),]$prec
high[,2] <- fits[(fits$condition == 1) & (fits$recognition == "High"),]$lmbda
high[,3] <- fits[(fits$condition == 2) & (fits$recognition == "High"),]$prec
high[,4] <- fits[(fits$condition == 2) & (fits$recognition == "High"),]$lmbda










