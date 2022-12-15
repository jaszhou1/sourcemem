setwd("~/git/sourcemem/EXPINT/analysis")
# source('append_intrusions.R')
# source('recenter_data.R')
# 
# setwd("~/git/sourcemem/EXPINT/data")
# load("~/git/sourcemem/EXPINT/data/p2.RData")
# data <- append_intrusions(data)
# 
# data<- data[(data$block != -1) & (data$is_stimulus == TRUE) & (data$valid_RT == TRUE),]
# 
# ortho <- data[data$condition == 'orthographic',]
# semantic <- data[data$condition == 'semantic',]
# unrelated <- data[data$condition == 'unrelated',]

load("~/git/sourcemem/EXPINT/analysis/modelling/R/2022-11-24_response_error.RData")
recenter_data$abs_lag <- abs(recenter_data$lag)

orthographic_recenter <- function(data){
  data <- data[data$orthographic < 5,]
  p1 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'orthographic', ], aes(x = offset, y = ..density..), bins = 50) +
    ylim(0, 0.5) + 
    facet_grid(~orthographic) +
    ggtitle('orthographic')
  
  p2 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'unrelated', ], aes(x = offset, y = ..density..), bins = 50) +
    ylim(0, 0.5) + 
    facet_grid(~orthographic) +
    ggtitle('unrelated')
  
  p3 <- ggplot() + 
    geom_histogram(data = data, aes(x = offset, y = ..density..), bins = 50) +
    ylim(0, 0.5) + 
    facet_grid(~orthographic) +
    ggtitle('overall')
  
  plot <- ggarrange(p1,p2,p3, ncol = 1)
  plot <- annotate_figure(plot, top = text_grob("Orthographic Recenter", 
                                        color = "black", face = "bold", size = 16))
  return(plot)
  #ggsave('recenter_orth_overall.png', plot = last_plot(), width = 20, height = 15, units = "cm")
}

semantic_recenter <- function(data){
  p1 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'semantic', ], aes(x = offset, y = ..density..), bins = 50) +
    ylim(0, 0.5) + 
    facet_grid(~semantic_bin) +
    ggtitle('semantic')
  
  p2 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'unrelated', ], aes(x = offset, y = ..density..), bins = 50) +
    ylim(0, 0.5) + 
    facet_grid(~semantic_bin) +
    ggtitle('unrelated')
  
  p3 <- ggplot() + 
    geom_histogram(data = data, aes(x = offset, y = ..density..), bins = 50) +
    ylim(0, 0.5) + 
    facet_grid(~semantic_bin) +
    ggtitle('overall')
  
  plot <- ggarrange(p1,p2,p3, ncol = 1)
  plot <- annotate_figure(plot, top = text_grob("Semantic Recenter", 
                                                color = "black", face = "bold", size = 16))
  return(plot)
  #ggsave('recenter_orth_overall.png', plot = last_plot(), width = 20, height = 15, units = "cm")
}

temporal_recenter <- function(data){
  data <- data[data$abs_lag < 5,]
  p1 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'orthographic', ], aes(x = offset, y = ..density..), bins = 50) +
    ylim(0, 0.3) + 
    facet_grid(~abs_lag) +
    ggtitle('orthographic')
  
  p2 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'semantic', ], aes(x = offset, y = ..density..), bins = 50) +
    ylim(0, 0.3) + 
    facet_grid(~abs_lag) +
    ggtitle('semantic')
  
  p3 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'unrelated', ], aes(x = offset, y = ..density..), bins = 50) +
    ylim(0, 0.3) + 
    facet_grid(~abs_lag) +
    ggtitle('unrelated')
  
  p4 <- ggplot() + 
    geom_histogram(data = data, aes(x = offset, y = ..density..), bins = 50) +
    ylim(0, 0.3) + 
    facet_grid(~abs_lag) +
    ggtitle('overall')
  
  plot <- ggarrange(p1,p2,p3,p4, ncol = 1)
  plot <- annotate_figure(plot, top = text_grob("Temporal Recenter", 
                                                color = "black", face = "bold", size = 16))
  return(plot)
}

spatial_recenter <- function(data){
  p1 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'orthographic', ], aes(x = offset, y = ..density..), bins = 50) +
    ylim(0, 0.5) + 
    facet_grid(~spatial_bin) +
    ggtitle('orthographic')
  
  p2 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'semantic', ], aes(x = offset, y = ..density..), bins = 50) +
    ylim(0, 0.5) + 
    facet_grid(~spatial_bin) +
    ggtitle('semantic')
  
  p3 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'unrelated', ], aes(x = offset, y = ..density..), bins = 50) +
    ylim(0, 0.5) + 
    facet_grid(~spatial_bin) +
    ggtitle('unrelated')
  
  p4 <- ggplot() + 
    geom_histogram(data = data, aes(x = offset, y = ..density..), bins = 50) +
    ylim(0, 0.5) + 
    facet_grid(~spatial_bin) +
    ggtitle('overall')
  
  plot <- ggarrange(p1,p2,p3,p4, ncol = 1)
  plot <- annotate_figure(plot, top = text_grob("Spatial Recenter", 
                                                color = "black", face = "bold", size = 16))
  return(plot)
}

#ggsave('temporal_recenter.png', plot = last_plot(), width = 7, height = 10, units = "in", bg = 'white')
