## publicationfigure_qxq.R
##
## Procedures for generating publication-quality figures 
## from the QxQ data and model fits.
##
## Jason Zhou <jzhou AT unimelb DOT edu DOT au>

## Construct a figure based on the concatenated marginal 
## response proportions and response times from both the 
## empirical data and the circular diffusion predictions.


joint.publication.figure <- function(data, empirical.data,
                                        filename="") {
  ## Opens a drawing device (either X11 for testing or a
  ## PDF for saving).
  if(filename == "") {
    X11() # Write to the screen
  } else {
    png(file=filename, width=8.3, height=10.7, units = "in", pointsize = 12, res = 300)
    #pdf(file=filename, width=8.3, height=10.7)
  }
  
  
  ## Overall charting parameters.
  # Models by line type
  MODEL.LTY <- list(
    "Cont"=1,
    "Thresh"=2
  )
  
  # Models by Colour
  MODEL.COL <- list(
    "Cont"="#CC79A7",
    "Thresh"= "#009E73"
  )
  
  
  # #Quantile by Character 
  QUANTILE.PCH <- list(
    "0.1"=15,
    "0.5"=19,
    "0.9"=17
  )
  

  
  ## Get the summary variables from the data.
  PARTICIPANTS <- unique(dataset$participant)
  NUM.PARTICIPANTS <- length(PARTICIPANTS)
  PARTICIPANTS.PER.ROW <- 4
  MODEL.TYPES <- unique(as.character(data$model_name))
  QUANTILES <- unique(as.character(data$quantile_idx))
  
  ## Compute variables required for chart layout.
  NUM.ROWS <- ceiling(NUM.PARTICIPANTS / PARTICIPANTS.PER.ROW)
  NUM.COLS <- PARTICIPANTS.PER.ROW
  
  X.AXIS.CEX <- 1.0
  Y.AXIS.CEX <- 1.0
  
  INNER.X.AXIS.CEX <- 1.0
  INNER.Y.AXIS.CEX <- 1.0
  
  X.LOW <- 0.0
  X.HI <- max(dataset$theta) + 0.01
  Y.LOW <- 0.0
  Y.HI <- max(dataset$rt) + 0.001
  
  ## Set up the global presentation parameters for the plot.
  par(mfrow=c(NUM.ROWS, NUM.COLS))
  par(mar=c(0.5, 0.5, 0.5, 0.5),
      oma=c(3.5, 3.5, 3.5, 3.5))
  
  # Iterate through participants
  for(p.idx in 1:NUM.PARTICIPANTS) {
    p <- PARTICIPANTS[p.idx]
    
  
    
    # Get model predictions and data points for this participant
    p.model <- data[(data$participant==p), ]
    p.data <- empirical.data[empirical.data$participant==p, ]
    
    
    plot.new()
    plot.window(xlim=c(X.LOW, X.HI),
                ylim=c(Y.LOW, Y.HI))
    # vv Debug
    box()
    # ^^
    # Plot participant number
    mtext(paste0("P", p), side=3, cex=0.85, line=-2, adj=0.1)
    
    ## Plot the data quantiles
    for(quantile.no in QUANTILES) {
      data.quantile <- p.data[p.data$quantile_idx == quantile.no,]
      points(data.quantile$theta, data.quantile$rt, type="p", pch = QUANTILE.PCH[[quantile.no]],cex=1.2)
      
      
    ## Plot the predicted density of the models.
    for(model.type in MODEL.TYPES) {
        model.data <- p.model[p.model$model_name == model.type, ]
    # Plot each quantile for that model
        for(quantile.no in QUANTILES) {
          model.quantile <- model.data[model.data$quantile_idx == quantile.no,]
          points(model.quantile$theta, model.quantile$rt, type="l",  lty=2,
                 col=MODEL.COL[[model.type]])
        }
      }
    }
    
    ## Plot the x axes (for the last four participants only)
    if(p %in% tail(PARTICIPANTS, n=PARTICIPANTS.PER.ROW)) {
      axis(side=1, at=c(0, pi/4, pi/2, (3*pi)/4), 
           labels=c("0", expression(pi/4), 
                    expression(pi/2), expression(3*pi/4)), 
           cex.axis=INNER.X.AXIS.CEX)
    } else {
      axis(side=1, at=c(-pi, pi), lwd.ticks=0, labels=FALSE, cex.axis=INNER.X.AXIS.CEX)
    }
    
    
    ## Plot the y axes (for the participants in the first col)
    if((p.idx %% PARTICIPANTS.PER.ROW) == 1) {
      axis(side=2, at=c(0, 1, 2, 3), cex.axis=INNER.Y.AXIS.CEX)
    }
  }
  ## Put the outer margin axis labels.
  mtext("Response Time (s)", side=2, line=2, outer=TRUE)
  mtext("Response Error (rads)", side=1, line=2, outer=TRUE)
  
  ## Add in legend
  #blank plots to fill in the space where I want the legend to go
  plot.new()
  #allow clipping
  par(xpd = NA)
  ##legend("bottomright", inset = c(0.4,0), legend=c("V-P", "Threshold", "Hybrid"),
          ##lty=c(2,2,2),col= c("#CC79A7","#E69F00","#009E73"), bty = "n",cex = INNER.X.AXIS.CEX, title="Models")
  legend("bottomright", inset = c(0.4,0), legend=c("V-P", "Threshold"),
         lty=c(2,2,2),col= c("#CC79A7","#009E73"), bty = "n",cex = INNER.X.AXIS.CEX, title="Models")
  legend("bottomright", inset = c(0,0), legend=c("0.1", "0.5", "0.9"),
         pch=c(15,19,17), bty = "n",cex=1,
         title = "Quantiles")
  
  ## If we're writing to a file (i.e. a PDF), close the device.
  if(filename != "") {
    dev.off()
    }
}

## Read in model predictions
Cont <- read.csv('simulated_cont.csv')
Thresh <- read.csv('simulated_thresh.csv')

models <- rbind(Cont,Thresh)
models$is_model <- models$is_model == ' true'

## Read in empirical data
dataset <- Cont[Cont$is_model == ' false',]
dataset$quantile_idx <- as.factor(dataset$quantile_idx)

joint.publication.figure(models, dataset)