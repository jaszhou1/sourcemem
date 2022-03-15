This subfolder is for the follow-up to "EXPSIM" aka. the intrusion paper.

Here, we are following up on the null result we seem to find of semantic/orthographic similarity
in the online EXPSIM study. While in that case, semantic and orthographic similarity were not 
experimentally manipulated, so not many words were semantically similar, and there were not many
words that had an orthographic distance of 1 in the orthographic analysis, where such an effect
would be strongest.

In this experiment we deliberately construct lists of semantically and orthographically similar
lists of words and running the essentially the same experimental paradigm with different stimuli
pools to see if we can find an effect.

Instead of defining semantic similarity off "word2vec" vector cosine similarity values, we are
instead using free association lists, specifically the "Small World of Words" (SWOW) and instead
of using just Levenshtein distance, we measure orthographic similarity with Damerau–Levenshtein 
distance (counting transpositions as a distance of 1).