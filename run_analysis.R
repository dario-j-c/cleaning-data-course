AnalysisScript <- function(datasource = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                           archivename = "getdata_projectfiles_UCI HAR Dataset.zip", foldername = "UCI HAR Dataset", desireddata = 3) {
  
  ## This is the script for tidying the raw data provided.
  ## Overview comments will be found with "##" preceding them.
  ## Granular comments will be found with "#" preceding them and where possible shall be to the side of the code.
  ## Important Note: This script is a function, meaning it must first be sourced then it can be called as any other function.
  ## The output of this script is two csv files, which is 1. the requested data and 2. the names changes made for the data.
  ## Further details can be found both in the README.md file and the codebook.md file. 
  
  ## Load needed packages
  pkg <- c("tidyverse", "fs")                                                   # My list of desired packages
  suppressMessages(                                                             # Suppress messages while allowing warning and error messages
  lapply(pkg, require, character.only = TRUE))                                  # Check and load desired packages
  
  
  ## Download raw data
  oldwd <- getwd()                                                              # Save the current working directory for later usage
  
  zippaths <- dir_ls(recurse = TRUE,                                            # Get paths for files in sub directories which match archive name
                     type = "file",
                     glob = paste0("*",archivename))       
  dirpaths <- dir_ls(recurse = TRUE,                                            # Get paths for directories in sub directories which match folder name
                     type = "directory",
                     glob = paste0("*",foldername))
 
   if (!length(zippaths) && !length(dirpaths)){                                 # If the archive name & folder name isn't found, download archive
    download.file(datasource, archivename, method="curl")
     unzip(archivename)
     setwd(foldername)
  } else if (!length(dirpaths)) {                                               # If the folder name isn't found, unzip archive and change working directory
    unzip(archivename)
    setwd(foldername)                                                           # Go to directory to prepare to work with files
  } else if ( grepl(pattern = paste0(foldername,"$"), oldwd) ){                 # Check if working directory is already the desired location or not
  } else {
    setwd(dirpaths[1])
  }
  
  
  
  ## Assemble raw data
  
  # Load files from folders
  features <- read_table2("features.txt",
                          col_names = c("id_features", "variables"),
                          col_types = c(col_double(), col_character()))
  activities <- read_table2("activity_labels.txt",
                            col_names = c("id_activity","activity"),
                            col_types = c(col_double(), col_character()))
  
  subject_test <- read_csv("test/subject_test.txt",
                           col_names = "id_subject",
                           col_types = c(col_double()))
  
  # x_test and x_train returns a warning message due to certain headers (e.g. "fBodyAcc-bandsEnergy()...")
  # not being properly labelled with their coordinates (x,y,z) in the raw data.
  # readr automatically de-duplicates the headers.
  # This warning, which has been suppressed, does not hinder the code from working as intended
  suppressWarnings(
  x_test <- read_table2("test/X_test.txt",
                        col_names = features$variables,
                        col_types = c(col_double()))
  )
  y_test <- read_table2("test/y_test.txt",
                        col_names = "id_activity",
                        col_types = c(col_double()))
  
  subject_train <- read_csv("train/subject_train.txt",
                            col_names = "id_subject",
                            col_types = c(col_double()))
  suppressWarnings(
  x_train <- read_table2("train/X_train.txt",
                         col_names = features$variables,
                         col_types = c(col_double()))
  )
  y_train <- read_table2("train/y_train.txt",
                         col_names = "id_activity",
                         col_types = c(col_double()))
  
  setwd(oldwd)                                                                  # Return to the starting working directory
  
  ## From Course: 1. Merges the training and the test sets to create one data set.
  
  x <- bind_rows(x_train, x_test)
  y <- bind_rows(y_train, y_test)
  subject <- bind_rows(subject_train, subject_test)
  oldnames <- c(colnames(subject), colnames(y), colnames(x))                    # Stores the old names to be used for comparison
  rawdata <- bind_cols(subject, y, x, .name_repair = "universal")               # .name_repair automatically adjusts header names to tidyverse standards
  names(rawdata) <- str_to_lower(names(rawdata))                                # Makes all headers lower case only
  
  newnames <- colnames(rawdata)                                                 # Stores the new names used for comparison
  rawchangednames <- bind_cols(oldnames, newnames)                              # Creates a table to track how names have been changed
  colnames(rawchangednames) <- c("oldnames", "newnames")
  
  
  
  ## From Course: 2. Extracts only the measurements on the mean and standard deviation for each measurement.
  
  tidydata <- rawdata %>%
    select(contains("id_"), contains("mean"), contains("std"))                  # Extracts and reorders columns of interest, is text-case agnostic
  
  tidychangednames <- filter(rawchangednames,                                   # Extracts but does not reorder rows of interest, is not text-case, which is no issue as all titles are now lowercase 
                             str_detect(newnames, "id_") |
                               str_detect(newnames, "mean") |
                               str_detect(newnames, "std"))
  
  reshufflenames <- as.data.frame(names(tidydata))                              # Reorders rows of interest to align with new order of data due to using the select function
  colnames(reshufflenames) <- c("newnames")
  tidychangednames <- left_join(reshufflenames, tidychangednames, by = "newnames") %>%
    select(oldnames, newnames)
  
  ## From Course: 3. Uses descriptive activity names to name the activities in the data set.
  
  tidydata <- left_join(tidydata, activities, by = "id_activity") %>%           #merges data frames with the activity id now replaced by the actual activity
    select(id_subject, activity, everything(), -id_activity )
  
  tidychangednames[2,2] <- "activity"                                           # Change "id_activity" to "activity"
    
  
  # From Course: 4. Appropriately labels the data set with descriptive variable names.
  
  names(tidydata)<-gsub("^t", "time.", names(tidydata))                         # Places descriptive words where considered applicable
  names(tidydata)<-gsub("^f", "frequency.", names(tidydata))
  names(tidydata)<-gsub("acc", "accelerometer.", names(tidydata))
  names(tidydata)<-gsub("gyro", "gyroscope.", names(tidydata))
  names(tidydata)<-gsub("bodybody", "body", names(tidydata))                    # This particular change is to fix a suspected error in naming from the raw data
  names(tidydata)<-gsub("mag", "magnitude.", names(tidydata))
  

  tidychangednames["newnames"] <- lapply(tidychangednames["newnames"],          # Places the same descriptive words where considered applicable to keep track of name changes
                                         str_replace_all,
                                         pattern = "^t", "time.")
  tidychangednames["newnames"] <- lapply(tidychangednames["newnames"],
                                         str_replace_all,
                                         pattern = "^f", "frequency.")
  tidychangednames["newnames"] <- lapply(tidychangednames["newnames"],
                                         str_replace_all,
                                         pattern = "acc", "accelerometer.")
  tidychangednames["newnames"] <- lapply(tidychangednames["newnames"],
                                         str_replace_all,
                                         pattern = "gyro", "gyroscope.")
  tidychangednames["newnames"] <- lapply(tidychangednames["newnames"],          # This particular change is to fix a suspected error in naming from the raw data
                                         str_replace_all,
                                         pattern = "bodybody", "body")
  tidychangednames["newnames"] <- lapply(tidychangednames["newnames"],
                                         str_replace_all,
                                         pattern = "mag", "magnitude.")
  
  
  
  ## From Course: 5. From the data set in step 4, creates a second, independent
  ## tidy data set with the average of each variable for each activity and each subject.
  
  tidysummarydata <- group_by(tidydata, id_subject, activity) %>%               # Grouped data and summarised by the mean
    summarise( across(everything(), mean))
  
  # Please note, the names have been changed again to show they're summarised by the mean
  names(tidysummarydata)<-gsub("^", "summary.mean...", names(tidysummarydata))
  tidysummarydata <- rename(tidysummarydata, id_subject = summary.mean...id_subject)
  tidysummarydata <- rename(tidysummarydata, activity = summary.mean...activity)
  
  tidysummarychangednames <- tidychangednames
  tidysummarychangednames["newnames"] <- lapply(tidysummarychangednames["newnames"],
                                         str_replace_all,
                                         pattern = "^", "summary.mean...")
  tidysummarychangednames[1,2] <- "id_subject"
  tidysummarychangednames[2,2] <- "activity"
  
  
  
  ## Write desired data to file
  
  # This loop chooses which data and accompanying list of changed names to write the file where:
  # 1 = the raw data and the respective original names
  # 2 = the tidy data and the respective changed names
  # 3 = the summarised tidy data and the respective changed names
  # The default will be 3. and any other input value will not write a file
  if( desireddata == 1) {
    chosendata <- rawdata
    chosennames <- rawchangednames
  } else if(desireddata == 2) {
    chosendata <- tidydata
    chosennames <- tidychangednames
  } else if(desireddata == 3) {
    chosendata <- tidysummarydata
    chosennames <- tidysummarychangednames
  } else {}
  
  if( desireddata == 1 | desireddata == 2 | desireddata == 3  ) {
    write_csv(chosendata, file.path("data.csv"), na = "NA", append = FALSE, col_names = TRUE,
              quote_escape = "double")
    write_csv(chosennames, file.path("changednames.csv"), na = "NA", append = FALSE, col_names = TRUE,
              quote_escape = "double")
  } else {}

}
