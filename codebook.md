# Code Book
## A code book for week 4's project

The run_analysis.R script is a function which must be first sourced then ran
It will do the following:

1. ### Download the dataset
The script will first check if either the needed zip file, or unzipped folder is downloaded and placed in its directory or sub directory. If yes, it will use the already downloaded material, if no, it will download the database and/or unzip the file resulting in the directory "UCI HAR Dataset".
This directory will be made the working directory while it carried out the next steps.


2. ### Assign the distributed raw data to different variables
    - **features** <- features.txt
      features describe the the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ after modification. These features are a `561-feature vector with time and frequency domain variables` and are further described in the features_info.txt file found in the downloaded zip file.
    - **activities** <- activity_labels.txt
      activities list the different activities performed by the subject while measurements were taken with an id number for reference. The activities and reference number were:
      1. walking
      2. walking upstairs
      3. walking downstairs
      4. sitting
      5. standing
      6. laying
    - **subject_test** <- test/subject_test.txt
      subject_test contains the unique id numbers referencing the tested subjects who were observed while performing the activity. It is the data randomly set aside originally for testing during data modelling.
    - **subject_train** <- test/subject_train.txt
      The same as subject_test, except data set aside for training during data modelling.
    - **x_test** <- test/X_test.txt 
      The observations corresponding to the test data.
    Headers are added here from `features`.
    - **x_train** <- test/X_train.txt
      The observations corresponding to the training data
    - **y_test** <- test/y_test.txt
      The respective activity id for each observation in the test data
    - **y_train** <- test/y_train.txt
      The respective activity id for each observation in the training data


3. ### Merge the training and the test sets to create one dataset
    - **x** is made using the `bind_rows` function on `x_train` and `x_test`.
    This is the combined observation data with headers but no data for subject or activities.
    - **y** is made using the `bind_rows` function on `y_train` and `y_test`.
    This is the activities id number for the combined observation data.
    - **subject** is made using the `bind_rows` function on `subject_train` and `subject_test`.
    This is the subject id number for the combined observation data.
    - **rawdata** is made using the `bind_cols` function on `subject`, `y`, and `x` in that order.
    This is now the assembled raw dataset
    - *Other Note: All column names were set to lowercase for ease of reading and useablilty within the code.*
    - *Other Note: All column names were automatically edited using* [.name_repair](https://principles.tidyverse.org/names-attribute.html) *to gain readability as well as usability within the code.*
    - *Other Note: at this point in time `rawchangednames` is made to track the column names i.e. its headers of the assembled raw dataset and the changes made.*

4. ### Extract only the measurements on the mean and standard deviation for each measurement.
    - **tidydata** is made using the `select` function, selecting only columns: which have character string "mean" or "std" within them. It also includes the subject and activity ids as well.
    - *Other Note: at this point in time `tidychangednames` is made to track the column names i.e. its headers of the assembled tidy dataset.*

5. ### Use descriptive activity names to name the activities in the data set
    - **id_activity**, the name for our column with activity ids, is switched to `activity` and the corresponding id numbers are switched to the activity name by using the `join` function on the `activities` dataset in conjunction with the `tidydataset`.
    - *Other Note: at this point in time `tidychangednames` is updated and changes `id_activity` to `activities`.*

6. ### Appropriately label the data set with descriptive variable names.
    - **All applicable column names** are updated using the following:
      - Names beginning with "**t**" were changed to begin with "**time.**"
      - Names beginning with "**f**" were changed to begin with "**frequency.**"
      - The string "**acc**" were changed to "**accelerometer.**"
      - The string "**gyro**" were changed to "gyroscope."
      - The string "**bodybody**" were changed to "**body**" as this seemed to be an error.
      - The string "**mag**" were changed to "**magnitude.**"
      - *Other Note: at this point in time `tidychangednames` is updated and changes with the same conventions.*
      - *Other Note: The periods "**.**" included in the new names is a deliberate choice to enhance readability between words while still (hopefully) holding to the conventions used in the automated name repairer.*
      - ***Other Note:*** *Please refer to changednames.csv to see the exact name choice for any variable*

7. ### From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
      - `tidysummarydata` is made using the `group_by` function to first group the data by activity and subject, then this piped to `summarise` to calculate the mean over each of these groups.
      - *Other Note: I choose here to add the prefix **summary.mean...** at the beginning of each header except for **subject** and **activity**. This prefix is to indicate the values following are a summary by mean over the subject and activity.*
      - *Other Note: at this point in time `tidysummarychangednames` is made and updated with the same naming conventions as `tidysummarydata`.*

8. ### Export the chosen data file.
      - A for loop is used to choose which date file to upload as **data.csv** with its accompanying name list, **changednames.csv**. The choices are:
        1. the raw data and the respective original names
        2. the tidy data and the respective changed names
        3. the summarised tidy data and the respective changed names
      The default (i.e. no input) will select 3. Please note, choices are made with the respective number listed directly above.
      