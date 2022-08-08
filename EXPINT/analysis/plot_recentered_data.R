setwd("~/git/sourcemem/EXPINT/analysis")
source('append_intrusions.R')
source('recenter_data.R')

setwd("~/git/sourcemem/EXPINT/data")
load("~/git/sourcemem/EXPINT/data/p2.RData")
data <- append_intrusions(data)

data<- data[(data$block != -1) & (data$is_stimulus == TRUE) & (data$valid_RT == TRUE),]

ortho <- data[data$condition == 'orthographic',]
semantic <- data[data$condition == 'semantic',]
unrelated <- data[data$condition == 'unrelated',]

ortho_recenter <- recenter_data(ortho)