#!/usr/bin/env Rscript

sess_token = commandArgs(trailingOnly=TRUE)[1]

file_name = paste('tmp/', sess_token,'.csv', sep='')

ratings = read.csv(file = file_name, header=FALSE, sep=',', colClasses=c("character", "numeric"))

mean(ratings[,2])
