#Convert lists of stimul (semantic and orthographic lists) into JSON key:value pairs to read into javascript
library(jsonlite)

setwd("~/git/sourcemem/EXPINT/experiment/static/stimuli")
semantic.lists <- read.csv('semantic_lists.csv')
orthographic.lists <- read.csv('orthographic_lists.csv')

semantic.json <- toJSON(semantic.lists, pretty = TRUE)
orthographic.json <- toJSON(orthographic.lists, pretty = TRUE)

write(semantic.json, "semantic-lists.js")
write(orthographic.json, "orthographic-lists.js")