# Getting and Cleaning Data
## A repository for week 4's project

This repository is the submission for the 'Getting and Cleaning Data' course project.
Included are the instructions on how to run the analysis on the provided [Human Activity Recognition Using Smartphones Dataset
Version 1.0](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) dataset and what is in the repository.

### Datasets
1. [Human Activity Recognition Using Smartphones](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)
  - This is the original data and will be automatically downloaded by the script. It is not in the repository.

### Files
1. **codedook.md**
  - This is the code book which describes the variables; data; and transformations made in the process of cleaning the dataset as prescribed by the course.
2. **changednames.csv**
  - This is an automatically  generated file to be used alongside the code book which documents the name changes in the column headers from the raw dataset (*old names*) to the chosen dataset (*newnames*).
3. **data.csv**
  - This is an automatically  generated file which contains the summarised tidy dataset by default.
  It can be changed to instead contain the combined raw dataset, or the tidy dataset through a simple input change for the script. Further details on the available files are shown below.
    - The raw dataset is the combined raw data with no changes made to headers.
    - The tidy dataset is all columns which mention "mean" and "std", along with subject and activity are the columns kept.It also changes the headers with the following in mind:
      - All headers are unique
      - All headers are lowercase for ease in typing
      - Errors have been removed (e.g. "bodybody" to "body")
      - All headers are descriptive for ease in understanding
      - All headers are modified automatically by tidyverse standards. See [.name_repair](https://principles.tidyverse.org/names-attribute.html) for further details.
    - The summary tidy dataset is all variables, where applicable, in the tidy set have been crunched into a mean grouped by the subject and activity. The names, where applicable, have also been modified with a prefix to show they're a summary mean.
4. **run_analysis.R**
  - This script is a function which must be first sourced then ran, It may be ran with no inputs as the defaults are already set. It will:
    - Confirm if it needs to download the dataset, if it it can't locate the dataset in a subdirectory, it will download the file. If it can, it will use the already downloaded file.
    - Merge the training and test data to create a single dataset (the raw dataset), then generate an accompanying name list.
    - Tidy this data by doing as described above in 3. when referring to the tidy dataset. It will generate an accompanying name list.
    - Summarise the tidy dataset as described above in 3. when referring to summary tidy dataset. It will generate an accompanying name list.
    - Print the files data.csv and changednames.csv where by default, they will refer to the summary tidy dataset and its accompanying name list.

 