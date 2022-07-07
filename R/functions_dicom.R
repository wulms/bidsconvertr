#' Finds dicom folders in dicom/session/subject folder structure
#'
#' @param input_folder a folder, containing /session/subject/dicomdata structure
#' @param output_folder the output folder, where the data will be stored in future
#' @param sessions_old a list, containing the old sessions (e.g. c("baseline", "follow-up 1"))
#' @param sessions_new a list, containing the BIDS session IDs in the order of the old sessions (e.g. c("0", "1"))
#' @param regex_subject a regular expression of the subject-ID - see stringr cheat sheet with regular expressions (e.g. "[:digit:]{5}" to indicate, that 5 digits are the subject ID)
#' @param regex_group a regular expression of the group-ID - see stringr cheat sheet with regular expressions (e.g. "[:digit:]{1}(?=[:digit:]{4})" to indicate, that the first number in a five number text indicates the session id.)
#' @param regex_remove a regular expression (or multiple, concatenated with the "|" symbol), which are removed from the filename.
#'
#' @return dataframe containing list, session and subject id
#' @export
#'
#' @examples \dontrun{list_dicom_folders("dicom")}
list_dicom_folders <- function(input_folder = path_input_dicom,
                               input_order = folder_order,
                               output_folder = path_output,
                               sessions_old = sessions_id_old,
                               sessions_new = sessions_id_new,
                               regex_subject = regex_subject_id,
                               regex_group = regex_group_id,
                               regex_remove = regex_remove_pattern) {

  string_sessions <- sessions_old %>%
    paste0(collapse = "|")

  string_sessions <- paste0("(", string_sessions, ")") %>%
    regex(., ignore_case = TRUE)



  if(!dir.exists(input_folder)){
    stop("ERROR: The 'path_input_dicom' does not exist. Please set up a valid existing folder.")
  }

  if(str_detect(input_order,
                "^(session_subject|subject_session)$",
                negate = TRUE)){
    stop("ERROR: The 'folder_order' needs to be specified as 'session_subject' or 'subject_session'")
  }



  df <- check_folder_order(input_folder, input_order)

  df <- check_filenames(df)

  # TESTS
  print("The following strings are unmatched strings. These are automatically removed from the file")
  print(df %>% select(rest_string, rest_string2) %>% count())
  cat("\n")
  Sys.sleep(2)

  print("This is the amount of data per session:")
  print(df %>% select(your_session_id, new_session_id) %>% count())
  cat("\n")
  Sys.sleep(2)

  print("This is the amount of data per session and group:")
  print(df %>% select(your_group_id, your_session_id, new_session_id) %>% count())
  cat("\n")
  Sys.sleep(2)

  df %>%
    filter(is.na(your_subject_id)) -> unmatched_subjects
  print(paste("Unmatched subject-IDs: ", nrow(unmatched_subjects)))
  print(unmatched_subjects)
  cat("\n")
  Sys.sleep(2)

  df %>%
    filter(is.na(your_session_id)) -> unmatched_sessions
  print(paste("Unmatched session-IDs: ", nrow(unmatched_sessions)))
  print(unmatched_sessions)
  cat("\n")
  cat("\n")
  Sys.sleep(2)

  # Preview
  print("Preview of extracted data: ")
  print(head(df))
  Sys.sleep(5)
  # cat("\014")

  path_to_folder(paste0(path_output_converter, "/dicom_paths.tsv"))
  write_tsv(df, file = paste0(path_output_converter, "/dicom_paths.tsv"))

  return(df)
}



check_folder_order <- function(input_folder = input_folder,
                               input_order = input_order) {
  df <- dir(input_folder, full.names = TRUE) %>%
    lapply(FUN = dir,
           recursive = FALSE,
           full.names = TRUE) %>%
    unlist() %>%
    data.frame(dicom_folder = ., stringsAsFactors = FALSE)  %>%
    # extract relevant information
    mutate(
      folder_short = str_remove(dicom_folder, input_folder) %>%
        str_replace("////", "//") %>%
        str_remove("^/"))

  if(nrow(df) == 0){
    stop("ERROR: No folders found in your specified 'path_input_dicom'")
  }

  cat("These are your input folders.
      'folder_short' should represent the folders, that contain the DICOM files per session & subject.")
  cat("\n\n")
  print(paste("You selected the input folder hierarchy: ", input_order))
  cat("\n\n")
  print(head(df))
  Sys.sleep(5)
  # cat("\014")
  cat("\n\n")

  if(input_order == "session_subject"){
    df <- df %>%
      separate(folder_short, into = c("session", "subject"), sep = "/")
    cat("You selected 'session_subject' as the hierarchical order of folders in the DICOM input.
        Change it to 'subject_session' if 'subject' and 'session' are in the wrong order here.")
    cat("\n\n")
  } else if (input_order == "subject_session") {
    df <- df %>%
      separate(folder_short, into = c("subject", "session"), sep = "/")

    cat("You selected 'subject_session' as the hierarchical order of folders in the DICOM input.
        Change it to 'session_subject' if 'subject' and 'session' are in the wrong order here.")
    cat("\n\n")
  } else {
    cat("\n\n")
    stop("ERROR: Please choose your 'input_order'.
         'dicom/sub-XXX/ses-XXX/' is 'subject_session'.
         'dicom/ses-XXX/sub-XXX' is 'session_subject'.")
  }
  print(head(df))
  cat("\n\n")
  Sys.sleep(5)


  # check for NAs
  df_na <- df %>%
    filter(if_all(everything(),~ is.na(.)))
  # cat("\014")
  if(nrow(df) == 0){
    stop("No folders found")
  } else if (nrow(df_na) > 0){
    print(df_na)
    stop("NAs found. Please check your data or open an issue on the Github repo.")
  }

  return(df)


}


check_filenames <- function(df = df){
  df <- df %>%
    # remove "ses- or sub-" from the input string
    mutate(session = str_remove(session, "^ses-"),
           subject = str_remove(subject, "^sub-")) %>%
    # apply regular expressions
    mutate(your_session_id = str_extract(session,
                                         string_sessions),
           your_subject_id = str_extract(subject,
                                         regex_subject),
           your_group_id = str_extract(subject,
                                       regex_group)) %>%
    # if one is NA, switch with extracted info before regex
    mutate(your_session_id = ifelse(is.na(your_session_id),
                                    yes = session,
                                    no = your_session_id),
           your_subject_id = ifelse(is.na(your_subject_id),
                                    yes = subject,
                                    no = your_subject_id),
           your_group_id = ifelse(is.na(your_group_id),
                                  yes = "1",
                                  no = your_group_id)) %>%
    # create rest string
    mutate(
      rest_string = str_remove(subject, your_subject_id) %>%
        str_remove("//"),
      rest_string2 = str_remove_all(rest_string,
                                    regex(regex_remove, ignore_case = TRUE))
    ) %>%
    # output path
    mutate(
      # switch session-IDS
      new_session_id = reduce2(paste0(sessions_old, "$"),
                               sessions_new,
                               .init = your_session_id,
                               str_replace),
      output_path_nii = paste0(path_output_converter_temp_nii,
                               "/sub-", your_subject_id,
                               "/ses-", new_session_id),
      output_path_json = str_replace(output_path_nii, "/nii/", "/json_sensitive/")
    ) %>%
    relocate(dicom_folder, your_subject_id, your_group_id,
             your_session_id, new_session_id)

  return(df)
}
