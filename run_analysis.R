library(dplyr)
library(data.table)
file <- "Coursera_DS3_Final.zip"
# access the data

if (!file.exists(file)){
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileURL, file, method="curl")
}  

if (!file.exists("UCI HAR Dataset")) { 
    unzip(file) 
}
list.files("UCI HAR Dataset", recursive=TRUE)

# pre cleaning -- merge
# 1. Merges the training and the test sets to create one data set.
feature_names <- read.table("UCI HAR Dataset/features.txt", header = FALSE)
feature_train <- read.table("UCI HAR Dataset/train/X_train.txt" , header = FALSE)
feature_test <- read.table( "UCI HAR Dataset/test/X_test.txt", header = FALSE)
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", header = FALSE)
activity_trian <-  read.table("UCI HAR Dataset/train/y_train.txt" , header = FALSE)
activity_test <- read.table( "UCI HAR Dataset/test/y_test.txt", header = FALSE)
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", header = FALSE)
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", header = FALSE)

names(feature_train) <- feature_names$V2
names(feature_test) <- feature_names$V2
names(activity_labels)

features <- rbind(feature_train,feature_test)
activity <- rbind(activity_trian, activity_test)
subject <- rbind(subject_train, subject_test)

colnames(activity) <- 'activity'
colnames(subject) <- 'subject'

df <- cbind(features, activity, subject)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 

indexwihtmeanstd <- grep(".*Mean.*|.*Std.*", names(df), ignore.case=TRUE)

df <- df[c(indexwihtmeanstd, 562, 563)]

dim(df)


# 3. Uses descriptive activity names to name the activities in the data set
activity_labels <- activity_labels$V2
for(i in 1:6){
    df$activity[which(df$activity == i)] <- as.character(activity_labels[i])
}
df$activity
df$activity <- as.factor(df$activity)

# 4. Appropriately labels the data set with descriptive variable names
names(df)
names(df)<-gsub("Acc", "Accelerometer", names(df))
names(df)<-gsub("Gyro", "Gyroscope", names(df))
names(df)<-gsub("BodyBody", "Body", names(df))
names(df)<-gsub("Mag", "Magnitude", names(df))
names(df)<-gsub("^t", "Time", names(df))
names(df)<-gsub("^f", "Frequency", names(df))
names(df)<-gsub("tBody", "TimeBody", names(df))
names(df)<-gsub("-mean()", "Mean", names(df), ignore.case = TRUE)
names(df)<-gsub("-std()", "STD", names(df), ignore.case = TRUE)
names(df)<-gsub("-freq()", "Frequency", names(df), ignore.case = TRUE)
names(df)<-gsub("angle", "Angle", names(df))
names(df)<-gsub("gravity", "Gravity", names(df))
names(df)

# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
# method 1
tidymean <- df %>%
    group_by(subject,activity) %>%
    summarise_all(funs(mean))

# method 2
tidymean <- aggregate(. ~activity + subject, df, mean)

write.table(tidymean, "tidymean.txt", row.name=FALSE)
