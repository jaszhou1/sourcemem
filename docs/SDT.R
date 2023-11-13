dataframe <- data.frame(matrix(nrow = 100, ncol = 3))
colnames(dataframe) <- c('x', 'y1', 'y2')
dataframe$x <- seq(-4, 4, length=100)
dataframe$y1 <- dnorm(dataframe$x, mean = -1, sd = 1)
dataframe$y2 <- dnorm(dataframe$x, mean = 1, sd = 1)

SDT <- ggplot(data = dataframe) +
  geom_area(aes(x = x, y = y1), lwd = 1, color = 'peru', fill = 'burlywood2', alpha = 0.5) +
  geom_area(aes(x = x, y = y2), lwd = 1, color = 'red', fill = 'red', alpha = 0.3) +
  geom_segment(x = 0.5, y = 0, xend = 0.5, yend = 0.6, linetype="dashed", 
               color = "black", size=1) +
  xlab("Memory Strength") + 
  scale_y_continuous(limits = c(0, 0.6)) +
  geom_text(x = 0, y = 0.48, label = 'Response\nCriterion', size = 4) +
  geom_text(x = -2, y = 0.6, label = 'Respond "New"', size = 5) +
  geom_text(x = 2, y = 0.6, label = 'Respond "Old"', size = 5) +
  geom_text(x = 2.6, y = 0.3, label = 'Studied Items', color = 'red', size = 4.5) +
  geom_text(x = -2.2, y = 0.3, label = 'Lures', color = 'peru', size = 4.5) +
  theme(text = element_text(size=14),
        legend.position = "none",
        legend.title = element_blank(),
        axis.ticks = element_blank(),
        axis.line.x = element_line(color="black", size = 1),
        axis.line.y = element_blank(),
        axis.text.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "white"),
        plot.margin = margin(1,0,0,0, "cm"))
setwd("~/PhD Documents/docs/thesis")
ggsave('SDT.png', plot = SDT, width = 18, height = 10, units = "cm")