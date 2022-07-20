# Advanced features

```{Note} 
This part is optional. 
It is relevant for you, if you have untidy subject-ID's (e.g. with some redundant prefix, suffix or string) or you want to rename your session-ID's.
```
This part is about the optional cleaning or extraction of subject-ID’s and renaming
of sessions.

You are asked during the setup procedure, if your subject- and session-ID’s are fine, or if you
want to edit them. If your data was already acquired with clear subject-
and session-ID’s you can skip this procedure by selecting:

| **Option to select**          | **What happens?**                                                                                       |
|-------------------------------|-------------------------------------------------------------------------------------------------------------|
| No, my subject-ID's are fine. | The paths are created, subject- and session-ID's get a "sub-" and "ses-" prefix, if it isn't already there. |
| Yes                           | Set a subject-ID regular expression or set a string, prefix, suffix or regular expression, which is then removed from each subject-ID.  |


## Resources for regular expressions

For more information on regular expressions (regex) please see the
[stringR cheat
sheet](https://github.com/rstudio/cheatsheets/blob/main/strings.pdf)
or [RegexOne](https://regexone.com/). 

<embed src="https://evoldyn.gitlab.io/evomics-2018/ref-sheets/R_strings.pdf" type="application/pdf" width="100%" height="400">

Each regex set here should match to
your data. If you encounter any problems just contact me via mail or via
the issues in this repository.


These both functions should give you enough flexibility to clean up your
filenames and modify your regular expression step by step.


## Useful regular expressions

The subject-ID is from the folder name. If no regular expression is used, the subject-ID remains unchanged.

### Regular expression: subject-ID 

These regular expression extracts the subject-ID from the input string. This can be used, if you had a clear defined naming convention for all your files.


| subject-ID                   | regular expression             | described in words                            | output subject-ID |
|------------------------------|--------------------------------|-----------------------------------------------|-------------------|
| 01234                        | [:digit:]{5}                   | 5 digits                                      | sub-01234         |
| Control2132                  | (Control\|Patient)[:digit:]{4} | "Control" OR "Patient" followed by 4 digits   | sub-Control2132   |
| Patient0123_test             | (Control\|Patient)[:digit:]{4} |                                               | sub-Patient0213   |
| abcd0123                     | [:alpha:]{4}[:digit:]{4}       | 4 letters and 4 digits                        | sub-abcd0123      |
| pilot_sdfjd3222              | [:alpha:]{4}[:digit:]{4}       |                                               | sub-sdfjd3222     |
| adc932d                      | [:alnum:]{5,7}                 | between 5 to 7 alphanumeric (letters, digits) | sub-adc932d       |
| 23d49                        | [:alnum:]{5,7}                 |                                               | sub-23d49         |

Examples of subject-ID regular expressions

### Regular expression: pattern to remove

| subject-ID                   | regular expression              | described in words                                   | output subject-ID |
|------------------------------|---------------------------------|------------------------------------------------------|-------------------|
| 02313_bidirect               | \_(bidirect\|BiDirect\|Bidiect) | "\_" followed by "bidirect", "BiDirect" or "BiDiect" | sub-02313         |
| 03211_BiDirect               | \_(bidirect\|BiDirect\|Bidiect) |                                                      | sub-03211         |
| 02111_Bidiect                | \_(bidirect\|BiDirect\|Bidiect) |                                                      | sub-02111         |
| test0111                     | test\|study_a\_                 | "test" or "study_a\_"                                | sub-0111          |
| study_a\_1111                | test\|study_a\_                 |                                                      | sub-1111          |
| pre9222post                  | pre\|post\|suffix\|prefix       | as in the cell above                                 | sub-9222          |
| suffix223prefix              | pre\|post\|suffix\|prefix       |                                                      | sub-223           |

Examples of ‘patterns to remove’ regular expressions





## Do you want to edit your session-ID’s?

You are now able to edit your session-ID’s. You decide, if you want to
keep or rename them.

| Option to select              | What happens?                                                           |
|-------------------------------|-------------------------------------------------------------------------|
| Yes, I need to change them    | Each session is opened separately and you can enter the new session-ID. |
| No, my session-ID’s are fine. | Nothing is edited, you keep your session-IDs                            |

Yes:

| session-ID (old) | session-ID (user input) | session-BIDS |
|------------------|-------------------------|--------------|
| baseline         | 1                       | ses-1        |
| follow_up        | 2                       | ses-2        |

“Yes, I need to change them” can result in output like this. The user
could also choose to use “followup” or something else.

No:

| session-ID (old) | session-BIDS  |
|------------------|---------------|
| baseline         | ses-baseline  |
| follow_up        | ses-follow_up |

“No, my session-ID’s are fine”
