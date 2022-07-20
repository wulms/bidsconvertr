# Usage notes

## Input data

The input data must have the following structure:

-   an input folder containing all folders with DICOM data

    -   …/subjects/sessions/DICOM
        -   one folder per subject, for example: “00001”, “00002”
        -   these folders containing the session data, each of which contains the DICOM data
    -   …/sessions/subjects/DICOM
        -   cross-sectional (at least one folder named ‘crosssectional’ or a custom session name)
        -   one folder per session, for example: “session_1”, “session_2”
        -   these folders, which contain DICOM data in separate folders
            for each subject, e.g. “00001”, “00002”
    - if you have any additional file structures, please contact me, so that I can include them.

## Starting the tool

``` r
# Load the library. 
# The 'quietly' argument turns off the messages about loading other dependencies.
library(bidsconvertr, quietly = TRUE) 

# Start the workflow.
convert_to_BIDS()
```

A 'user settings.R' file is required when using the 'convert to BIDS()' function.

```{note} 
The 'user settings.R' file stores the settings and variables you've chosen (folders, filename convention, dcm2niix string, regular expressions).
You do not need to manually edit these; instead, our user dialogue will walk you through the process.
```

### Do you have a `user settings` file?

| Option | What happens?                                                                                                       |
|--------|---------------------------------------------------------------------------------------------------------------------|
| Yes    | You are able to select your already existing file. The user dialog is skipped. Starts the rest of the workflow. |
| No     | Creates your user settings file (described below).                                                                  |


#### Yes: Selection for your ‘user settings’ file.

In the file selection window, you select the file. This could be located anywhere on your filesystem. 
This file stores your settings so that you can run it continuously while collecting data.

#### No: 

Starts a user dialogue to create a file called `user settings`.





