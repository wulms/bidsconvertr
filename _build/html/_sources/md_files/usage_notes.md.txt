# Usage notes

## Input data

The input data needs to be in the following structure:

-   an input folder containing all folders with DICOM data

    -   …/subjects/sessions/DICOM
        -   one folder per subject, e.g. “00001”, “00002”
        -   these folders containing the session data, each of them
            containing the DICOM data
    -   …/sessions/subjects/DICOM
        -   cross-sectional (one folder named ‘baseline’ or else)
        -   one folder per session, e.g. “session_1”, “session_2”
        -   these folders containing the DICOM data in separate folders
            per subject, e.g. “00001”, “00002”
    - in case of other logical structures: Please contact me, so that I can include them.

## Starting the tool

``` r
# loading the library, the 'quietly' argument turns off the messages about loading other dependencies.
library(bidsconvertr, quietly = TRUE) 

# function that starts the workflow
convert_to_BIDS()
```

If you run the `convert_to_BIDS()` function, you need a `user_settings.R` file.


```{note} 
The `user_settings.R` file contains your selected options (folders, filename convention, dcm2niix string, regular expressions) and stores theses settings and variables.
You don't have to edit these manually, instead you are guided through the procedure with our user dialog.
```

### Do you have a user settings file?

| Option | What happens?                                                                                                       |
|--------|---------------------------------------------------------------------------------------------------------------------|
| Yes    | You are able to select your already existing file. The user dialog is skipped. Starts the rest of the workflow. |
| No     | Creates your user settings file (described below).                                                                  |


#### Yes: Selection for your ‘user settings’ file.

You select the file in the file selection window. This can be anywhere on
your filesystem. This file stores your settings, so that you can run this file continuously during the acquisition of data.

#### No: 

Starts user dialog to create 'user settings' file.






