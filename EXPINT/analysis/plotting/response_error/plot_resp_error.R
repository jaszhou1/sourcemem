recenter.condition <- function(data, cond){
  this_data <- data[data$cond == cond, ]
  orth <- ggplot(this_data) + geom_histogram(aes(x = offset, y = ..density..), bins = 30) + 
    ylim(0, 0.5) + 
    facet_grid(~orthographic) +
    ggtitle(sprintf('%s Condition, Recentered on orthographic', cond))
  ggsave(sprintf('recenter_orthographic_cond_%s.png', cond), plot = orth, width = 20, height = 15, units = "cm")
  
  sem <- ggplot(this_data) + geom_histogram(aes(x = offset, y = ..density..), bins = 30) + 
    ylim(0, 0.5) + 
    facet_grid(~semantic_bin) +
    ggtitle(sprintf('%s Condition, Recentered on semantic (quantile)', cond))
  ggsave(sprintf('recenter_semantic_cond_%s.png', cond), plot = sem, width = 20, height = 15, units = "cm")
  
  spatial <- ggplot(this_data) + geom_histogram(aes(x = offset, y = ..density..), bins = 30) + facet_grid(~spatial_bin) +
    ggtitle(sprintf('%s Condition, Recentered on spatial (quantile)', cond))
  ggsave(sprintf('recenter_spatial_cond_%s.png', cond), plot = spatial, width = 20, height = 15, units = "cm")
}
