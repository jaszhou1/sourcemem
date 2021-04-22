library(ggplot2)
library(tidyverse)

setwd("~/GitHub/sourcemem/EXPIMG/models/figures/cDiffusionFits")

# Import data
dataset <- read_csv("~/GitHub/sourcemem/EXPIMG/models/figures/cDiffusionFits/dataFiltered3.csv")

# Create a new variable to label the subject numbers as strings 
dataset$subjString <- NA

#dataset <- dataset[!(dataset$participant== 1),]
#dataset <- dataset[!(dataset$participant== 13),]
# Get a list of subjects 
data.subjList <- unique(dataset$participant)
#data.subjList <- c(1,2,3,4)

# Custom function to create new variable labels 
create.subj.string <- function(subjNo, dataset){
  
  dataset[dataset$participant==subjNo, 'subjString'] <- sprintf('Subject %d', subjNo)
  
  return(dataset)
}

# Run through loop - don't use lapply or map because subject numbers not in order 
for (sub in 1:length(data.subjList)){
  
  # Get the subject number 
  subjNo <- data.subjList[sub]
  
  # Run function, return data frame (dataset)
  dataset <- create.subj.string(subjNo, dataset)
  
}

dataset <- dataset[(dataset$subjString != 'Subject 1'),]
dataset <- dataset[(dataset$subjString != 'Subject 13'),]

# Create as factor for plotting and also include levels so the order is correct 
dataset$subjString <- factor(dataset$subjString, 
                             levels = unique(dataset$subjString))

dataset$participant <- factor(dataset$participant, levels = unique(dataset$participant))


recogdata <- dataset[dataset$recog_rating>3,]
lowdata <- recogdata[recogdata$condition==1,]
highdata <- recogdata[recogdata$condition==2,]

# Import Model Fits
Cont <- read.csv('2019-11-06_NoCrit_Cont.csv')
Thresh <- read.csv('2019-11-06_NoCrit_Thresh.csv')
density <- rbind(Cont,Thresh)

#exclude participants 1 and 13, who are non-sig on Rayleigh Test
#density <- density[!(density$participant== 1),]
#density <- density[!(density$participant== 13),]

names(density)[1] <- "model_name"
density <- density[density$participant != 1,]
density <- density[density$participant != 13,]

continuous<- density[density$model_name == 'Continuous', ]
threshold<- density[density$model_name == 'Threshold', ]

# -------- CONTINUOUS MODEL -------------------
# Initialise columns 
continuous$model <- matrix(NA, dim(continuous)[1])
continuous$cond <- matrix(NA, dim(continuous)[1])
continuous$theta <- matrix(NA, dim(continuous)[1])

# Find all instances of model, high and theta
continuous$model[which(continuous$is_model == ' true')] <- 1 # model 
continuous$model[which(continuous$is_model == ' false')] <- 0 # not ya model 

continuous$cond[which(continuous$is_high == ' true')] <- 1 # high 
continuous$cond[which(continuous$is_high == ' false')] <- 0 # low 

continuous$theta[which(continuous$is_theta == ' true')] <- 1 # theta
continuous$theta[which(continuous$is_theta == ' false')] <- 0 # not ya theta 

continuous <- tibble(modelName = continuous$model_name,
                     participant = continuous$participant,
                     model = as.factor(continuous$model),
                     cond = as.factor(continuous$cond),
                     theta = as.factor(continuous$theta),
                     value = continuous$value,
                     prob = continuous$prob)

head(continuous)
# -------- THRESHOLD MODEL -------------------
threshold$model <- matrix(NA, dim(threshold)[1])
threshold$cond <- matrix(NA, dim(threshold)[1])
threshold$theta <- matrix(NA, dim(threshold)[1])

# Find all instances of model, high and theta
threshold$model[which(threshold$is_model == ' true')] <- 1 # model 
threshold$model[which(threshold$is_model == ' false')] <- 0 # not ya model 

threshold$cond[which(threshold$is_high == ' true')] <- 1 # high 
threshold$cond[which(threshold$is_high == ' false')] <- 0 # low 

threshold$theta[which(threshold$is_theta == ' true')] <- 1 # theta
threshold$theta[which(threshold$is_theta == ' false')] <- 0 # not ya theta 

threshold <- tibble(modelName = threshold$model_name,
                    participant = threshold$participant,
                    model = as.factor(threshold$model),
                    cond = as.factor(threshold$cond),
                    theta = as.factor(threshold$theta),
                    value = threshold$value,
                    prob = threshold$prob)


# # Get low and high conditions out 
threshold_low <- threshold[threshold$cond == 0,]

threshold_high <- threshold[threshold$cond == 1,]

# Thetas 
threshold_low_theta <- threshold_low[threshold_low$theta == 1,]

threshold_high_theta <- threshold_high[threshold_high$theta == 1,]

# RTs 
threshold_low_RT <- threshold_low[threshold_low$theta == 0,]

threshold_high_RT <- threshold_high[threshold_high$theta == 0,]

# Model Theta 
mthreshold_low_theta <- threshold_low_theta[threshold_low_theta$model == 1,]

mthreshold_high_theta <- threshold_high_theta[threshold_high_theta$model == 1,]

# Data Theta
dthreshold_low_theta <- threshold_low_theta[threshold_low_theta$model == 0,]

dthreshold_high_theta <- threshold_high_theta[threshold_high_theta$model == 0,]

# model predicted RT data 
mRT_threshold_low <- threshold_low_RT[threshold_low_RT$model == 1, ]

mRT_threshold_high <- threshold_high_RT[threshold_high_RT$model == 1, ]

# RT data 
dRT_threshold_low <- threshold_low_RT[threshold_low_RT$model == 0, ]

dRT_threshold_high <- threshold_high_RT[threshold_high_RT$model == 0, ]

# Get low and high conditions out 
continuous_low <- continuous[continuous$cond == 0,]

continuous_high <- continuous[continuous$cond == 1,]

# Thetas 
continuous_low_theta <- continuous_low[continuous_low$theta == 1,]

continuous_high_theta <- continuous_high[continuous_high$theta == 1,]

# RTs 
continuous_low_RT <- continuous_low[continuous_low$theta == 0,]

continuous_high_RT <- continuous_high[continuous_high$theta == 0,]

# Model Theta 
mcontinuous_low_theta <- continuous_low_theta[continuous_low_theta$model == 1,]

mcontinuous_high_theta <- continuous_high_theta[continuous_high_theta$model == 1,]

# Data Theta
dcontinuous_low_theta <- continuous_low_theta[continuous_low_theta$model == 0,]

dcontinuous_high_theta <- continuous_high_theta[continuous_high_theta$model == 0,]

# model predicted RT data 
mRT_continuous_low <- continuous_low_RT[continuous_low_RT$model == 1, ]

mRT_continuous_high <- continuous_high_RT[continuous_high_RT$model == 1, ]

# RT data 
dRT_continuous_low <- continuous_low_RT[continuous_low_RT$model == 0, ]

dRT_continuous_high <- continuous_high_RT[continuous_high_RT$model == 0, ]

## Plotting Function
plot_participant_theta <- function(p){
  # Get data
  data <- highdata[highdata$participant == p,]
  cont <- mcontinuous_high_theta[mcontinuous_high_theta$participant == p,]
  thresh <- mthreshold_high_theta[mthreshold_high_theta$participant == p,]
  
  ggplot(data=data,aes(x=data$response_error, ..density..)) + 
    geom_histogram(bins = 50, color = "black", fill = "white")  +
    # ------ Model --------
  #Continuous
  geom_line(data = cont, aes(x = value, prob), size = 2, color = "dodgerblue3") +  
    xlab("Theta (radians)") + 
    #Threshold
    geom_line(data = thresh, aes(x = value, prob), size = 2, color = "red") +  
    xlab("Theta (radians)") + 
    #Hybrid
    #geom_line(data = mhybrid_high_theta, aes(x = value, prob), size = 0.75, linetype = "dotdash") +  
    # facet_wrap(~subjString, labeller = label_wrap_gen(width = 30), ncol = 3, scale = "free") + 
    # xlab("Theta (radians)") + 
    #Misc
    scale_x_continuous(name ="Response Error (radians)", # also x axis name 
                       breaks = c(-2, 0, 2),
                       labels = c(expression(-pi), "0", expression(pi))) + 
    scale_colour_manual(values=c("red","black")) +
    ylab("Density") + 
    ggtitle("Response Error") +   
    theme(
      # x axis label
      # Theme asthetics to make the plot look nicer 
      axis.text.x = element_text(color="white", size = 18),
      axis.text.y = element_text(color="white", size = 18),
      plot.title = element_text(color="white", size=20),
      axis.title.x = element_text(color="white", size=14),
      axis.title.y = element_text(color="white", size=14),
      plot.background = element_rect(fill = "black"),
      panel.grid.major = element_line(colour = "grey40"), 
      panel.grid.minor = element_line(colour = "grey50"),
      panel.background = element_rect(fill = "grey30"), 
      axis.line = element_line(colour = "black")
    )
}

plot_participant_RT <- function(p){
  # Get data
  data <- highdata[highdata$participant == p,]
  cont <- mRT_continuous_high[mRT_continuous_high$participant == p,]
  thresh <- mRT_threshold_high[mRT_threshold_high$participant == p,]
  
  ggplot(data=data,aes(x=data$response_RT, ..density..)) + 
    geom_histogram(bins = 50, color = "black", fill = "white")  +
    xlim(0, 3) +
    # ------ Model --------
  #Continuous
  geom_line(data = cont, aes(x = value, prob), size = 2, color = "dodgerblue3") +  
    xlab("Theta (radians)") + 
    xlim(0, 3) +
    #Threshold
    geom_line(data = thresh, aes(x = value, prob), size = 2, color = "red") +  
    xlab("Theta (radians)") + 
    xlim(0, 3) +
    #Hybrid
    #geom_line(data = mhybrid_high_theta, aes(x = value, prob), size = 0.75, linetype = "dotdash") +  
    # facet_wrap(~subjString, labeller = label_wrap_gen(width = 30), ncol = 3, scale = "free") + 
    # xlab("Theta (radians)") + 
    #Misc
    scale_colour_manual(values=c("red","black")) +
    ylab("Density") + 
    ggtitle("Response Time") +   
    theme(
      # x axis label
      # Theme asthetics to make the plot look nicer 
      axis.text.x = element_text(color="white", size = 18),
      axis.text.y = element_text(color="white", size = 18),
      plot.title = element_text(color="white", size=20),
      axis.title.x = element_text(color="white", size=14),
      axis.title.y = element_text(color="white", size=14),
      plot.background = element_rect(fill = "black"),
      panel.grid.major = element_line(colour = "grey40"), 
      panel.grid.minor = element_line(colour = "grey50"),
      panel.background = element_rect(fill = "grey30"), 
      axis.line = element_line(colour = "black")
    )
}