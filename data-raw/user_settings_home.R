# Path that contains one folder per session, containing all DICOMS in subject folders
path_input_dicom <- "C:/Science/bidirect/dicom/"

# output folder
path_output <- "C:/Science/bidirect_bids/"


study_name <- "BiDirect Study"

# regular expressions
regex_subject_id <- "[:digit:]{5}"
regex_group_id <- "[:digit:]{1}(?=[:digit:]{4})"
regex_remove_pattern <- "[:punct:]{1}|[:blank:]{1}|((b|d)i(d|b)i|bid|bd|bdi)(ect|rect)($|(rs|T2TSE|inclDIRSequenz|neu|abbruch))"

# session ids
sessions_id_old <- c("Baseline", "FollowUp", "FollowUp2", "FollowUp3")
sessions_id_new <- c("0", "2", "4", "6")

# mri sequence ids
mri_sequences <- c("T1|T2|DTI|fmr|rest|rs|func|FLAIR|smartbrain|survey|smart|ffe|tse")
