# Set the working directory
setwd("C:/R")
# Download and unzip the data
library(dplyr)
library(tidyr)

fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileurl,"dataset.zip" , method="curl")
unzip("dataset.zip")

# Clear all
rm(list = ls())


# Read the data and assign to the variables

X_train <- read.table("UCI HAR Dataset/train/X_train.txt", header = FALSE)
Y_train <- read.table("UCI HAR Dataset/train/Y_train.txt", header = FALSE)
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", header = FALSE)

X_test <- read.table("UCI HAR Dataset/test/X_test.txt", header = FALSE)
Y_test <- read.table("UCI HAR Dataset/test/Y_test.txt", header = FALSE)
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", header = FALSE)

features <- read.table("UCI HAR Dataset/features.txt",as.is = TRUE)
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")

# Merge the data
colnames(activity_labels) <- c("activityId", "activityLabel")

test_Data<-cbind(subject_test, X_test, Y_test)
training_Data<-cbind(subject_train, X_train, Y_train)

# 1. Merges the training and the test sets to create one data set.

final_Data <- rbind(test_Data,training_Data)

# Assign the column names 
colnames(final_Data) <- c("subject", features[, 2], "activity")

# Get only the measurements of mean and standard deviation and update the data 
columnsMeanStD <- grepl("subject|activity|mean|std", colnames(final_Data))

# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
final_Data <- final_Data[, columnsMeanStD]

# 3. Uses descriptive activity names to name the activities in the data set
final_Data$activity <- factor(final_Data$activity, levels = activity_labels[, 1], labels = activity_labels[, 2])
final_Data_Cols <- colnames(final_Data)

# 4. Appropriately labels the data set with descriptive variable names.
# make the names approriate 
final_Data_Cols <- gsub("[\\(\\)-]", "", final_Data_Cols)
final_Data_Cols <- gsub("^f", "frequencyDomain", final_Data_Cols)
final_Data_Cols <- gsub("^t", "timeDomain", final_Data_Cols)
final_Data_Cols <- gsub("Acc", "Accelerometer", final_Data_Cols)
final_Data_Cols <- gsub("Gyro", "Gyroscope", final_Data_Cols)
final_Data_Cols <- gsub("Mag", "Magnitude", final_Data_Cols)
final_Data_Cols <- gsub("Freq", "Frequency", final_Data_Cols)
final_Data_Cols <- gsub("mean", "Mean", final_Data_Cols)
final_Data_Cols <- gsub("std", "StandardDeviation", final_Data_Cols)
final_Data_Cols <- gsub("BodyBody", "Body", final_Data_Cols)
# use the new column names 
colnames(final_Data) <- final_Data_Cols

# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
tidy_Data <- final_Data %>% 
  group_by(subject, activity) %>%
  summarise_all(funs(mean))

# crate the file    "tidy_data.txt"
write.table(tidy_Data, "tidy_data.txt", row.names = FALSE,quote = FALSE)

# Create the codebook
library(dataMaid)
makeCodebook(tidy_Data,file="Codebook.Rmd")
