SWOW <- read.csv('manual_SWOW.csv')
DRM <- read.csv('DRM_words.csv')

colnames(SWOW) <- c('cue', 'n_resp', 'word', 'count')
colnames(DRM) <- c('cue', 'word')