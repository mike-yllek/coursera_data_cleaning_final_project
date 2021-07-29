#Peer Review Assignment: Cleaning Data Week 4

#Download and unzip data
CD_zip <- download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "CD_zipfile_peerassignment.zip", method = "curl")
unzip("CD_zipfile_peerassignment.zip")

#Read in training data
train_set <- read.table("/Users/mikekelly/Documents/R_files/Coursera_R_Projects/Data_Cleaning/UCI\ HAR\ Dataset/train/X_train.txt")
train_labels <- read.table("/Users/mikekelly/Documents/R_files/Coursera_R_Projects/Data_Cleaning/UCI\ HAR\ Dataset/train/y_train.txt")
train_subject <- read.table("/Users/mikekelly/Documents/R_files/Coursera_R_Projects/Data_Cleaning/UCI\ HAR\ Dataset/train/subject_train.txt")

#Read in test data
test_set <- read.table("/Users/mikekelly/Documents/R_files/Coursera_R_Projects/Data_Cleaning/UCI\ HAR\ Dataset/test/X_test.txt")
test_labels <- read.table("/Users/mikekelly/Documents/R_files/Coursera_R_Projects/Data_Cleaning/UCI\ HAR\ Dataset/test/y_test.txt")
test_subject <- read.table("/Users/mikekelly/Documents/R_files/Coursera_R_Projects/Data_Cleaning/UCI\ HAR\ Dataset/test/subject_test.txt")

#Read in activity data and features
activitylabels <- read.table("/Users/mikekelly/Documents/R_files/Coursera_R_Projects/Data_Cleaning/UCI\ HAR\ Dataset/activity_labels.txt")
features <- read.table("/Users/mikekelly/Documents/R_files/Coursera_R_Projects/Data_Cleaning/UCI\ HAR\ Dataset/features.txt")

#Name columns more intuitively
colnames(train_set) <- features$V2
colnames(test_set) <- features$V2
colnames(test_subject) <- "subjectID"
colnames(train_subject) <- "subjectID"
colnames(test_labels) <- "activity_label"
colnames(train_labels) <- "activity_label"

#Bind together training and test data individually
train_full <- cbind(train_subject, train_labels, train_set)
test_full <- cbind(test_subject, test_labels, test_set)

#Bind test and training data by row
full_data <- rbind(train_full, test_full)

#Extract only meand and standard deviation from the data set
names_mean <- grep(pattern = "mean", names(full_data))
names_std <- grep(pattern = "std", names(full_data))
names_mean_std <- c(names(full_data)[names_mean], names(full_data)[names_std])

full_data_trim <- select(full_data, subjectID, activity_label, all_of(names_mean_std))

#Rename activity labels intuitively and recode
full_data_trim_recode_activity <- recode(full_data_trim$activity_label, "1" = "walking", "2" = "walking_upstairs", "3" = "walking_downstairs", "4" = "sitting", "5" = "standing", "6" = "laying")
full_data_trim_recoded <- mutate(full_data_trim, 
                                 activity = full_data_trim_recode_activity, 
                                 .after = "subjectID",
                                 activity_label = NULL,
                                 .keep = "unused")

#Take recoded data, make it into a data tbl
#Group by SubjectID and Activity, then take the average of all the rest of the values in the data table by those groups
full_data_trim_recoded %>% 
    data.table() %>% 
    group_by(subjectID, activity) %>% summarise_all(.funs = mean) -> summarized_data

#Write summarized table to csv file
write.csv(summarized_data, file = "Coursera_Data_Cleaning_Final_Project.csv")

