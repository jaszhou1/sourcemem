library(DEoptim)
library(CircStats)

## Mixture Model Function
mixture.model <- function(params, data){
  # Data
  error <- data$source_error
  
  prec <- params[1] # Precision of Memory Distribution
  beta <- params[2] # Proportion of Guesses
  
  # Likelihoods for each data point from memory
  memory <- dvm(error, 0, prec)
  
  # Likelihoods for each data point from guesses
  guess <- dcircularuniform(error)
  
  # Weight the memory and guessing processes
  like <- ((1-beta) * memory) + (beta * guess)
  like[like < 1e-10] = 1e-10 # to avoid likelihoods of zero, substitute with a minimum value
  
  # Joint probability by summing logs (easier on computers than multiplying), and make negative for optimisation
  nLL <- -1*sum(log(like))
  return(nLL)
}

## Optimisation Function
fit.mixture.model <- function(participant, condition, data){
  
  this_data <- data[(data$participant == participant) &
                      (data$condition == condition) &
                      (data$is_stimulus),]

  # Parameter Boundaries
  lower <- c(0.001, 0.001)
  upper <- c(60, 1)
  
  # Optimise
  this_fit <- DEoptim(mixture.model, lower, upper, control = DEoptim.control(itermax = 500), this_data)
  
  # Extract best fitting parameters
  # prec <- this_fit$optim$bestmem[1]
  # beta <- this_fit$optim$bestmem[2]
  
  # Pass out best fitting parameters
  return(this_fit$optim$bestmem)
}

# Fit all participants and conditions
fit.mixture.all <- function(data){
  fits = data.frame(participant = integer(),
          condition =character(), 
          prec = numeric(),
          beta = numeric(),
          stringsAsFactors=FALSE) 
  
  data <- data[data$is_stimulus,]
  conds <- unique(data$condition)
  participants <- unique(data$participant)
  idx <- 1
  for(i in participants){
    for(j in conds){
      res <- fit.mixture.model(i, j, data)
      fits[idx, 1] <- i
      fits[idx, 2] <- j
      fits[idx, 3] <- res[[1]]
      fits[idx, 4] <- res[[2]]
      idx <- idx + 1
    }
  }
  return(fits)  
}

## Some plotting for sanity checking
## Plotting Function
simulate.mixture.model <- function(prec, beta){
  nSims = 2000
  mem <- rvm(nSims, pi, prec) - pi
  guess <- runif(nSims, -pi, pi)
  weight <- rbinom(nSims, 1, 1-beta)
  
  model <- numeric(nSims)
  model[weight == 1] <- mem[weight == 1]
  model[weight == 0] <- guess[weight == 0]
  
  return(model)
}


plot.mixture.model <- function(participant, condition, data, model){
  
  this_data <- data[(data$participant == participant) &
                      (data$condition == condition) &
                      (data$is_stimulus), 'source_error']

  # Get Model Parameters
  prec <- model[(model$participant == participant) &
                  (model$condition == condition), 'prec']
  beta <- model[(model$participant == participant) &
                  (model$condition == condition), 'beta']
  this_model <- simulate.mixture.model(prec,beta)
  
  ggplot() +
    geom_histogram(aes(x=this_data, y=..density..), alpha=0.6, 
                   position="identity", lwd=0.2) +
    geom_density(aes(x=this_model, colour='red'), alpha=0.6, 
                 position="identity", lwd=1) +
    labs(title= paste(participant, condition),
         x ="Response Outcome", y = "Density", colour = "model")
}