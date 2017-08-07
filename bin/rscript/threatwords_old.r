#!/usr/bin/env Rscript

root_path = commandArgs(trailingOnly=TRUE)[1]
file_name = commandArgs(trailingOnly=TRUE)[2]

ratings = read.csv(file = file_name, header=TRUE, sep=',', colClasses=c("character", "numeric"))

# file_name = paste('/app/tmp/', sess_token,'.csv', sep='')

training_file = paste(root_path, "/vendor/norm_mturk_ratings.csv", sep="")
training.data <- read.csv(training_file, sep=",", header=TRUE)
training.data <- training.data[,-1]

# normalize the data
# center_rowmeans <- function(x) {
# 	xcenter = colMeans(x, na.rm=TRUE)
# 	x-rep(xcenter,times=ncol(x))
# }
# ratings.norm <- center_rowmeans(ratings[,2])
words <- as.matrix(colnames(training.data))
words <- cbind(words, c(NA))
words[,2] <- runif(513,0,1)
words.sorted <- as.matrix(words[order(words[,2]),1])

print(words.sorted[1:60])
