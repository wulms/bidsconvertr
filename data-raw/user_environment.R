# Path that contains one folder per session, containing all DICOMS in subject folders
path_input_dicom <- "/media/niklas/BIDS_data/BiDirect_DICOM_Archive/dicoms_protocol_base/dicom/"


# output folder
path_output <- "/media/niklas/BIDS_data/protocol_base"


# template_study <- tibble(
#   "study_name" = "BiDirect Study",
#   "subject_id_regex" = "[:digit:]{5}",
#   "group_id_regex" = "[:digit:]{1}(?=[:digit:]{4})",
#   "remove_pattern_regex" = "[:punct:]{1}|[:blank:]{1}|((b|d)i(d|b)i|bid|bd|bdi)(ect|rect)($|(rs|T2TSE|inclDIRSequenz|neu|abbruch))"
# )
# 
# template_sessions <- tibble(
#   session_id = c("Baseline", "FollowUp", "FollowUp2", "FollowUp3"),
#   session_id_BIDS = c("0", "2", "4", "6"))

study_name <- "BiDirect Study"

regex_subject_id <- "[:digit:]{5}"
regex_group_id <- "[:digit:]{1}(?=[:digit:]{4})"
regex_remove_pattern <- "[:punct:]{1}|[:blank:]{1}|((b|d)i(d|b)i|bid|bd|bdi)(ect|rect)($|(rs|T2TSE|inclDIRSequenz|neu|abbruch))"

sessions_id_old <- c("Baseline", "FollowUp", "FollowUp2", "FollowUp3")
sessions_id_new <- c("0", "2", "4", "6")


mri_sequences <- c("T1|T2|DTI|fmr|rest|rs|func|FLAIR|smartbrain|survey|smart|ffe|tse")
