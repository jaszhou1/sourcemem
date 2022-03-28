## Take the word2vec embeddings, reduce the dimensionality to make it easier to work with, 
# then do k-means cluster to get some word clusters to base the semantic lists on

library(rjson)
library(FactoMineR)
library(stats)
word2vec <- fromJSON(file = 'word2vec2.json')

# PCA, reduce down to 5 dimensions
res.pca <- PCA(word2vec,500, graph = FALSE)

# plot of the eigenvalues
## barplot(res.pca$eig[,1],main="Eigenvalues",names.arg=1:nrow(res.pca$eig))

reduced.dim.list <- res.pca$var$coord

# k-means
res.kmeans <- kmeans(reduced.dim.list, 40)
clustered.list <- res.kmeans$cluster

# Turn cluster list into dataframe
clustered.list <- data.frame(keyName=names(clustered.list), value=clustered.list, row.names=NULL)