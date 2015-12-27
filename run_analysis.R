require(plyr)

#Download the files to data folder
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")

#Now unzip the files.
unzip(zipfile="./data/Dataset.zip",exdir="./data")


# Set names and path
uci_path <- "DATA/UCI HAR Dataset"
feature_df <- paste(uci_path, "/features.txt", sep = "")
activity_headings_df <- paste(uci_path, "/activity_labels.txt", sep = "")
x_train_df <- paste(uci_path, "/train/X_train.txt", sep = "")
y_train_df <- paste(uci_path, "/train/y_train.txt", sep = "")
subject_train_df <- paste(uci_path, "/train/subject_train.txt", sep = "")
x_test_df  <- paste(uci_path, "/test/X_test.txt", sep = "")
y_test_df <- paste(uci_path, "/test/y_test.txt", sep = "")
subject_test_df <- paste(uci_path, "/test/subject_test.txt", sep = "")

# Now load the unprocessed data

#1features <- read.table(feature_df, header = FALSE)
features <- read.table(feature_df, colClasses = c("character"))
activity_labels <- read.table(activity_labels_df, col.names = c("ActivityId", "Activity"))
x_train <- read.table(x_train_df)
y_train <- read.table(y_train_df)
subject_train <- read.table(subject_train_df)
x_test <- read.table(x_test_df)
y_test <- read.table(y_test_df)
subject_test <- read.table(subject_test_df)

# Now do a mega merge to merge the training and subject test date to create one data set

training_data <- cbind(x_train, subject_train)
training_data <- cbind(training_data, subject_train)

test_data <- cbind( x_test, subject_test)
test_data <- cbind ( test_data, y_test)

merged_data <- rbind(training_data, test_data)

# Label columns
sensor_labels <- rbind(rbind(features, c(562, "Subject")), c(563, "ActivityId"))[,2]
names(merged_data) <- sensor_labels

# Now extract only the values of meand and sd
merged_data_mean_std <- merged_data[,grepl("mean|std|Subject|ActivityId", names(merged_data))]


# Now join the merged data with Activity headings to get the activities
merged_data_mean_std <- join(merged_data_mean_std, activity_headings, by = "ActivityId", match = "first")
merged_data_mean_std <- merged_data_mean_std[,-1]



# Remove parentheses
names(merged_data_mean_std) <- gsub('\\(|\\)',"",names(merged_data_mean_std), perl = TRUE)

# Make clearer names
names(merged_data_mean_std) <- gsub("Acc", "Accelerometer", names(merged_data_mean_std))
names(merged_data_mean_std) <- gsub('GyroJerk',"Gyro Accelearation",names(merged_data_mean_std))
names(merged_data_mean_std) <- gsub("Gyro", "Gyroscope", names(merged_data_mean_std))
names(merged_data_mean_std) <- gsub('Mag',"Magnitude",names(merged_data_mean_std))
names(merged_data_mean_std) <- gsub('^t',"time.",names(merged_data_mean_std))
names(merged_data_mean_std) <- gsub('^f',"frequency.",names(merged_data_mean_std))
names(merged_data_mean_std) <- gsub('\\.mean',".Mean",names(merged_data_mean_std))
names(merged_data_mean_std) <- gsub('\\.std',".SD",names(merged_data_mean_std))
names(merged_data_mean_std) <- gsub('Freq\\.',"Frequency.",names(merged_data_mean_std))


#Final Step. Create Tiday data set

sensor_avg_by_act_sub = ddply(merged_data_mean_std, c("Subject","Activity"), numcolwise(mean))
write.table(sensor_avg_by_act_sub, file = "Tidy_sensor_avg_by_act_sub.txt")