# Take a word2vec dictionary saved as a numpy object (kindly done by Raina)
# The goal is to serialise it, filter the words wanted, and save as a JSON object to load into R
import numpy as np
import json
vectors = np.load('word2vec.npy', allow_pickle = True).item()
# The .item() bit is quite important here as it keeps the structure of the arrays

# Load in the word list used in the experiment
import csv
import codecs
with open('word2vec_length_final.csv') as csv_file:
    wordlist = csv.reader(codecs.EncodedFile(csv_file, 'utf8', 'utf_8_sig'), delimiter = '\n')
    # There's some stuff ('\xef\xbb\xbf') in my csv which tells computer that file is utf8 encoded.
    # Just reading it in will incorrectly include that as a string

    # Some weird stuff here: I turn the csv_reader object into a list so i can index from it,
    # but this turns each element into a a list of a list of characters, and not a list of strings
    words = list(wordlist)
    words = [''.join(word) for word in words]
    words = [word.lower() for word in words]

# Sort out the word which are in my stimulus pool

# This line is doing a lot, first of all its constructing a new dictionary as a subset of 'vectors', the big dict
# The subset is for those keys in the list of stimuli, and also the value in the dict is to be a list, not a
# numpy array, because json.dump wont take a numpy object.
filtered_vectors = {word:vectors[word].tolist() for word in words if word in vectors}

with open('word2vec_final.json', 'w+') as fp:
    json.dump(filtered_vectors, fp, indent = 4)
