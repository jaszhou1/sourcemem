library(circular)
data <- read.csv("~/git/sourcemem/EXPINT/data/EXPINT_data.csv")
# Exclude data from practice blocks
data <- data[data$block != -1,]

# Exclude foils
data <- data[data$is_stimulus, ]

# Exclude data with inalid RT
data <- data[data$valid_RT, ]

res<-data.frame(participant=character(0),
                statistic=numeric(0), 
                p.value=numeric(0))

for(i in 1:10){
  this.data <- data[data$participant == i,]
  this.rayleigh <- rayleigh.test(this.data$source_error, mu = 0)
  res <- rbind(res,
               data.frame(participant = i,
                          statistic = this.rayleigh$statistic,
                          p.value = this.rayleigh$p.value))
}


