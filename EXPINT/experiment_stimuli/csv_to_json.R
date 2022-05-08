#Convert lists of stimul (semantic and orthographic lists) into JSON key:value pairs to read into javascript
library(jsonlite)

setwd("~/git/sourcemem/EXPINT/experiment_stimuli")
semantic.lists <- read.csv('semantic_lists_final.csv', fileEncoding="UTF-8-BOM")
orthographic.lists <- read.csv('orthographic_lists_final.csv',fileEncoding="UTF-8-BOM")

semantic.json <- toJSON(semantic.lists, pretty = TRUE)
orthographic.json <- toJSON(orthographic.lists, pretty = TRUE)

write(semantic.json, "semantic-lists.js")
write(orthographic.json, "orthographic-lists.js")