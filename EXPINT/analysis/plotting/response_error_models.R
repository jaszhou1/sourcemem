# Publication style figure of data and model predictions of source error, 
# pooled across participants, conditioned on word list type.
## Overall charting parameters.
NUM.BINS <- 50
X.AXIS.CEX <- 1.5
Y.AXIS.CEX <- 1.5


group.condition <- function(data, model, filename="") {
  ## Opens a drawing device (either X11 for testing or a
  ## PDF for saving).
  if(filename == "") {
    X11() # Write to the screen
  } else {
    png(file=filename, width=8.3, height=10.7, units = "in", pointsize = 12, res = 300)
    #pdf(file=filename, width=8.3, height=10.7)
  }
  
  # Set axis boundaries
  X.RESP.LOW <- -pi - 0.01
  X.RESP.HI <- pi + 0.01
  Y.RESP.LOW <- 0.0
  Y.RESP.HI <- 1
  
  CONDITIONS <- c('unrelated', 'semantic', 'orthographic')
  
  par(mfrow=c(1, 3))
  par(mar=c(0.1, 0.1, 0.1, 0.1),
      oma=c(4, 4, 3, 4),
      xaxs="i")
  
  ## Iterate through conditions 
  for(cond in CONDITIONS){
    # Filter this participants' data by condition
    this.data <- data[data$condition == cond, ]
    
    ## Plot marginal response proportion for participant.
    par(mar=c(0.1, 1, 1, 1))
    plot.new()
    plot.window(xlim=c(X.RESP.LOW, X.RESP.HI),
                ylim=c(Y.RESP.LOW, Y.RESP.HI))
    
    ## Compute and plot the empirical histograms for response error.
    resp.hist <- hist(this.data$source_error,
                      breaks=NUM.BINS,
                      plot=FALSE)
    for(b in 2:length(resp.hist$breaks)) {
      lo.break <- resp.hist$breaks[b-1]
      hi.break <- resp.hist$breaks[b]
      bar.height <- resp.hist$density[b-1]
      rect(lo.break, 0.0, hi.break, bar.height, border=NA, col="grey80")
    }
    
    ## Plot the model prediction density, with smoothing at the edges so they dont curve down to 0. Circle wrap.
    
    
    ## Plot the x axes (for the last two participants only)
    
    axis(side=1, at=c(-pi, 0, pi), labels=c(expression(-pi), "0", expression(pi)), 
         cex.axis=X.AXIS.CEX)
    mtext(stringr::str_to_title(cond), side=3, cex=1, line=-2, adj=0.1)
    
    
    ## Plot the y axes (for the participants in the first col)
    if((cond) == CONDITIONS[1]) {
      axis(side=2, at=c(0, 1), cex.axis=Y.AXIS.CEX)
    }
  }
  mtext("Error density", side=2, line=2,outer=TRUE, padj = -0.5)
  mtext("Response Error (rads)", side=1, outer = TRUE, line=2.5)
}

#  Function that averages out the tails of model density
get_response_error_density <- function(model){
  preds <- density(as.numeric(model$simulated_error), from = -pi, to = pi, cut = FALSE, kernel = "gaussian")
  # To counteract the smoothing to zero beyond the domain -pi, pi, replace the last 50 y co-ords 
  # with the mean of the preceeding 50
  preds$y[1:50] <- mean(preds$y[51:100])
  preds$y[(length(preds$y)-50):length(preds$y)] <- mean(preds$y[(length(preds$y)-100):(length(preds$y)-50)])
  this_predictions <- data.frame(matrix(ncol = 3, nrow = 512))
  this_predictions[1] <- preds$x
  this_predictions[2] <- preds$y
  this_predictions[3] <- model$model[1]
  return(this_predictions)
}