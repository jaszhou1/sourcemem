sort_stimuli takes in the SWOW words and runs a coarse filter: cues and responses all 5 letters long, and more than 25 responses

compare_cosine takes in the filtered SWOW set and the stimuli from the DRM paper and compares the semantic similarity, quantified with the word2vec cosine vectors, and takes SWOW lists that are similar to the DRM lists

second_pass then takes in manually checked SWOW sets and does a final check for semantic similarity.