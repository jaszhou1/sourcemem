load("~/git/sourcemem/EXPINT/analysis/modelling/R/model_code/saturated.Rdata")
library(ggplot2)
library(ggpubr)

plot_orth <- function(data, model){
  p1 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'orthographic', ], aes(x = offset, y = ..density..), bins = 30) +
    geom_density(data = model[model$cond == 'orthographic', ], aes(x = offset, y = ..density..), fill = 'red', alpha = 0.2, bins = 30) +
    ylim(0, 0.5) + 
    facet_grid(~orthographic) +
    ggtitle(sprintf('%s Condition, Recentered on orthographic', 'orth'))
  
  p2 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'unrelated', ], aes(x = offset, y = ..density..), bins = 30) +
    geom_histogram(data = model[model$cond == 'unrelated', ], aes(x = offset, y = ..density..), fill = 'red', alpha = 0.2, bins = 30) +
    ylim(0, 0.5) + 
    facet_grid(~orthographic) +
    ggtitle(sprintf('%s Condition, Recentered on orthographic', 'unrelated'))
  
  p3 <- ggplot() + 
    geom_histogram(data = data, aes(x = offset, y = ..density..), bins = 30) +
    geom_histogram(data = model, aes(x = offset, y = ..density..), fill = 'red', alpha = 0.2, bins = 30) +
    ylim(0, 0.5) + 
    facet_grid(~orthographic) +
    ggtitle(sprintf('%s Condition, Recentered on orthographic', 'overall'))
  
  plot <- ggarrange(p1, p2, p3, ncol = 1, nrow = 3, heights = c(1, 1, 1))
  ggsave('recenter_orth.png', plot = last_plot(), width = 20, height = 45, units = "cm")
}