There are 13 models here, which is a lot
The idea is to explore the space with response error models, pick some good ones, and run diffusion versions of those.

My approach was to take the most complicated possible explanation of the data, and remove bits (parameters) until we get the simplest model that satisfactorily exaptures the qualitative intrusion patterns.

1 is the satured model, which has different intrusion weights, guessing proportion, similarity weights and decays

13 is the baseline model, which is basically just the Bays three component mixture model, with no similarity gradients on intrusions (I call this flat gradient).