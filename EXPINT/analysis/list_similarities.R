# Illustrate the similarity difference of the lists that participants saw
library(ggplot2)
library(data.table)
library(ggpubr)

## Looking at data prior to modelling
data <- read.csv("~/git/sourcemem/EXPINT/data/EXPINT_data.csv")
data <- na.omit(data)

data[data$condition == 'semantic', 'condition'] <- 'Semantic'
data[data$condition == 'orthographic', 'condition'] <- 'Orthographic'
data[data$condition == 'unrelated', 'condition'] <- 'Unrelated'



orth.data <- melt(setDT(data), id.vars = c('participant', 'session', 'block', 'condition'), measure.vars = c('ortho1', 'ortho2', 'ortho3', 'ortho4', 'ortho5', 'ortho6', 'ortho7'))
sem.data <- melt(setDT(data), id.vars = c('participant', 'session', 'block', 'condition'), measure.vars = c('semantic1', 'semantic2', 'semantic3', 'semantic4', 'semantic5', 'semantic6', 'semantic7'))
# Turn semantic similarity into distance
sem.data$value = 1- sem.data$value 
sem.data <- sem.data[!((sem.data$condition == 'Semantic') & (sem.data$value < 0.3)),]

orthographic.similarities <- ggplot(data = orth.data, aes(x = value, fill = condition)) +
  geom_bar(color = "black", position = "dodge") +
  scale_x_continuous(name = 'Orthographic Distance', 
                   breaks = 1:6, 
                   labels = c(1,2,3,4,5,6)) +
  scale_y_continuous(name = 'Frequency', 
                   breaks = c(0, 6000, 12000), 
                   labels = c(0, 6000, 12000)) +
  scale_fill_manual(name = 'Condition', values=c("#E69F00", "#56B4E9", "#009E73")) +
  theme(legend.position = 'right',
        panel.background =  element_rect(fill = "white"),
        panel.border = element_rect(linetype = "solid", fill = NA),
        text=element_text(size=16))

sem.similarities <- ggplot(data = sem.data, aes(x = value)) +
  geom_histogram(data=subset(sem.data,condition == 'Orthographic'),color = "#E69F00", fill = "#E69F00", alpha = 0.6) +
  geom_histogram(data=subset(sem.data,condition == 'Semantic'),color = "#56B4E9", fill = "#56B4E9", alpha = 0.6) +
  geom_histogram(data=subset(sem.data,condition == 'Unrelated'),color = "#009E73", fill = "#009E73", alpha = 0.6) +
  scale_x_continuous(name = 'Semantic Distance',
                     breaks = c(0, 0.25, 0.5, 0.75, 1),
                     labels = c(0, 0.25, 0.5, 0.75, 1)) +
  scale_y_continuous(name = 'Frequency', 
                     breaks = c(0, 4000), 
                     labels = c(0, 4000)) +
  theme(legend.position = 'none',
        panel.background =  element_rect(fill = "white"),
        panel.border = element_rect(fill = NA),
        text=element_text(size=16))

setwd("~/git/sourcemem/EXPINT/analysis/plotting/output")
plot <- ggarrange(orthographic.similarities, NULL, sem.similarities, ncol = 1, heights = c(1, 0.1, 1), common.legend = TRUE, legend="none")
#ggsave('list_comparison_v2.png', plot = last_plot(), width = 25, height = 20, units = "cm")