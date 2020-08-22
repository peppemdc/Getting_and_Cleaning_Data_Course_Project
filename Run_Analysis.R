library(dplyr)
library(data.table)
#0 Downloading Data and creating variables
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="auto")

#Unzip and list files
unzip(zipfile="./data/Dataset.zip",exdir="./data")
path_rf <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(path_rf, recursive=TRUE)
files
#Creating variables for the analysis

#Activity
dataActivityTest  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE)

#Subject
dataSubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)

#Features
dataFeaturesTest  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)

#1 Merge training and test sets
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)
#Naming variables
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2
#Create the data frame
Data <- cbind(dataSubject,dataActivity,dataFeatures)
Data<-data.table(Data)
Data<-Data[order(activity)]

#2 Extracts only the measurements on the mean and standard deviation for each measurement.
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
selectedNames<-c( "subject", "activity",as.character(subdataFeaturesNames))
Data<-subset(Data,select=selectedNames)
str(Data)

#3 Uses descriptive activity names to name the activities in the data set
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)
Data$activity<- factor(Data$activity, labels =activityLabels$V2 )
head(Data,20)

#4 Appropriately labels the data set with descriptive variable names
names(Data)<-gsub("^t", "time_domain_", names(Data))
names(Data)<-gsub("^f", "frequency_domain_", names(Data))
names(Data)<-gsub("Acc", "Acceleration", names(Data))
names(Data)<-gsub("Gyro", "Angular_speed", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

#5 Creates a second,independent tidy data set and ouput it
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(subject,activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)
names(Data2)
