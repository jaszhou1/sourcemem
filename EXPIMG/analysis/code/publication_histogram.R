## publication)histogram.R
##
## Procedures for generating publication-quality histogram of response proportions
##  conditional on recognition confidence rating
##
## Jason Zhou <jzhou AT unimelb DOT edu DOT au>

publication.histogram <- function(all, recog, unrecog,
                                        filename="") {
  ## Opens a drawing device (either X11 for testing or a
  ## PDF for saving).
  if(filename == "") {
    X11() # Write to the screen
  } else {
    pdf(file=filename, width=8.3, height=10)
  }
  
  
  ## Set up the global presentation parameters for the plot.
  
  NUM.BINS = 100
  
  X.LOW <- -pi - 0.1
  X.HI <-  pi + 0.1
  Y.LOW <- 0.0
  Y.HI <- 100

  par(mfrow = c(2,3))
  par(cex = 0.8)
  par(mar = c(0.1, 0.1, 0.1, 0.1),
      oma = c(1, 1, 1, 1))
  
  # Plot 
  plot.new()
  plot.window(xlim=c(X.LOW, X.HI),
              ylim=c(Y.LOW, Y.HI))
  box()
  
  hist(recog$response_error, breaks = NUM.BINS,
       freq = TRUE)

  # Plot 
  plot.new()
  plot.window(xlim=c(X.LOW, X.HI),
              ylim=c(Y.LOW, Y.HI))
  box()
  

  # Plot 
  plot.new()
  plot.window(xlim=c(X.LOW, X.HI),
              ylim=c(Y.LOW, Y.HI))
  box()
  

  
  
  if(filename != "") {
    dev.off()
  }

}


dataset <- read.csv('datasetnona.csv')
recog <- dataset[dataset$recog_rating>3,]
unrecog <- dataset[dataset$recog_rating<=3,]

publication.histogram(dataset, recog, unrecog)