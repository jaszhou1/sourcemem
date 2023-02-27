data <- read.csv("~/git/sourcemem/EXPINT/data/EXPINT_data.csv")
data <- data[data$block != -1,]
# Exclude foils
data <- data[data$is_stimulus, ]
# Exclude data with inalid RT
data <- data[data$valid_RT, ]
participants <- unique(data$participant)
setwd("~/git/sourcemem/EXPINT/analysis/plotting/output/publication")
condition.figure <- function(data, filename="") {
  ## Opens a drawing device (either X11 for testing or a
  ## PDF for saving).
  if(filename == "") {
    X11() # Write to the screen
  } else {
    png(file=filename, width=8.3, height=10.7, units = "in", pointsize = 12, res = 300)
    #pdf(file=filename, width=8.3, height=10.7)
  }
  
  
  ## Overall charting parameters.
  NUM.BINS <- 50
  X.AXIS.CEX <- 1.5
  Y.AXIS.CEX <- 1.5
  
  
  ## Get the summary variables from the data.
  PARTICIPANTS <- unique(data$participant)
  NUM.PARTICIPANTS <- length(PARTICIPANTS)
  PARTICIPANTS.PER.ROW <- 1
  
  CONDITIONS <- unique(data$condition)
  
  ## Compute variables required for chart layout.
  NUM.ROWS <- ceiling(NUM.PARTICIPANTS / PARTICIPANTS.PER.ROW)
  NUM.COLS <- PARTICIPANTS.PER.ROW * 3
  
  X.RESP.LOW <- -pi - 0.01
  X.RESP.HI <- pi + 0.01
  Y.RESP.LOW <- 0.0
  Y.RESP.HI <- 2
  
  ## Set up the global presentation parameters for the plot.
  par(mfrow=c(NUM.ROWS, NUM.COLS))
  par(mar=c(0.1, 0.1, 0.1, 0.1),
      oma=c(4, 4, 3, 4),
      xaxs="i")
  
  ## Iterate through each participant...
  for(p.idx in 1:NUM.PARTICIPANTS) {
    p <- PARTICIPANTS[p.idx]
    
    ## Get the participant's data.
    p.data <- data[data$participant==p, ]
    
    ## Iterate through conditions 
    for(cond in CONDITIONS){
      # Filter this participants' data by condition
      this.data <- p.data[p.data$condition == cond, ]
      
      ## Plot marginal response proportion for participant.
      par(mar=c(0.1, 0.1, 0.1, 0.5))
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
      
      ## Plot the participant number and data type
      if((cond) == CONDITIONS[1]) {
        mtext(paste0("P", p), side=3, cex=0.85, line=-2, adj=0.1)
      }
      
      ## Plot the x axes (for the last two participants only)
      if(p %in% tail(PARTICIPANTS, n=PARTICIPANTS.PER.ROW)) {
        axis(side=1, at=c(-pi, 0, pi), labels=c(expression(-pi), "0", expression(pi)), 
             cex.axis=X.AXIS.CEX)
        mtext(paste("Response outcome (rads)"), side=1, cex=0.75, line=2.5)
      } else {
        axis(side=1, at=c(-pi, pi), lwd.ticks=0, labels=FALSE, cex.axis=0.75)
      }
      
      ## Plot the y axes (for the participants in the first col)
      if((cond) == CONDITIONS[1]) {
        axis(side=2, at=c(0, 1), cex.axis=Y.AXIS.CEX)
      }
    }
  }
  
  ## Put the outer margin axis labels.
  mtext("Error density", side=2, line=2,outer=TRUE, padj = -0.5)
  
  ## If we're writing to a file (i.e. a PDF), close the device.
  if(filename != "") {
    dev.off()
  }
}

individual.RT.figure <- function(data,filename="") {
  ## Opens a drawing device (either X11 for testing or a
  ## PDF for saving).
  if(filename == "") {
    X11() # Write to the screen
  } else {
    png(file=filename, width=8.3, height=10.7, units = "in", pointsize = 12, res = 300)
    #pdf(file=filename, width=8.3, height=10.7)
  }
  
  ## Overall charting parameters.
  NUM.BINS <- 50
 
  X.AXIS.CEX <- 1.5
  Y.AXIS.CEX <- 1.5
  
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
  Y.RESP.HI <- 1.5
  
  X.RT.LOW <- 0.0
  X.RT.HI <- 4
  Y.RT.LOW <- 0.0
  Y.RT.HI <- 3
  
  ## Set up the global presentation parameters for the plot.
  par(mfrow=c(NUM.ROWS, NUM.COLS))
  par(mar=c(0.1, 0.1, 0.1, 0.1),
      oma=c(4, 4, 3, 4),
      xaxs="i")
  
  ## Iterate through each participant...
  for(p.idx in 1:NUM.PARTICIPANTS) {
    p <- PARTICIPANTS[p.idx]
    
    ## Get the participant's data.
    p.data <- data[data$participant==p, ]

    ## Plot marginal response proportion for participant.
    par(mar=c(0.1, 0.1, 0.1, 0.5))
    plot.new()
    plot.window(xlim=c(X.RESP.LOW, X.RESP.HI),
                ylim=c(Y.RESP.LOW, Y.RESP.HI))
    
    ## If this is the first row, indicate the column plot type.
    if(p %in% 1:PARTICIPANTS.PER.ROW) {
      mtext("Response outcome", side=3, line=1)
    }
    
    ## Compute and plot the empirical histograms for response error.
    resp.hist <- hist(p.data$source_error,
                      breaks=NUM.BINS,
                      plot=FALSE)
    for(b in 2:length(resp.hist$breaks)) {
      lo.break <- resp.hist$breaks[b-1]
      hi.break <- resp.hist$breaks[b]
      bar.height <- resp.hist$density[b-1]
      rect(lo.break, 0.0, hi.break, bar.height, border=NA, col="grey80")
    }
    
    ## Plot the participant number and data type
    mtext(paste0("P", p), side=3, cex=0.85, line=-2, adj=0.1)
    
    ## Plot the x axes (for the last two participants only)
    if(p %in% tail(PARTICIPANTS, n=PARTICIPANTS.PER.ROW)) {
      axis(side=1, at=c(-pi, 0, pi), labels=c(expression(-pi), "0", expression(pi)), 
           cex.axis=X.AXIS.CEX)
      mtext(paste("Response outcome (rads)"), side=1, cex=0.75, line=2.5)
    } else {
      axis(side=1, at=c(-pi, pi), lwd.ticks=0, labels=FALSE, cex.axis=0.75)
    }
    
    ## Plot the y axes (for the participants in the first col)
    if((p.idx %% PARTICIPANTS.PER.ROW) == 1) {
      axis(side=2, at=c(0, 1.5), cex.axis=Y.AXIS.CEX)
    }
    
    ## Plot marginal response time for participant.
    par(mar=c(0.1, 0.7, 0.1, 1.5))
    plot.new()
    plot.window(xlim=c(X.RT.LOW, X.RT.HI),
                ylim=c(Y.RT.LOW, Y.RT.HI))
    
    ## If this is the first row, indicate the column plot type.
    if(p %in% 1:PARTICIPANTS.PER.ROW) {
      mtext("Response time", side=3, line=1)
    }
    
    ## Compute and plot the empirical histograms for response time.

    rt.hist <- hist((p.data$source_RT/1000), 
                    breaks=NUM.BINS,
                    plot=FALSE)
    for(b in 2:length(rt.hist$breaks)) {
      lo.break <- rt.hist$breaks[b-1]
      hi.break <- rt.hist$breaks[b]
      bar.height <- rt.hist$density[b-1]
      rect(lo.break, 0.0, hi.break, bar.height, border=NA, col="grey80")
    }
    
    ## Plot the participant number 
    ## mtext(paste0("P", p), side=3, cex=0.5, line=-2, adj=0.8)
    
    if(p %in% tail(PARTICIPANTS, n=PARTICIPANTS.PER.ROW)) {
      axis(side=1, at = c(0, 2, 4), cex.axis=X.AXIS.CEX)
      mtext(paste("Response time (s)"), side=1, cex=0.75, line=2.5)
    } else {
      axis(side=1, at=c(0, 2, 4), lwd.ticks=0, labels=FALSE, cex.axis=0.75)
    }
    
    if((p.idx %% PARTICIPANTS.PER.ROW) == 0) {
      axis(side=4, at=c(0, 3), cex.axis=X.AXIS.CEX)
    }
  }
  
  ## Put the outer margin axis labels.
  mtext("Error density", side=2, line=2,outer=TRUE, padj = -0.5)
  mtext("RT density", side=4, line=2, outer=TRUE)
  ##mtext("Response time/response error", side=1, line=2, outer=TRUE)
  
  if(filename != "") {
    dev.off()
  }
}

individual.error.figure <- function(data,filename="") {
  ## Opens a drawing device (either X11 for testing or a
  ## PDF for saving).
  if(filename == "") {
    X11() # Write to the screen
  } else {
    png(file=filename, width=10, height=6, units = "in", pointsize = 12, res = 300)
    #pdf(file=filename, width=8.3, height=10.7)
  }
  
  ## Overall charting parameters.
  NUM.BINS <- 50
  
  X.AXIS.CEX <- 1.5
  Y.AXIS.CEX <- 1.5
  
  ## Get the summary variables from the data.
  PARTICIPANTS <- unique(data$participant)
  NUM.PARTICIPANTS <- length(PARTICIPANTS)
  PARTICIPANTS.PER.ROW <- 5
  MODEL.TYPES <- unique(as.character(data$model_name))
  
  ## Compute variables required for chart layout.
  NUM.ROWS <- ceiling(NUM.PARTICIPANTS / PARTICIPANTS.PER.ROW)
  NUM.COLS <- PARTICIPANTS.PER.ROW 
  
  X.RESP.LOW <- -pi - 0.01
  X.RESP.HI <- pi + 0.01
  Y.RESP.LOW <- 0.0
  Y.RESP.HI <- 1.5
  
  X.RT.LOW <- 0.0
  X.RT.HI <- 4
  Y.RT.LOW <- 0.0
  Y.RT.HI <- 3
  
  ## Set up the global presentation parameters for the plot.
  par(mfrow=c(NUM.ROWS, NUM.COLS))
  par(mar=c(0.1, 0.1, 0.1, 0.1),
      oma=c(4, 4, 3, 4),
      xaxs="i")
  
  ## Iterate through each participant...
  for(p.idx in 1:NUM.PARTICIPANTS) {
    p <- PARTICIPANTS[p.idx]
    
    ## Get the participant's data.
    p.data <- data[data$participant==p, ]
    
    ## Plot marginal response proportion for participant.
    par(mar=c(0.1, 1, 1, 1))
    plot.new()
    plot.window(xlim=c(X.RESP.LOW, X.RESP.HI),
                ylim=c(Y.RESP.LOW, Y.RESP.HI))
    
    ## Compute and plot the empirical histograms for response error.
    resp.hist <- hist(p.data$source_error,
                      breaks=NUM.BINS,
                      plot=FALSE)
    for(b in 2:length(resp.hist$breaks)) {
      lo.break <- resp.hist$breaks[b-1]
      hi.break <- resp.hist$breaks[b]
      bar.height <- resp.hist$density[b-1]
      rect(lo.break, 0.0, hi.break, bar.height, border=NA, col="grey80")
    }
    
    ## Plot the participant number and data type
    mtext(paste0("P", p), side=3, cex=1, line=-2, adj=0.1)
    
    ## Plot the x axes (for the last two participants only)
    if(p %in% tail(PARTICIPANTS, n=PARTICIPANTS.PER.ROW)) {
      axis(side=1, at=c(-pi, 0, pi), labels=c(expression(-pi), "0", expression(pi)), 
           cex.axis=X.AXIS.CEX)
  
    } else {
      axis(side=1, at=c(-pi, pi), lwd.ticks=0, labels=FALSE, cex.axis=0.75)
    }
    
    ## Plot the y axes (for the participants in the first col)
    if((p.idx %% PARTICIPANTS.PER.ROW) == 1) {
      axis(side=2, at=c(0, 1.5), cex.axis=Y.AXIS.CEX)
    }
  }
  
  ## Put the outer margin axis labels.
  mtext("Error density", side=2, line=2,outer=TRUE, padj = -0.5)
  mtext("Response Error (rads)", side=1, outer = TRUE, line=2.5)

  if(filename != "") {
    dev.off()
  }
}