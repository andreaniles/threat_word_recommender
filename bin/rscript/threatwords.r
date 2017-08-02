#!/usr/bin/env Rscript

sess_token = commandArgs(trailingOnly=TRUE)[1]

file_name = paste('/app/tmp/', sess_token,'.csv', sep='')

ratings = read.csv(file = file_name, header=FALSE, sep=',', colClasses=c("character", "numeric"))


training.data <- read.csv("vendor/norm_mturk_ratings.csv", sep=",", header=TRUE)
training.data <- training.data[,-1]

# normalize the data
center_rowmeans <- function(x) {
	xcenter = rowMeans(x, na.rm=TRUE)
	x-rep(xcenter,times=ncol(x))
}
ratings.norm <- center_rowmeans(ratings)

words <- as.matrix(colnames(training.data))
words <- cbind(words, c(NA))
words[,2] <- runif(514,0,1)
words.sorted <- as.matrix(words[order(words[,2]),1])

print(words.sorted[1:60])