#Set a clean and new directory
setwd("C:\\R")
# Download the data
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")
# Unzip the file
unzip(zipfile="./data/Dataset.zip",exdir="./data")
dtPath <- file.path("./data" , "UCI HAR Dataset")
# Installing and loading necessary packages
install.packages("RCurl")
install.packages("reshape2")
install.packages("data.table")
library("RCurl")
library("reshape2")
library("data.table")

# PART 1. Merges the training and the test sets to create one data set.
#Read the Activity files and merge them
dtActTest  <- read.table(file.path(dtPath, "test" , "Y_test.txt" ),header = FALSE)
dtActTrain <- read.table(file.path(dtPath, "train", "Y_train.txt"),header = FALSE)
dtActivity<- rbind(dtActTrain, dtActTest)
#Read the Subject files
dtSubTrain <- read.table(file.path(dtPath, "train", "subject_train.txt"),header = FALSE)
dtSubTest  <- read.table(file.path(dtPath, "test" , "subject_test.txt"),header = FALSE)
dtSubject <- rbind(dtSubTrain, dtSubTest)

#Read Fearures files
dtFtrsTest  <- read.table(file.path(dtPath, "test" , "X_test.txt" ),header = FALSE)
dtFtrsTrain <- read.table(file.path(dtPath, "train", "X_train.txt"),header = FALSE)
dtFeatures<- rbind(dtFtrsTrain, dtFtrsTest)

# PART 2 Extracts only the measurements on the mean and standard deviation for each measurement.
# naming them
dtFtrsNames <- read.table(file.path(dtPath, "features.txt"),head=FALSE)
nmIndex<-dtFtrsNames$V2[grep("mean\\(\\)|std\\(\\)", dtFtrsNames$V2)]
dtFeatures<-dtFeatures[,nmIndex]

# PART 3: Uses descriptive activity names to name the activities in the data set
names<-dtFeatures[nmIndex,2] 
names(dtFeatures)<-names
names(dtSubject)<-"SubjectID"
names(dtActivity)<-"Activity"
# PART 4: Appropriately labels the data set with descriptive variable names.
# combining all the data together
dtComb <- cbind(dtSubject, dtActivity)
dtFinal <- cbind(dtFeatures, dtComb)

actLabels <- read.table(file.path(dtPath, "activity_labels.txt"),header = FALSE)
names(dtFinal)<-gsub("^t", "Time", names(dtFinal))
names(dtFinal)<-gsub("^f", "Frequency", names(dtFinal))
names(dtFinal)<-gsub("Acc", "Accelerometer", names(dtFinal))
names(dtFinal)<-gsub("Gyro", "Gyroscope", names(dtFinal))
names(dtFinal)<-gsub("Mag", "Magnitude", names(dtFinal))
names(dtFinal)<-gsub("BodyBody", "Body", names(dtFinal))
# PART 5: From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
dtFinal<-data.table(dtFinal)
TidyData <- dtFinal[, lapply(.SD, mean), by = 'SubjectID,Activity']
write.table(TidyData, file = "Tidy.txt", row.names = FALSE)
