
modified.rayleigh <- function(data){
  participants <- unique(data$participant)
  
  
  res<-data.frame(participant=character(0),
                         statistic=numeric(0), 
                         p.value=numeric(0))
  for(p in participants){
    this.rayleigh<-rayleigh.test(data[data$participant==p,]$response_error)
    Rpbar <- this.rayleigh$statistic
    ntrials <- nrow(data[data$participant==p,])
    #stat <- 2*ntrials*Rpbar^2
    stat <- (2 * ntrials - 1) * Rpbar^2 + ntrials * Rpbar^4 / 2;
  
    res <- rbind(res,
                        data.frame(participant = p,
                                   statistic = stat,
                                   p.value = this.rayleigh$p.value))
    
  }
  print(res)
}


setwd("~/GitHub/sourcemem/EXPIMG/analysis/data")
dataset <- read.csv('dataFiltered3.csv')

dataset.recog <- dataset[dataset$recog_rating>3, ]
dataset.unrecog <- dataset[dataset$recog_rating<=3, ]

all <- modified.rayleigh(dataset)
recognised <- modified.rayleigh(dataset.recog)
unrecognised <- modified.rayleigh(dataset.unrecog)