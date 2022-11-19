# RECOGNITION_ANALYSES
# Functions necessary for the recongition analyses for EXPINT.

## Load dependencies
library(circular)
library(stringdist)
library(rjson)
library(lsa)
library(psycho)
library(ggplot2)
library(grid)
library(plyr)

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

## Looking at data prior to modelling
data <- read.csv("~/git/sourcemem/EXPINT/data/EXPINT_data.csv")

# Exclude data from practice blocks
data <- data[data$block != -1,]

# Rename conditions (want capital letters)
data$condition <- revalue(data$condition, c("unrelated" = "Unrelated", "orthographic" = "Orthographic", "semantic" = "Semantic"))

# Define some things to iterate through
participants <- unique(data$participant)
conds <- unique(data$condition)

# Flip the semantic similarity so it is expressed as a distance like others
data[,51:57] <- 1-data[,51:57]

## Hit Rates and False Alarms for each participant
recog <- data.frame(participant = integer(),
                    condition = character(),
                    hits = numeric(),
                    misses = numeric(),
                    fa = numeric(),
                    correct.rejections = numeric(),
                    dprime = numeric(),
                    beta = numeric())
idx <- 1
for(i in participants){
  this.p.data <- data[data$participant == i, ]
  for(j in conds){
    this.cond.data <- this.p.data[this.p.data$condition == j, ]
    this.cond.stim <- this.cond.data[this.cond.data$is_stimulus,]
    this.cond.foil <- this.cond.data[!this.cond.data$is_stimulus,]
    # Calculate hits and misses
    this.hits <- nrow(this.cond.stim[this.cond.stim$recognised,])/nrow(this.cond.stim)
    this.misses <- 1-this.hits
    # False alarms and correct rejections
    this.fa <- nrow(this.cond.foil[this.cond.foil$recognised,])/nrow(this.cond.foil)
    this.reject <- 1-this.fa
    # Index for the bigger dataframe
    recog[idx, 'participant'] <- i
    recog[idx, 'condition'] <- j
    recog[idx, 'hits'] <- this.hits
    recog[idx, 'misses'] <- this.misses
    recog[idx, 'fa'] <- this.fa
    recog[idx, 'correct.rejections'] <- this.reject
    
    # Tacking on some SDT measurements
    SDT <- dprime(nrow(this.cond.stim[this.cond.stim$recognised,]),  nrow(this.cond.foil[this.cond.foil$recognised,]), 
                  nrow(this.cond.stim[!this.cond.stim$recognised,]),  nrow(this.cond.foil[!this.cond.foil$recognised,]))
    recog[idx, "dprime"] <- SDT$dprime
    recog[idx, "beta"] <- SDT$beta
    idx <- idx + 1
  }
}

#Plot d prime, hit rate, false alarms, across conditions
recog$condition <- factor(recog$condition, levels = c("Unrelated", "Semantic", "Orthographic"), ordered = T)
recog$participant <- as.factor(recog$participant)
recog_dprime <- ggplot(recog, aes(x=condition,  y = dprime, group = participant, color = participant)) + 
  geom_line(lty= 'solid', lwd = 1, alpha = 0.4) + geom_point(size = 4, shape = 16)

recog_FA <- ggplot(data = recog, aes(x=condition,  y = fa, group = participant, color = participant)) + 
  geom_line(lty = 'solid', lwd = 1, alpha = 0.4) + 
  geom_point(size = 4, shape = 16)

recog_hit <- ggplot(data = recog, aes(x=condition,  y = hits, group = participant, color = participant)) + 
  geom_line(lty = 'solid', lwd = 1, alpha = 0.4) + 
  geom_point(size = 4, shape = 15)

recog_hit_fa <- ggplot(data = recog, aes(x=condition, group = participant, color = participant)) +
  geom_line(aes(y = fa), lty = 'solid', lwd = 1, alpha = 0.4) + 
  geom_point(aes(y = fa), size = 4, shape = 16) +
  geom_line(aes(y = hits), lty = 'dotted', lwd = 1, alpha = 0.4) + 
  geom_point(aes(y = hits), size = 4, shape = 15)

# Find the group-level hit rate and false alarm rates, and generate confidence intervals for these values.
group_recog <- data.frame(matrix(nrow = 3, ncol = 7))
colnames(group_recog) <- c('condition', 'hits', 'hit_CI_upper', 'hit_CI_lower',
                           'fa', 'fa_CI_upper', 'fa_CI_lower')

# Construct within-subject confidence interval for group hit rate and false alarms
# Because the inter-subject variability is not relevant, we can normalise the scores
# by subtracting from each subject's across across each condition a difference score
# (subject mean - grand mean)
# Normalise the participants' hit rate 
hit_gm <- mean(recog$hits)
fa_gm <- mean(recog$fa)
# For each participant, calculate their mean hit rate/false alarm across the three conditions
normalised_recog <- data.frame(matrix(nrow = 0, ncol = 4))
colnames(normalised_recog) <- c('participant', 'condition', 'normalised_hit', 'normalised_fa')
for(p in participants){
  this_p_recog <- recog[recog$participant == p,]
  this_p_recog <- this_p_recog[ , c("participant", "condition", "hits","fa")]
  mean_hits <- mean(this_p_recog$hits)
  # Normalise hit rates by subtracting participant mean from each participant observation..
  this_p_recog$hits <- this_p_recog$hits - mean_hits + hit_gm
  # Normalise the false alarms in the same way
  mean_fa <- mean(this_p_recog$fa)
  this_p_recog$fa <- this_p_recog$fa - mean_fa + fa_gm
  normalised_recog <- rbind(normalised_recog, this_p_recog)
}


for(i in 1:length(conds)){
  this_cond <- recog[recog$condition == conds[i], ]
  this_cond_normalised <- normalised_recog[normalised_recog$condition == conds[i], ]
  
  # Hit Rates
  this_cond_hits <- mean(this_cond$hits)
  group_recog[i, 'hits'] <- this_cond_hits
  
  # Confidence Interval around hit rate mean
  # Calculate standard error from normalised hit rates (Cousineau, 2005)
  hit_se <- sd(this_cond_normalised$hits)/sqrt(length(participants))
  hit_CI <- hit_se * 2.26
  
  # Correct for bias by multiplying by M/(M-1), where M is number of conditions
  hit_CI <- hit_CI*(length(conds)/(length(conds)-1))
  
  group_recog[i, 'hit_CI_upper'] <- this_cond_hits + hit_CI
  group_recog[i, 'hit_CI_lower'] <- this_cond_hits - hit_CI
  
  
  # False Alarms
  this_cond_fa <- mean(this_cond$fa)
  group_recog[i, 'fa'] <- this_cond_fa
  group_recog[i, 'condition'] <- conds[i]
  
  fa_se <- sd(this_cond_normalised$fa)/sqrt(length(participants))
  fa_CI <- fa_se * 2.26
  fa_CI <- fa_CI * (length(conds)/(length(conds)-1))
  
  group_recog[i, 'fa_CI_upper'] <- this_cond_fa + fa_CI
  group_recog[i, 'fa_CI_lower'] <- this_cond_fa - fa_CI
}
group_recog$condition <- factor(group_recog$condition, levels = c("Unrelated", "Semantic", "Orthographic"), ordered = T)

plot_group_recog <- function(include_participant){
  if(include_participant == FALSE){
    hit_rates <- ggplot(data = group_recog, aes(x = condition, group = 1)) +
      geom_line(aes(y = hits), lty = 'solid', lwd = 1, alpha = 0.4) + 
      geom_point(aes(y = hits), size = 4, shape = 16) +
      geom_errorbar(aes(ymin = hit_CI_lower, ymax = hit_CI_upper), width = 0.2) +
      scale_y_continuous(name="Rate", limits=c(0.5, 0.8)) +
      scale_x_discrete(name = "Condition") +
      ggtitle('Hits') +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
            panel.background = element_blank(), axis.line = element_line(colour = "black"),
            text = element_text(size = 16))
    
    false_alarms <- ggplot(data = group_recog, aes(x = condition, group = 1)) +
      geom_line(aes(y = fa), lty = 'solid', lwd = 1, alpha = 0.4) + 
      geom_point(aes(y = fa), size = 4, shape = 15) +
      geom_errorbar(aes(ymin = fa_CI_lower, ymax = fa_CI_upper), width = 0.2) +
      scale_y_continuous(name = "", limits=c(0.1, 0.4)) +
      scale_x_discrete(name = "Condition") +
      ggtitle('False Alarms') +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
            panel.background = element_blank(), axis.line = element_line(colour = "black"),
            text = element_text(size = 16))
    
    plot <- ggarrange(hit_rates, false_alarms, ncol = 2, nrow = 1)
  } else {
    hit_rates <- ggplot(data = group_recog, aes(x = condition, group = 1)) +
      # Add in individual participant level with low alpha
      geom_line(data = recog, aes(x=condition,  y = hits, group = participant, color = participant), lty = 'dotted', lwd = 0.75, alpha = 0.6) + 
      geom_point(data = recog, aes(x=condition,  y = hits, group = participant, color = participant), size = 3, shape = 16, alpha = 0.6) +
      # Group
      geom_line(aes(y = hits), lty = 'solid', lwd = 1, alpha = 0.8) + 
      geom_point(aes(y = hits), size = 4, shape = 15) +
      geom_errorbar(aes(ymin = hit_CI_lower, ymax = hit_CI_upper), width = 0.2) +
      scale_y_continuous(name="Hit Rate", limits=c(0.3, 1.0)) +
      scale_x_discrete(name = "Condition") +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
            panel.background = element_blank(), axis.line = element_line(colour = "black"),
            legend.key = element_rect(colour = NA, fill = NA),
            text = element_text(size = 16)) +
      guides(color = guide_legend("Participant"))
    
    false_alarms <- ggplot(data = group_recog, aes(x = condition, group = 1)) +
      # Add in individual participant level with low alpha
      geom_line(data = recog, aes(x=condition,  y = fa, group = participant, color = participant), lty = 'dotted', lwd = 0.75, alpha = 0.6) + 
      geom_point(data = recog, aes(x=condition,  y = fa, group = participant, color = participant), size = 3, shape = 16, alpha = 0.6) +
      geom_line(aes(y = fa), lty = 'solid', lwd = 1, alpha = 0.8) + 
      geom_point(aes(y = fa), size = 4, shape = 15) +
      geom_errorbar(aes(ymin = fa_CI_lower, ymax = fa_CI_upper), width = 0.2) +
      scale_y_continuous(name="False Alarms", limits=c(0, 0.5)) +
      scale_x_discrete(name = "Condition") +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
            panel.background = element_blank(), axis.line = element_line(colour = "black"),
            legend.key = element_rect(colour = NA, fill = NA),
            text = element_text(size = 16)) +
      guides(color = guide_legend("Participant"))
    
    plot <- ggarrange(hit_rates, false_alarms, ncol = 2, nrow = 1, common.legend = TRUE, legend = "bottom")
  }
  return(plot)
}

## Statistical Analysis on HR/FA
library(nlme)
library(multcomp)
# use lme to basically just do anova, need lme to play nice with glht below

lme.hits <- lme(hits ~ condition, data = recog, random = ~1|participant)
anova(lme.hits)

lme.fa <- lme(fa ~ condition, data = recog, random = ~1|participant)
anova(lme.fa)

# Pairwise comparisons
summary(glht(lme.fa, linfct=mcp(condition = "Tukey")), test = adjusted(type = "bonferroni"))


## Look at source performance for recognised and unrecognised data

plot.source.x.ratings <- function(data){
  
  # Recode recognition ratings
  data$recog_rating <- mapvalues(data$recog_rating, from = c(0,1,2,3,8,9), to = c(6,1,2,3,4,5))
  
  data.no.na <- data[data$is_stimulus,]
  plot <- ggplot(data = data.no.na, aes(x = source_error, y = ..density..)) +
    geom_histogram(bins = 50) +
    facet_wrap(~recog_rating, scales = 'free') +
    scale_y_continuous(name="Density", limits=c(0, 1.1), breaks = c(0, 0.5, 1.0)) +
    scale_x_continuous(name = "Source Error", limits = c(-pi,pi), breaks = c(-pi, 0, pi), labels=c(expression(-pi), "0", expression(pi))) +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(), axis.line = element_line(colour = "black"),
          legend.key = element_rect(colour = NA, fill = NA),
          strip.background=element_rect(fill="white"),
          text = element_text(size = 16))
  return(plot)
}

plot.source.x.recog <- function(data){
  plot <- data.no.na <- data[data$is_stimulus,]
  data.no.na$recognised <- mapvalues(data.no.na$recognised, from = c(FALSE, TRUE), to = c('Unrecognized', 'Recognized'))
  ggplot(data = data.no.na, aes(x = source_error, y = ..density..)) +
    geom_histogram(bins = 50) +
    facet_wrap(~recognised) +
    scale_y_continuous(name="Density", limits=c(0, 1.1), breaks = c(0, 0.5, 1.0)) +
    scale_x_continuous(name = "Source Error", breaks = c(-pi, 0, pi), labels=c(expression(-pi), "0", expression(pi))) +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(), axis.line = element_line(colour = "black"),
          legend.key = element_rect(colour = NA, fill = NA),
          strip.background=element_rect(fill="white"),
          text = element_text(size = 16))
  return(plot)
}