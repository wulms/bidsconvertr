select_user_settings_file <- function(){
  cat("============ Welcome to BIDSconvertR ============ \n\n\n")

  # Existing user settings file? 1 = yes, 2 = no
  user_settings_file_existing <<- menu(graphics = TRUE,
    c("Yes",
      "No, please create one for me."),
    title="Do you have a user settings file?")

  if(user_settings_file_existing == 1){
    print("Please select the 'user_settings.R' file now:")
    # Select the file!
    user_settings_file <<- file.choose() %>%
      normalizePath(., winslash = "/")

    # Check, that the file is valid!
    readLines(user_settings_file)
  } else {
    print("Okay, we create a 'user_settings.R' file together.\n\n")

    # starting get_user_input function
    get_user_input()

  }
}


#' Start function for the user inputs, asks for input directory, output directory and the order of the input data 'subject_session' or 'session_subject'.
#'
#' @return
#' @export
#'
#' @examples
get_user_input <- function(){
  print("---------- Creation of 'user_settings.R' file ---------- \n\n\n")

  print("Configuring input (root folder containing DICOM's), the order of 'session' and 'subject' folders and the output path.\n\n")

  # DICOM Input folder on root level
  user_input_dir <<- shinyDirectoryInput::choose.dir(caption = "Please select the root directory of all DICOM images (Input). \n
  Your folder must be structured as e.g.: 'root/sessions/subjects/dicoms' OR 'root/subjects/sessions/dicoms'") %>%
    normalizePath(., winslash = "/")
  #}

  # DICOM folder order
  user_input_order <<- ifelse(test = menu(graphics = TRUE,
    choices = c("'../sessions/subjects/DICOM' ?",
                "'../subjects/sessions/DICOM' ?"),
    title="Is your DICOM data folder structured as:") == 1, "session_subject")

  # Selection of output directory
  user_output_dir <<- shinyDirectoryInput::choose.dir(caption = "Please select the output directory, where all outputs should be saved. \n") %>%
    normalizePath(., winslash = "/")

  # Clean subject IDs
  cleaning_subject_ids()



}



#' Function to clean the input subject-ID's from redundant prefixes, suffices or strings.
#'
#' @return
#' @export
#'
#' @examples
cleaning_subject_ids <- function(){
  data_cleaning_needed = menu(graphics = TRUE,
    choices = c("Yes, I need to remove some prefixes, suffices or else.",
                "No, my subject-ID's are fine."),
    title="Do your subject-ID's need some file cleaning using regular expressions?")

  if(data_cleaning_needed == 1){

    print("--- Configuring data cleaning of subject names. --- \n\n")

    regex_subject_id <- svDialogs::dlg_input("Please set your subject-ID regular expression: e.g. [:digit:]{3} for a three digit ID. \n \n
                                             Press cancel, if you don't know what to do, or only want to remove a suffix, prefix or else.")

    if (!length(regex_subject_id)) {# The user clicked the 'cancel' button
      cat("OK, we skip to patterns, that you want to remove, e.g. 'study_id' prefix or suffix you want to remove from each subject-ID!\n\n")
      regex_subject_id <<- "nothing_configured"
    } else {
      cat("You selected: \n\n", regex_subject_id, "\n\n")
      regex_subject_id <<- regex_subject_id
    }

    print("--- Configuring data cleaning of patterns, that needs to be removed from the subject-ID's --- \n\n")

    regex_remove_pattern <- svDialogs::dlg_input("Please set your regular expressions, you want to remove from the data. \n
                                                 The string 'my_study' would remove this string from each of the ID's. \n
                                                 If you want to use multiple patterns just connect them with the '|' operator: 'study_a|study_b'\n\n.
                                             Press cancel, if you don't know what to do, nothing will be removed from the string.")

    if (!length(regex_subject_id)) {# The user clicked the 'cancel' button
      cat("OK, we skip to the next step.")
      regex_remove_pattern <<- "nothing_configured"
    } else {
      cat("You selected: \n\n", regex_remove_pattern, "\n\n")
      regex_remove_pattern <<- regex_remove_pattern
    }

    print("--- Configuring session information. --- \n\n")


  } else {
    regex_subject_id <<- "nothing_configured"
    regex_remove_pattern <<- "nothing_configured"

    print("OK, we skip to the next step.")
  }
}



cleaning_session_ids <- function(directory = user_input_dir){

  df <- dir(directory, full.names = TRUE) %>%
    lapply(FUN = dir,
           recursive = FALSE,
           full.names = TRUE) %>%
    unlist() %>%
    normalizePath(winslash = "/") %>%
    data.frame(dicom_folder = ., stringsAsFactors = FALSE)  %>%
    # extract relevant information
    mutate(
      folder_short = str_remove(dicom_folder, directory) %>%
        str_replace("////", "//") %>%
        str_replace("\\\\", "/") %>%
        str_remove("^/"))


  print(df)

  session_cleaning_needed = menu(graphics = TRUE,
                              choices = c("Yes, I need to change them.",
                                          "No, my session-ID's are fine."),
                              title="Do your session-ID's need some renaming?")
}



# index_folders <- function(path){
#
#   path <- normalizePath(path) %>% str_replace_all("\\\\", "/")
#
#   path2 <- ifelse(str_detect(path, "/$"), paste0(path, "/"))
#
#   dicom_folders <- list.dirs(path, full.names = TRUE, recursive = TRUE)
#
#   print(paste("Following number of folders were found", length(dicom_folders)))
#   print(paste("Showing the first 10: "))
#   head(dicom_folders, n = 10)
#   stringr::str_remove(dicom_folders, path)
#
#
#
# }



