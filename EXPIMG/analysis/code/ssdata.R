ssdata <- function(x) {
  rts <- as.numeric(as.character(dataset[dataset$participant==x, "response_RT"]))
  rts <- rts[rts < 1.5]
  return(rts)
}

plot.ssdata <- function(x) {
  png(filename=paste0("ssdata-", x, ".png"))
  plot(ssdata(x))
  dev.off()
}

