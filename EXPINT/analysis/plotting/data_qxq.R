data <- read.csv("~/git/sourcemem/EXPINT/analysis/modelling/MATLAB/EXPINT_data.csv")

# Exclude data from practice blocks
data <- data[data$block != -1,]

# Get rid of foil data, and data with invalid RT
data <- data[(data$valid_RT) & (data$is_stimulus),]

# Express RTs in seconds, not ms
data$source_RT <- data$source_RT/1000

# Define some things to iterate through
participants <- unique(data$participant)
conds <- unique(data$condition)

rt_quantiles <- c(0.1, 0.5, 0.7, 0.9)
error_quantiles <- c(0.1, 0.3, 0.5, 0.9)
Q_SYMBOLS <- c(25, 23, 24, 22)

source("~/git/sourcemem/EXPINT/analysis/plotting/diffusion/qxq.R")

# QQ pooled across conditions
data_qxq <- qxq(data, rt_quantile, error_quantiles, 'data')

plot.data.qxq <- function(data_qxq){
  plot <- ggplot(data = data_qxq) +
    geom_point(size = 3, aes(x= theta, y = rt, shape = factor(rt_q))) +
    theme(text = element_text(size = 16))
}

# QQ split by condition
data_qxq_cond <- qxq.cond(data, rt_quantile, error_quantiles, 'data')
plot.data.qxq.cond <- function(data_qxq_cond){
  plot <- ggplot(data = data_qxq_cond) +
    geom_point(size = 3, aes(x= theta, y = rt, shape = factor(rt_q), colour = factor(rt_q))) +
    geom_line(aes(x = theta, y = rt, colour = factor(rt_q)), alpha = 0.3) +
    geom_errorbar(aes(x = theta, ymin = rt_lower, ymax = rt_upper, colour = factor(rt_q)), alpha = 0.3, width = 0.1) +
    facet_wrap(~cond, ncol = 3) +
    theme(text = element_text(size = 16))
}

## Individual level

get.individual.qq <- function(data){
  res <- data.frame()
  for(i in unique(data$participant)){
    this_p_qxq <- qxq.cond(data, rt_quantiles, error_quantiles, 'data', i)
    res <- rbind(res, this_p_qxq)
  }
  return(res)
}

indiv_qq <- get.individual.qq(data)
plot.data.indiv.qxq.cond <- function(indiv_qq){
  plot <- ggplot(data = indiv_qq) +
    geom_point(size = 3, aes(x= theta, y = rt, shape = factor(rt_q), colour = factor(rt_q))) +
    geom_line(aes(x = theta, y = rt, colour = factor(rt_q)), alpha = 0.3) +
    geom_errorbar(aes(x = theta, ymin = rt_lower, ymax = rt_upper, colour = factor(rt_q)), alpha = 0.3, width = 0.1) +
    facet_wrap(participant~cond, ncol = 3, scales="free_y") +
    theme(text = element_text(size = 16))
}

save.plots <- function(){
  setwd("~/git/sourcemem/EXPINT/analysis/plotting/output/")
  
  group_qxq <- plot.data.qxq(data_qxq)
  ggsave('group_qxq.png', plot = group_qxq, width = 30, height = 10, units = 'cm')
  
  group_cond_qxq <- plot.data.qxq.cond(data_qxq_cond)
  ggsave('group_cond_qxq.png', plot = group_cond_qxq, width = 30, height = 10, units = 'cm')
  
  indiv_qq_plot <- plot.data.indiv.qxq.cond(indiv_qq)
  ggsave('inidiv_qq.png', plot = indiv_qq_plot, width = 30, height = 100, units = 'cm')
}
