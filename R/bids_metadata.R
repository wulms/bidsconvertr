#' This function creates the required BIDS files 'participants.tsv' and 'participants.json'. The '.tsv' contains the actual data per subject from the 'json_metadata.tsv'. The '.json' contains a description of the extracted variables. The following variables are extracted: subject, session, group, PatientBirthDate, AcquisitionDateTime, Patientsex, PatientWeight.
#'
#' @param tsv_path the path to the 'json_metadata.tsv'
#'
#' @return
#' @export
#'
#' @examples
add_participants_tsv <- function(tsv_path = paste0(path_output_converter, "/json_metadata.tsv")){
  # Select columns from json dataframe, mutate relevant columns

  tsv_path = paste0(path_output_converter, "/json_metadata.tsv")

  df <- tsv_path %>%
    readr::read_tsv(show_col_types = FALSE, lazy = FALSE)

  print("Checking if 'json_metadata.tsv' contains the following columns.")
  cat("\n")
  print("subject, session, group")
  print("PatientBirthDate, AcquisitionDateTime, PatientSex, PatientWeight")
  cat("\n")
  column_names <- names(df)

  needed_columns <- c("subject",
                      "session",
                      "group",
                      "PatientBirthDate",
                      "AcquisitionDateTime",
                      "PatientSex",
                      "PatientWeight")
  if(needed_columns[!needed_columns %in% column_names] %>% length() == 0){
    print("Every needed column was found.")
    cat("\n")

    patient_tsv <- df %>%
      select(subject, session, group,
             PatientBirthDate, AcquisitionDateTime, PatientSex, PatientWeight) %>%
      rename(participant_id = subject,
             group_id = group,
             birthdate = PatientBirthDate,
             acquisitiondate = AcquisitionDateTime,
             sex = PatientSex,
             weight = PatientWeight) %>%
      mutate(acquisitiondate = as.Date(acquisitiondate),
             age = time_length(difftime(acquisitiondate, birthdate), "years") %>%
               round(digits = 2)) %>%
      unique()
    # Write participants.tvs file
    write_tsv(patient_tsv,
              paste0(path_output_bids, "/participants.tsv"))
    writeLines(participants,
               paste0(path_output_bids, "/participants.json"))
    print("Created 'participants.tsv' and 'participants.json' in the BIDS folder.")
  } else {
    print("Some columns are missing. This could result from different scanner or json header names.")
    print("Check if the following columns exist:")
    cat("\n")
    print(needed_columns[!needed_columns %in% column_names])
  }
}


#' This function writes a string to a path in UTF-8.
#'
#' @param txt_input String input.
#' @param file_path Output file path.
#'
#' @return
#' @export
#'
#' @examples
write_metadata_bids <- function(txt_input, file_path){
  if (file.exists(file_path) == 0) {
    # writeLines(txt_input, file_path, useBytes=T)
    stri_write_lines(str = txt_input, con = file_path)
  }
}

#' Extracts the sequence id and RepetitionTime of functional sequences for the required BIDS files.
#'
#' @param tsv_path the path to the 'json_metadata.tsv'
#' @param tsv_map the path to the 'sequence_map.tsv'
#'
#' @return
#' @export
#'
#' @examples
create_taskname_metadata <- function(tsv_path = paste0(path_output_converter, "/json_metadata.tsv"),
                                     tsv_map = paste0(path_output_converter, "/sequence_map.tsv")){
  taskname_df <- tsv_path %>%
    readr::read_tsv(show_col_types = FALSE, lazy = FALSE) %>%
    select(sequence, RepetitionTime) %>% unique()

  if("RepetitionTime" %in% names(taskname_df)){
    print(paste("Column 'RepetitionTime found. Everything is fine."))

    task_df <- tsv_map %>%
      readr::read_tsv(show_col_types = FALSE, lazy = FALSE) %>%
      select(-total, -possible_sequence, -relevant) %>%
      filter(BIDS_type == "func") %>%
      left_join(taskname_df) %>%
      unique() %>%
      mutate(string = paste0('{\n\t"TaskName": "',
                             BIDS_sequence,
                             '",\n\t"RepetitionTime": ',
                             RepetitionTime, '\n}'),
             filename = paste0(path_output_bids, "/", BIDS_sequence, ".json"))

    for (i in 1:nrow(task_df))
      write_metadata_bids(task_df$string[i],
                          task_df$filename[i])

  } else {
    print(paste("Column 'RepetitionTime' could not be found in 'json_metadata.tsv'. Please rename the column with the TR manually to 'RepetitionTime' and start again."))
  }


}

#' This function adds all required BIDS metadata: 'CHANGES', 'README', 'dataset_description.json', 'participants.json', 'participants.tsv' and per functional sequence a file that contains the RepetitionTime.
#'
#' @return
#' @export
#'
#' @examples
add_BIDS_metadata <- function(){

  add_participants_tsv()
  # add CHANGES, README, dataset_description

  write_metadata_bids(CHANGES, paste0(path_output_bids, "/CHANGES"))
  write_metadata_bids(README, paste0(path_output_bids, "/README"))
  write_metadata_bids(dataset_description, paste0(path_output_bids, "/dataset_description.json"))



  create_taskname_metadata()

  print("The files were added to your /sourcedata folder. You can edit CHANGES and README manually in the folder with a text editor. Please go to http://bids-standard.github.io/bids-validator/ and check, that your dataset is valid. If the NIfTI Headers produce error messages in the validator select 'ignore NIfTI Headers'.")

}
