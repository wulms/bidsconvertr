# Creation of 'user settings' file.

```{Note} 
You entered `convert_to_BIDS()` and selected in the popup window, that you want to create the `user_settings.R` file.
You have to know where your data is and should be saved to (select the according folders) and set some options based on your input data (session/subject or subject/session) folder order. 
The questions from each popup window are described below in their order.

You need RStudio for popup support (user-friendly solution). Otherwise the questions will be asked inside the terminal (for the advanced user).
```


## Please select the root directory of all DICOM images (your input folder, as described above.)

You select the root folder, that contains all session/subject or
subject/session folders. If you only have one session, store your data
in a e.g. ‘session-0’ folder.

The terminal shows a list of folders. These should contain the DICOM
data.

## Do these folders contain the DICOM images?

| Option to select | What happens?                           |
|------------------|-----------------------------------------|
| Yes              | next step                               |
| No               | You are able to select the folder again |


## Is your DICOM data structured as ‘session/subject’ or ‘subject/session’.

The tool extracts extracts the subject- and session-ID’s based on this
order. The terminal shows the folders.

Please note: Any subject- or session-ID’s are possible! Also without
“sub-” or “ses-”.

| Folder order of your files | Selection       |
|----------------------------|-----------------|
| sub-0001/ses-01            | subject/session |
| ses-01/sub-0001            | session/subject |


Select the option according to your data, which is shown in the terminal.

## Were subject-ID’s and session-ID’s extracted correctly?

The terminal shows a table with a “subject” and a “session” column. Are these looking valid?

| Option to select | What happens?                  |
|------------------|--------------------------------|
| Yes              | Next step is started.          |
| No               | Change the folder order again. |

## Selection of output directory.

You are able to select any folder on your disk. So you are able to store
raw data at another location than converted data.
