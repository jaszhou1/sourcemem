load("~/git/sourcemem/EXPINT/analysis/modelling/R/2022-11-24_response_error.RData")


recentered_models <- rbind(recenter_pure_orthosem,
                           recenter_orthosem,
                           recenter_mix_cond, 
                           recenter_gamma,
                           recenter_gammabeta)

################# PLOTS
# Plot recentered spatiotemporal against data
setwd("~/git/sourcemem/EXPINT/analysis/plotting/output")
plot_temporal <- function(data, model, cond){
  ggplot() + 
    geom_histogram(data = data[data$cond == cond, ], aes(x = offset, y = ..density..), bins = 30) +
    geom_density(data = model[model$cond == cond, ], aes(x = offset, color = model), alpha = 0.2, bins = 30) +
    ylim(0, 0.5) + 
    facet_grid(~lag) +
    ggtitle(sprintf('%s Condition, Recentered on lag', cond))
  
}

plot_spatial <- function(data, model, cond){
  ggplot() + 
    geom_histogram(data = data[data$cond == cond, ], aes(x = offset, y = ..density..), bins = 30) +
    geom_histogram(data = model[model$cond == cond, ], aes(x = offset, y = ..density..), fill = 'red', alpha = 0.2, bins = 30) +
    ylim(0, 0.5) + 
    facet_grid(~spatial_bin) +
    ggtitle(sprintf('%s Condition, Recentered on spatial bin', cond))
  
}

plot_orth <- function(data, model){
  p1 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'orthographic', ], aes(x = offset, y = ..density..), bins = 30) +
    geom_density(data = model[model$cond == 'orthographic', ], aes(x = offset, color = model), alpha = 0.2) +
    ylim(0, 0.5) + 
    facet_grid(~orthographic) +
    ggtitle(sprintf('%s Condition, Recentered on orthographic', 'orth'))
  
  p2 <- ggplot() + 
    geom_histogram(data = data[data$cond == 'unrelated', ], aes(x = offset, y = ..density..), bins = 30) +
    geom_density(data = model[model$cond == 'unrelated', ], aes(x = offset, color = model), alpha = 0.2) +
    ylim(0, 0.5) + 
    facet_grid(~orthographic) +
    ggtitle(sprintf('%s Condition, Recentered on orthographic', 'unrelated'))
  
  p3 <- ggplot() + 
    geom_histogram(data = data, aes(x = offset, y = ..density..), bins = 30) +
    geom_density(data = model[model$cond == 'unrelated', ], aes(x = offset, color = model), alpha = 0.2) +
    ylim(0, 0.5) + 
    facet_grid(~orthographic) +
    ggtitle(sprintf('%s Condition, Recentered on orthographic', 'overall'))
  
  plot <- ggarrange(plotlist = c(p1,p2,p3), ncol = 1)
  return(plot)
  #ggsave('recenter_orth_overall.png', plot = last_plot(), width = 20, height = 15, units = "cm")
}

plot_sem <- function(data, model, cond){
  ggplot() + 
    geom_histogram(data = data[data$cond == cond, ], aes(x = offset, y = ..density..), bins = 30) +
    geom_histogram(data = model[model$cond == cond, ], aes(x = offset, y = ..density..), fill = 'red', alpha = 0.2, bins = 30) +
    ylim(0, 0.5) + 
    facet_grid(~semantic_bin) +
    ggtitle(sprintf('%s Condition, Recentered on semantic', cond))
  
}

