#' Finds dicom folders in dicom/session/subject folder structure
#'
#'
#' @return dataframe containing list, session and subject id
#' @export
#'
#' @examples \dontrun{list_dicom_folders("dicom")}
list_dicom_folders <- function() {

  print(sessions_id_old)
  print(sessions_id_new)

  string_sessions <<- sessions_id_old %>%
    paste0(collapse = "|")

  string_sessions <<- paste0("(", string_sessions, ")") %>%
    regex(., ignore_case = TRUE)



  if(!dir.exists(path_input_dicom)){
    stop("ERROR: The 'path_input_dicom' does not exist. Please set up a valid existing folder.")
  }

  if(str_detect(folder_order,
                "^(session_subject|subject_session)$",
                negate = TRUE)){
    stop("ERROR: The 'folder_order' needs to be specified as 'session_subject' or 'subject_session'")
  }



  df <- check_folder_order()

  df <- check_filenames(df)



  # ============================= TESTS ==============================================
  cat("\n\n Running diagnostics on the data. \n\n")

  print(head(df))

  cat("\n\n")

  if(df %>% dplyr::count(rest_string, rest_string2) %>% nrow() > 0){
    print("The following strings are unmatched strings. These are automatically removed from the file")
    print(df %>% dplyr::count(rest_string, rest_string2))
    cat("\n\n")
    Sys.sleep(2)
  }

  if(df %>% dplyr::count(your_session_id, new_session_id) %>% nrow() > 0){
    print("This is the amount of data per session:")
    print(df %>% dplyr::count(your_session_id, new_session_id))
    cat("\n\n")
    Sys.sleep(2)
  }

  # print("This is the amount of data per session and group:")
  # print(df %>% select(your_group_id, your_session_id, new_session_id) %>% count())
  # cat("\n\n")
  # Sys.sleep(2)

  unmatched_subjects <- df %>%
    filter(is.na(your_subject_id))

  if(unmatched_subjects %>% nrow() > 0){
    print(paste("Unmatched subject-IDs identified: ", nrow(unmatched_subjects)))
    print(unmatched_subjects)
    cat("\n\n")
    Sys.sleep(2)
    stop("Please start a new user file or edit the old one manually, until all subject-IDs are matched!")
  }


   unmatched_sessions <- df %>%
    filter(is.na(your_session_id))

  if(unmatched_sessions %>% nrow() > 0){
    print(paste("Unmatched session-IDs identified: ", nrow(unmatched_sessions)))
    print(unmatched_sessions)
    cat("\n\n")
    Sys.sleep(2)
    stop("Please start a new user file or edit the old one manually, until all session-IDs are matched!")

  }


  # Preview
  print("Preview of extracted data: ")
  print(head(df))
  Sys.sleep(2)
  # cat("\014")

  path_to_folder(paste0(path_output_converter, "/dicom_paths.tsv"))
  write_tsv(df, file = paste0(path_output_converter, "/dicom_paths.tsv"))

  return(df)
}



check_folder_order <- function() {
  df <- dir(path_input_dicom, full.names = TRUE) %>%
    lapply(FUN = dir,
           recursive = FALSE,
           full.names = TRUE) %>%
    unlist() %>%
    data.frame(dicom_folder = ., stringsAsFactors = FALSE)  %>%
    # extract relevant information
    dplyr::mutate(
      folder_short = str_remove(dicom_folder, path_input_dicom) %>%
        str_replace("////", "//") %>%
        str_remove("^/"))

  if(nrow(df) == 0){
    stop("ERROR: No folders found in your specified 'path_input_dicom'")
  }

  cat("These are your input folders.
      'folder_short' should represent the folders, that contain the DICOM files per session & subject.")
  cat("\n\n")
  print(paste("You selected the input folder hierarchy: ", folder_order))
  cat("\n\n")
  print(head(df))
  Sys.sleep(2)
  # cat("\014")
  cat("\n\n")

  if(folder_order == "session_subject"){
    df <- df %>%
      separate(folder_short, into = c("session", "subject"), sep = "/")
    cat("You selected 'session_subject' as the hierarchical order of folders in the DICOM input.
        Change it to 'subject_session' if 'subject' and 'session' are in the wrong order here.")
    cat("\n\n")
  } else if (folder_order == "subject_session") {
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
  Sys.sleep(2)


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
  cat("\n\n Preparing filenames \n\n")
  df_out <- df %>%
    # remove "ses- or sub-" from the input string
    dplyr::mutate(session = str_remove(session, "^ses-"),
           subject = str_remove(subject, "^sub-")) %>%
    # apply regular expressions
    dplyr::mutate(your_session_id = str_extract(session,
                                         string_sessions),
           your_subject_id = str_extract(subject,
                                         regex_subject_id)) %>%
    # if one is NA, switch with extracted info before regex
    dplyr::mutate(your_session_id = ifelse(is.na(your_session_id),
                                    yes = session,
                                    no = your_session_id),
           your_subject_id = ifelse(is.na(your_subject_id),
                                    yes = subject,
                                    no = your_subject_id)) %>%
    # create rest string
    dplyr::mutate(
      rest_string = str_remove(subject, your_subject_id) %>%
        str_remove("//"),
      rest_string2 = str_remove_all(rest_string,
                                    regex(regex_remove_pattern, ignore_case = TRUE))
    ) %>%
    # output path
    dplyr::mutate(
      # switch session-IDS
      new_session_id = reduce2(paste0(sessions_id_old, "$"),
                               sessions_id_new,
                               .init = your_session_id,
                               str_replace),
      output_path_nii = paste0(path_output_converter_temp_nii,
                               "/sub-", your_subject_id,
                               "/ses-", new_session_id),
      output_path_json = paste0(path_output_converter_temp_json,
                                "/sub-", your_subject_id,
                                "/ses-", new_session_id)
    ) %>%
    relocate(dicom_folder, your_subject_id,
             your_session_id, new_session_id)

  cat("\n\n")
  print(df_out)
  cat("\n\n")

  return(df_out)
}
