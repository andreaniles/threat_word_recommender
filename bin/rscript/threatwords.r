#!/usr/bin/env Rscript
rm(list=ls())
options(warn=-1)

root_path = commandArgs(trailingOnly=TRUE)[1]
ratings_file_name = commandArgs(trailingOnly=TRUE)[2]


##################################
###### Recommender System ########
##################################

numbertorecommend = 60
numwordsgiven = 55 
popamp = 1.5 #seq(from = 0, to = 3, by = .5) # m
neighbors = 30 #seq(from = 10, to = 50, by = 10) # k
alpha = 1 #seq(from = .75, to = 3, by = .25) #n
datasetsize = 837 #seq(from = 100, to = 800, by = 100) #l
simvalue = .3 # seq(from = .2, to = .4, by = .05) #o

filewide = paste(root_path, "/vendor/ratings_forrecommender_threat.csv", sep='')
print filewide
##FUNCTIONS

# normalize the data
center_rowmeans <- function(x) {
  xcenter = rowMeans(x, na.rm=TRUE)
  x-rep(xcenter,times=ncol(x))
}

#discount factor
discount_factor <- function(x) {
  B <- 10
  if(x < B) {
    x/B
  }
  else {
    1
  }
}

## GET DATA
print file_name
ratings <- read.csv(ratings_file_name, header=T, sep=",", colClasses=c("character", "numeric"))

user.word.ratings <- ratings
user.word.ratings <- as.matrix(user.word.ratings[,-1])
rownames(user.word.ratings) <- ratings[,1]
user.word.ratings <- t(user.word.ratings)

training.data <- read.csv(filewide, sep=",", header=T)

# add rownames
data.rownames <- training.data

rownames(data.rownames) <- data.rownames[,1]

data.rownames <- data.rownames[,-1]

#calculate offset
  #mean of all words: 4.991416
  #mean of rated words: 6.871879
  #offset = 1.880463

#normalize training data and user data
normdat <- center_rowmeans(data.rownames)
norm.user.ratings <- center_rowmeans(user.word.ratings)

## GET SIMILARITY BETWEEN USER AND TEST DATA

   # Create a placeholder dataframe listing user vs. user
  data.similarity  <- matrix(NA, nrow=nrow(normdat),
                           ncol=1, dimnames=list(rownames(normdat)))
   word.overlap <- matrix(NA, nrow=nrow(normdat),
                          ncol=1, dimnames=list(rownames(normdat)))
   
   ## Create neighbors dataset with only ratings being used

  neighbor.dat <- normdat[,ratings$word]
   
   # Fill similarity matrix with correlation coefficients
      
  for(i in 1:nrow(neighbor.dat)) {
         
    u1ratings <- as.numeric(neighbor.dat[i,])
    u2ratings <- as.numeric(user.word.ratings[1,])
         
    compare <- u1ratings & u2ratings
    commonwords <- sum(compare * rep(1, numwordsgiven), na.rm=TRUE)
    word.overlap[i,1] <- commonwords
         
    if (commonwords < 3) {
     data.similarity[i,1] <- NA
    }
    else {
     data.similarity[i,1] <- cor(u1ratings,u2ratings,use = "complete.obs")  
    }
  }                         
                           
## GET RECOMMENDATIONS
  
  #discount similarities based on few words
                          
  for(g in 1:nrow(word.overlap))
  {
    if(word.overlap[g,1]<20) {
    data.similarity[g,1]<- data.similarity[g,1]*(word.overlap[g,1]/20)
    }
  }
  
  data.similarity<-data.similarity ^ alpha
      
   #loop to identify recommendations           
    predratings <- matrix(NA, nrow=1, ncol=ncol(normdat))
    colnames(predratings) <- colnames(normdat)
    for(v in 1:ncol(normdat))
     {              
       ratings_nomiss<-normdat[!is.na(normdat[,v]),v,drop=FALSE]
       simnomiss<-as.matrix(data.similarity[rownames(ratings_nomiss),1])
       simsortnomiss<-as.matrix(simnomiss[order(simnomiss,decreasing=TRUE),1])
       topN<-as.matrix(simsortnomiss[1:neighbors,1])
       topN.names <- as.character(rownames(topN))
       topN.similarities <- as.numeric(topN)       
       topN.similarities <- topN.similarities[!topN.similarities<simvalue]
       if(length(topN.similarities)==0){
         predratings[,v] <- colMeans(data.rownames[,v], na.rm=TRUE) 
       }
       else {
         topN.ratings<- as.matrix(normdat[c(topN.names),v])
         topN.weightedratings<-topN.similarities*topN.ratings[1:length(topN.similarities)]
         weightsum <- sum(abs(topN.similarities), na.rm=TRUE)
         topN.avgratings <- sum(topN.weightedratings, na.rm=TRUE)/weightsum
         predratings[,v] <- topN.avgratings+mean(user.word.ratings, na.rm=TRUE) + 1.880463       
       }
     }

    ratingsforrec <- as.matrix(predratings)
    recs.and.ratings <- t(as.matrix(head(((ratingsforrec[,order(as.numeric(ratingsforrec), decreasing=TRUE)])), n=numbertorecommend)))
    recs <- as.matrix(colnames(recs.and.ratings))
    print(recs)
