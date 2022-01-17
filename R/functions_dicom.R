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
#' @examples \dontrun{list_dicom_folders("dicom")}
list_dicom_folders <- function(input_folder = path_input_dicom,
                               output_folder = path_output,
                               sessions_old = sessions_id_old,
                               sessions_new = sessions_id_new,
                               regex_subject = regex_subject_id,
                               regex_group = regex_group_id,
                               regex_remove = regex_remove_pattern) {

  string_sessions <- sessions_old %>%
    paste0(collapse = "|")

  string_sessions <- paste0("(", string_sessions, ")(?=/)") %>% regex()


  df <- dir(input_folder, full.names = TRUE) %>%
    lapply(FUN = dir,
           recursive = FALSE,
           full.names = TRUE) %>%
    unlist() %>%
    data.frame(dicom_folder = ., stringsAsFactors = FALSE)  %>%
    # extract relevant information
    mutate(
      folder_short = str_remove(dicom_folder, input_folder),
      your_session_id = str_extract(dicom_folder,
                                    string_sessions
      ),
      your_subject_id = str_extract(dicom_folder,
                                    regex_subject),
      your_group_id = str_extract(dicom_folder,
                                  regex_group)) %>%
    # create rest string
    mutate(
      rest_string = str_remove(folder_short, your_session_id) %>%
        str_remove(your_subject_id) %>%
        str_remove("//"),
      rest_string2 = str_remove_all(rest_string, regex(regex_remove, ignore_case = TRUE))
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
    relocate(dicom_folder, your_subject_id, your_group_id, your_session_id, new_session_id)

  # TESTS
  print("The following strings are unmatched strings. These are automatically removed from the file")
  print(df %>% count(rest_string, rest_string2))
  cat("\n")

  print("This is the amount of data per session:")
  print(df %>% count(your_session_id, new_session_id))
  cat("\n")

  print("This is the amount of data per session and group:")
  print(df %>% count(your_group_id, your_session_id, new_session_id))
  cat("\n")

  df %>%
    filter(is.na(your_subject_id)) -> unmatched_subjects
  print(paste("Unmatched subject-IDs: ", nrow(unmatched_subjects)))
  print(unmatched_subjects)
  cat("\n")

  df %>%
    filter(is.na(your_session_id)) -> unmatched_sessions
  print(paste("Unmatched session-IDs: ", nrow(unmatched_sessions)))
  print(unmatched_sessions)
  cat("\n")
  cat("\n")

  # Preview
  print("Preview of extracted data: ")
  print(head(df))

  path_to_folder(paste0(path_output_converter, "/dicom_paths.tsv"))
  write_tsv(df, file = paste0(path_output_converter, "/dicom_paths.tsv"))

  return(df)
}


#' Creates the dcm2niix system commands for the conversion
#'
#' @param input Folder path(s) containing dicoms
#' @param output Folder path(s) where the nii images should be exported to
#' @param scanner_type MRI scanner vendor type
#' @param dcm2niix_path Path to dcm2niix tool on your system
#'
#' @return List of dcm2niix system commands
#'
#' @examples
#' \dontrun{dcm2nii_wrapper("root_folder/session_id/participant_id/", "nii/session-id/participant-id/")}
dcm2nii_wrapper <-   function(input_folder,
                              output_folder,
                              scanner_type,
                              dcm2niix_local_path = normalizePath(dcm2niix_path, mustWork = F),
                              dcm2niix_string) {
  commands <- paste(dcm2niix_local_path,
                    "-o", output_folder,
                    dcm2niix_string,
                    input_folder)

  print("Example commands:")
  cat("\n")
  print(head(commands, 3))
  cat("\n\n")
  return(commands)
}


## dicom converter

#' dcm2niix system calls using a list from dcm2nii_wrapper
#'
#' @param list from dcm2nii_wrapper
#' @param output_folder list of output folders (one for each subject and session)
#'
#' @examples
#' \dontrun{dcm2nii_converter("dcm2niix -o nii/session-id/participant-id/ -ba y -f %d -z y root_folder/session_id/participant_id/")}
dcm2nii_converter <- function(dcm2niix_string,
                              input_folder,
                              output_folder){

  list <- dcm2nii_wrapper(
    output_folder = output_folder,
    input_folder = input_folder,
    dcm2niix_string = dcm2niix_string
  )




  start_timer <- Sys.time()
  for (i in seq_along(list)) {
    done_file <- paste0(output_folder[i], "/done.txt")
    if (file.exists(done_file) == 0) {
      cat("\n")
      dir.create(output_folder[i], recursive = TRUE, showWarnings = FALSE)
      print_passed_time(i, list, start_timer, "dcm2niix (by Chris Rorden) conversion: ")
      system(list[i])
      write_file("done", done_file)
    } else if (file.exists(done_file) == 1) {
      print("Skipped: Subject already processed - folder contains done.txt")
    }
  }
  cat("\n\n")
  print_passed_time(i, list, start_timer, "Total:  ")
  print("===================================")
  print("Congratulation - the conversion was successful.")
}


#' Converts the DICOM to anonymized NII and JSON files.
#' @return
#' @export
#'
#' @examples
dcm2nii_converter_anon <- function(){
  dcm2nii_converter(dcm2niix_string = "-ba y -f %d -z y -w 0 -i y",
                    input_folder = input_dicom_folders$dicom_folder %>% normalizePath(mustWork = F),
                    output_folder = input_dicom_folders$output_path_nii %>% normalizePath(mustWork = F)
                    )
}

#' Converts the DICOM to only JSON files, that contain all sensitive information stored in the DICOM headers.
#'
#' @return
#' @export
#'
#' @examples
dcm2nii_converter_json <- function(){
  dcm2nii_converter(dcm2niix_string = "-b o -ba n -f %d",
                    input_folder = input_dicom_folders$dicom_folder %>% normalizePath(mustWork = F),
                    output_folder = input_dicom_folders$output_path_json %>% normalizePath(mustWork = F)
                    )
}
