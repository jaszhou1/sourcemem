## publicationfigure.R
##
## Procedures for generating publication-quality figures 
## from the marginal data and model fits
##
## Jason Zhou <jzhou AT unimelb DOT edu DOT au>

## Construct a figure based on the concatenated marginal 
## response proportions and response times from both the 
## empirical data and the circular diffusion predictions.
## This is a B.A.F = Big a** function
marginal.publication.figure <- function(data, empirical.data,
                                        filename="") {
  ## Opens a drawing device (either X11 for testing or a
  ## PDF for saving).
  if(filename == "") {
    X11() # Write to the screen
  } else {
    pdf(file=filename, width=7, height=10)
  }
  
  ## Use only the model predictions from the density data frame.
  data <- data[data$is_model, ]
  
  ## Overall charting parameters.
  NUM.BINS <- 50
  MODEL.LTY <- list(
    "Cont"=1,
    "Hybrid"=2,
    "Thresh"=3
  )
  
  ## Get the summary variables from the data.
  PARTICIPANTS <- unique(data$participant)
  NUM.PARTICIPANTS <- length(PARTICIPANTS)
  PARTICIPANTS.PER.ROW <- 2
  MODEL.TYPES <- unique(as.character(data$model_name))
  
  ## Compute variables required for chart layout.
  NUM.ROWS <- ceiling(NUM.PARTICIPANTS / PARTICIPANTS.PER.ROW)
  NUM.COLS <- PARTICIPANTS.PER.ROW * 2
  
  X.RESP.LOW <- -pi - 0.01
  X.RESP.HI <- pi + 0.01
  Y.RESP.LOW <- 0.0
  Y.RESP.HI <- max(data[data$is_theta, "prob"]) + 0.01
  
  X.RT.LOW <- 0.0
  X.RT.HI <- min(max(data[!data$is_theta, "value"]), 2.0) + 0.01
  Y.RT.LOW <- 0.0
  Y.RT.HI <- max(data[!data$is_theta, "prob"]) + 0.001
  
  ## Set up the global presentation parameters for the plot.
  par(mfrow=c(NUM.ROWS, NUM.COLS))
  par(mar=c(0.5, 0.5, 0, 0.5),
      oma=c(4, 3.5, 0, 3.5))
  
  ## Iterate through each participant...
  for(p.idx in 1:NUM.PARTICIPANTS) {
    p <- PARTICIPANTS[p.idx]
    
    ## Get the participant's data.
    p.model <- data[(data$participant==p), ]
    p.rt.model <- p.model[(!p.model$is_theta) & (p.model$value > 0), ]
    p.resp.model <- p.model[(p.model$is_theta), ]
    p.data <- empirical.data[empirical.data$participant==p, ]
    
    #p.resp.hist <- hist(p.data$response_error, plot=FALSE)
    #p.rt.hist <- hist(p.data$response_RT, plot=FALSE)
    
    ## Plot marginal response proportion for participant.
    plot.new()
    plot.window(xlim=c(X.RESP.LOW, X.RESP.HI),
                ylim=c(Y.RESP.LOW, Y.RESP.HI))
    
    ## Compute and plot the empirical histograms for response error.
    resp.hist <- hist(p.data$response_error,
                      breaks=NUM.BINS, freq=FALSE,
                      plot=FALSE)
    for(b in 2:length(resp.hist$breaks)) {
      lo.break <- resp.hist$breaks[b-1]
      hi.break <- resp.hist$breaks[b]
      bar.height <- resp.hist$density[b-1]
      rect(lo.break, 0.0, hi.break, bar.height, border=NA, col="grey70")
    }
    
    ## Plot the predicted density of the models.
    for(model.type in MODEL.TYPES) {
      model.data <- p.resp.model[p.resp.model$model_name == model.type, ]
      points(model.data$value, model.data$prob, type="l", lty=MODEL.LTY[[model.type]])
    }
    
    ## Plot the participant number and data type
    mtext(paste0("P", p, " Error"), side=3, cex=0.5, line=-2, adj=0.2)
    
    ## Plot the x axes (for the last two participants only)
    if(p %in% tail(PARTICIPANTS, n=PARTICIPANTS.PER.ROW)) {
      axis(side=1, at=c(-pi, 0, pi), labels=c("-pi", "0", "pi"), cex.axis=0.75)
      mtext(paste("Response error (rads)"), side=1, cex=0.6, line=2.5)
    } else {
      axis(side=1, at=c(-pi, pi), lwd.ticks=0, labels=FALSE, cex.axis=0.75)
    }
    
    ## Plot the y axes (for the participants in the first col)
    if((p.idx %% PARTICIPANTS.PER.ROW) == 1) {
      axis(side=2, at=c(0, 1), cex.axis=0.75)
    }
    
    ## Plot marginal response time for participant.
    plot.new()
    plot.window(xlim=c(X.RT.LOW, X.RT.HI),
                ylim=c(Y.RT.LOW, Y.RT.HI))
    
    ## Compute and plot the empirical histograms for response time.
    rt.hist <- hist(p.data$response_RT, 
                    breaks=NUM.BINS, freq=FALSE,
                    plot=FALSE)
    for(b in 2:length(rt.hist$breaks)) {
      lo.break <- rt.hist$breaks[b-1]
      hi.break <- rt.hist$breaks[b]
      bar.height <- rt.hist$density[b-1]
      rect(lo.break, 0.0, hi.break, bar.height, border=NA, col="grey70")
    }
    
    ## Plot the predicted density of the models.
    for(model.type in MODEL.TYPES) {
      model.data <- p.rt.model[p.rt.model$model_name == model.type, ]
      points(model.data$value, model.data$prob, type="l" , lty=MODEL.LTY[[model.type]])
    }
    
    ## Plot the particiapnt number and data type
    mtext(paste0("P", p, " RT"), side=3, cex=0.5, line=-2, adj=0.8)
    
    if(p %in% tail(PARTICIPANTS, n=PARTICIPANTS.PER.ROW)) {
      axis(side=1, cex.axis=0.75)
      mtext(paste("Response time (s)"), side=1, cex=0.6, line=2.5)
    } else {
      axis(side=1, at=c(0, 2), lwd.ticks=0, labels=FALSE, cex.axis=0.75)
    }
    
    if((p.idx %% PARTICIPANTS.PER.ROW) == 0) {
      axis(side=4, at=c(0, 2), cex.axis=0.75)
    }
  }
  
  ## Put the outer margin axis labels.
  mtext("Error density", side=2, line=2, outer=TRUE)
  mtext("RT density", side=4, line=2, outer=TRUE)
  ##mtext("Response time/response error", side=1, line=2, outer=TRUE)
  
  ## If we're writing to a file (i.e. a PDF), close the device.
  if(filename != "") {
    dev.off()
  }
}

marginal.publication.figure(density, dataset)