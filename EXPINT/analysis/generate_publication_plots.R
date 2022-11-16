# GENERATE_PUBLICATION_PLOTS
# This is the top-level script that will generate all the plots for my third (and final!) PhD project.
setwd("~/git/sourcemem/EXPINT/analysis/plotting/output/publication")
# Hit rates and false alarms across conditions
source("~/git/sourcemem/EXPINT/analysis/recognition_analyses.R")

HR_FA_cond <- plot_group_recog(TRUE)
ggsave('fig1.png', plot = HR_FA_cond, height = 15, width = 25, units = "cm", dpi = 300)