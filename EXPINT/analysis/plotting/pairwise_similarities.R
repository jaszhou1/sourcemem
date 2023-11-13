library(ggplot2)
library(ggpubr)
load("~/git/sourcemem/EXPINT/data/recentered_data.RData")

recentered_data$cond[recentered_data$cond == 'orthographic'] <- 'Orthographic'
recentered_data$cond[recentered_data$cond == 'semantic'] <- 'Semantic'
recentered_data$cond[recentered_data$cond == 'unrelated'] <- 'Unrelated'

orth <- ggplot(data = recentered_data) +
  geom_bar(aes(x = orthographic, y = ..prop.., group = cond, fill = cond), 
           color = "black", position="dodge") +
  ylab("Proportion") +
  xlab("Orthographic Distance") +
  scale_x_continuous(breaks = c(1:6)) +
  scale_fill_manual(values = c("#E69F00", "#56B4E9", "#009E73")) +
  guides(fill=guide_legend(title="Condition")) +
  theme(text = element_text(size=14),
        strip.background = element_blank(),
        plot.title = element_text(face = "bold", size = 11),
        legend.position = "none",
        legend.title = element_blank(),
        axis.ticks = element_line(colour = "grey70", size = 0.2),
        axis.line.x = element_line(color="black", size = 0.2),
        axis.line.y = element_line(color="black", size = 0.2),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "white"))

semantic <- ggplot(data = recentered_data) +
  geom_histogram(aes(x = semantic, y = ..ncount.., fill = cond),
                 color = "black", alpha = 0.6, position = "identity", bins = 50) +
  ylab("Density") +
  xlab("Semantic Distance") +
  scale_fill_manual(values = c("#E69F00", "#56B4E9", "#009E73")) +
  theme(text = element_text(size=14),
        strip.background = element_blank(),
        plot.title = element_text(face = "bold", size = 11),
        legend.position = "none",
        legend.title = element_blank(),
        axis.ticks = element_line(colour = "grey70", size = 0.2),
        axis.line.x = element_line(color="black", size = 0.2),
        axis.line.y = element_line(color="black", size = 0.2),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "white"))

plot <- ggarrange(orth, semantic, ncol = 1)

ggsave('pairwise_sim3.png', plot = plot, width = 20, height = 15, units = "cm")