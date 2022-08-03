#' Wrapper function to select and check the user input
#'
#' @return
#' @export
#'
#' @examples
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
    settings_file <<- file.choose() %>%
      normalizePath(., winslash = "/")

    # Check, that the file is valid!
    print(readLines(settings_file))


  } else {
    print("Okay, we create a 'user_settings.R' file together.\n\n")

    # starting get_user_input function
    get_user_input()

    # Clean subject IDs
    cleaning_subject_ids()

    # editing session IDs
    cleaning_session_ids()

    create_user_settings()

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

  ######################## input folder #############################
  print("Configuring input (root folder containing DICOM's), the order of 'session' and 'subject' folders and the output path.\n\n")

  switch_input_folder <- 2
  while (switch_input_folder == 2) {
    # DICOM Input folder on root level
    user_input_dir <<- shinyDirectoryInput::choose.dir(caption = "Please select the root directory of all DICOM images (Input). \n
  Your folder must be structured as e.g.: 'root/sessions/subjects/dicoms' OR 'root/subjects/sessions/dicoms'") %>%
      normalizePath(., winslash = "/")

    # Check input data
    cat("Input data check: \n\n")
    print(create_subject_session_df()$folder_short)

    # switch
    switch_input_folder <- menu(graphics = TRUE,
                                choices = c("Yes, these folders contain the DICOMs",
                                            "No, please let me select the folder again."),
                                title="Check your input data: Do these folders contain the DICOM images?")
    }
  ########################## folder order #############################
  cat("\n\n Now please select the order of folders in your input directory: Are they like '../subject_001/session_001/..' or like '../session_001/subject__001..'?\n\n" )
  print(create_subject_session_df()$folder_short)

  switch_input_order <- 2
  while (switch_input_order == 2) {
  # DICOM folder order
  user_input_order <<- ifelse(test = menu(graphics = TRUE,
    choices = c("'../sessions/subjects/DICOM' ?",
                "'../subjects/sessions/DICOM' ?"),
    title="Is your DICOM data folder structured as:") == 1,
    yes = "session_subject",
    no = "subject_session")

  # diagnostic check
  subject_session_df <<- check_folder_order_df(create_subject_session_df(), user_input_order)
  print(subject_session_df)

  # switch
  switch_input_order <- menu(graphics = TRUE,
                              choices = c("Yes, the 'subject' and 'session' column are valid.",
                                          "No, please let me select the folder order again."),
                              title="Do folders and subfolders are in the right order?")
  }

  ##################### output directory ####################################
  # Selection of output directory
  user_output_dir <<- shinyDirectoryInput::choose.dir(caption = "Please select the output directory, where all outputs should be saved. \n") %>%
    normalizePath(., winslash = "/")





}



#' Function to clean the input subject-ID's from redundant prefixes, suffices or strings.
#'
#' @return
#' @export
#'
#' @examples
cleaning_subject_ids <- function() {
  ######################### regex cleaning subject ID ############################
  data_cleaning_needed = menu(
    graphics = TRUE,
    choices = c(
      "Yes, I need to remove some prefixes, suffices or else.",
      "No, my subject-ID's are fine."
    ),
    title = "Do your subject-ID's need some file cleaning using regular expressions?"
  )

  if (data_cleaning_needed == 1) {
    print("--- Configuring data cleaning of subject names. --- \n\n")

    switch_subject_regex = 2
    while (switch_subject_regex == 2) {
      regex_subject_id <<- svDialogs::dlg_input("Please set your subject-ID regular expression: e.g. [:digit:]{3} for a three digit ID. \n \n Press cancel, if you don't know what to do, or want to keep the subject folder name.")$res

      if (!length(regex_subject_id) | isTRUE(str_detect(regex_subject_id, "nothing_configured")) | exists("regex_subject_id") == 0) {
        # The user clicked the 'cancel' button. Using the subject-ID from the folder
        cat("Ok, I am using the subject folder name as the subject-ID. \n\n")
        regex_subject_id <<- "nothing_configured"
        subject_session_df_BIDS <<- subject_session_df %>%
          mutate(subject_BIDS = paste0("sub-", subject) %>%
                   str_replace("sub-sub-", "sub-"))

      } else {


      # applying the regex to the subject ID
      print(paste("You selected: \n\n", regex_subject_id, "\n\n"))
      regex_subject_id <<- stringr::regex(regex_subject_id)
      subject_session_df_BIDS <<- subject_session_df %>%
        mutate(
          rest = stringr::str_remove_all(subject, regex_subject_id),
          subject_BIDS = stringr::str_extract(subject, regex_subject_id) %>%
            paste0("sub-", .) %>%
            str_replace("sub-sub-", "sub-")
        )
    }

    print("Do the subject columns look valid?\n\n")
    subject_session_df_BIDS %>%
      select(-dicom_folder, -session) %>% unique() %>% print()

    switch_subject_regex <- menu(
      graphics = TRUE,
      choices = c(
        "Yes, they are valid.",
        "No, please let me change the subject regular expression."
      ),
      title = "Are the subject-ID's correct?"
    )

  }





    cat("\n\n Your 'regex_subject_id' is:\n\n")
    print(regex_subject_id)

    ############################# regex pattern to remove ####################################
    print("--- Configuring data cleaning of patterns, that needs to be removed from the subject-ID's --- \n\n")

    switch_pattern_regex = 2
    while (switch_pattern_regex == 2) {
      regex_remove_pattern <<- svDialogs::dlg_input("Please set your regular expressions, you want to remove from the data. \n The string 'my_study' would remove this string from each of the ID's. \n If you want to use multiple patterns just connect them with the '|' operator: 'study_a|study_b'\n\n Press cancel, if you don't know what to do, nothing will be removed from the string.")$res

      if (!length(regex_remove_pattern) | isTRUE(str_detect(regex_remove_pattern, "nothing_configured"))) {
        # The user clicked the 'cancel' button. Using the sequence-ID from the folder
        cat("OK, I am using the session folder name as session-ID.")
        regex_remove_pattern <<- "nothing_configured"

      } else {

        cat("You selected: \n\n", regex_remove_pattern, "\n\n")
        regex_remove_pattern <<- stringr::regex(regex_remove_pattern)
        subject_session_df_BIDS <<- subject_session_df_BIDS %>%
          mutate(removed = stringr::str_extract_all(subject_BIDS, regex_remove_pattern),
                 subject_BIDS = stringr::str_remove(subject_BIDS, regex_remove_pattern) %>%
                   paste0("sub-", .) %>%
                   str_replace("sub-sub-", "sub-"))
      }

      print("Do the subject columns look valid?\n\n")
      subject_session_df_BIDS %>%
        select(-dicom_folder, -session) %>% unique() %>% print()

      switch_pattern_regex <- menu(graphics = TRUE,
                                   choices = c("Yes, they are valid.",
                                               "No, please let me change 'the pattern to remove' regular expression."),
                                   title="Are the subject-ID's correct?")


    }
  } else {
    regex_subject_id <<- "nothing_configured"
    regex_remove_pattern <<- "nothing_configured"

    subject_session_df_BIDS <<- subject_session_df %>%
      mutate(subject_BIDS = paste0("sub-", subject) %>%
               str_replace("sub-sub-", "sub-"))
    subject_session_df_BIDS %>%
      select(-dicom_folder, -session) %>% unique() %>% print()
  }


  cat("\n\n Your BIDS subject-ID's are: \n\n")
  print(unique(subject_session_df_BIDS$subject_BIDS))
  cat("\n\n")
}


#' Extracts the input data folder structure
#'
#' @param directory
#'
#' @return
#' @export
#'
#' @examples
create_subject_session_df <- function(directory = user_input_dir){
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

  if(nrow(df) == 0){
    stop("ERROR: No folders found in your selected folder")
  }

  return(df)
}


#' Wrapper function for the editing of session-IDS
#'
#' @return
#' @export
#'
#' @examples
cleaning_session_ids <- function(){

  create_subject_session_df()

  cat("--- Configuring session information. --- \n\n")

  cat("Your sessions are numbered automatically. You can change this in the next step: \n\n")

  cat("These are your unique session-ID's:\n\n")
  subject_session_df_BIDS$session %>% unique() %>% print()

  session_cleaning_needed = menu(graphics = TRUE,
                              choices = c("Yes, I need to change them.",
                                          "No, my session-ID's are fine."),
                              title="Do your session-ID's need some renaming?")

  if(session_cleaning_needed == 1){
    subject_session_df_BIDS <<- edit_session_df() %>%
      mutate(session_BIDS = paste0("ses-", session_BIDS) %>%
               str_replace("ses-ses-", "ses-"))
  } else {
    subject_session_df_BIDS <<- subject_session_df_BIDS %>%
      mutate(session_BIDS = paste0("ses-", session) %>%
               str_replace("ses-ses-", "ses-"))
  }

  cat("Your new sessions are named like this:\n\n")
  subject_session_df_BIDS %>%
    select(session, session_BIDS) %>% unique() %>% print()
}






#' Enables user edits to the session ID.
#'
#' @return
#' @export
#'
#' @examples
edit_session_df <- function(){
  df <- subject_session_df_BIDS %>%
    select(session) %>%
    unique() %>%
    mutate(session_BIDS = session %>%
             as.factor() %>%
             as.integer() %>%
             as.character())

  for (i in 1:nrow(df)) {
    df$session_BIDS[i] <- svDialogs::dlg_input(paste0("Please set your new session-ID for the old session-ID: \n",
                                                      df$session[i], " (", i, " of ", nrow(df), ")"),
                                               default = df$session_BIDS[i])$res}

  df_out <- subject_session_df_BIDS %>%
    left_join(df, by = "session")

  cat("Sessions are edited:")
  # print(df_out)
  return(df_out)
}



#' Checks the folder order
#'
#' @param df
#' @param input_order
#'
#' @return
#' @export
#'
#' @examples
check_folder_order_df <- function(df, input_order = user_input_order){
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
        Change it to 'session_subject' if 'subject' and 'session' are in the wrong columns here.")
    cat("\n\n")

  } else {
    cat("\n\n")
    stop("ERROR: Please choose your 'input order'.
         'root/sub-XXX/ses-XXX/' is 'subject_session'.
         'root/ses-XXX/sub-XXX' is 'session_subject'.")

  }
  # print(head(df))
  cat("\n\n")
  return(df)
}




#' Creates a user setting template file at working directory or custom folder. This file is required for all processing.
#'
#' @param folder Set the folder to save your file.
#'
#' @return The path to the folder
#' @export
#'
#' @examples
create_user_settings <- function(folder = shinyDirectoryInput::choose.dir(caption = "Select the folder, where your 'user_settings.R' file should be saved.")){

  print("Creating the user settings file.")
  settings_string <- paste0(
    '# Input path: that contains multiple folders per "session/subject" or "subject/session", containing all DICOMS in subject folders
path_input_dicom <- "', user_input_dir, '/"
folder_order <<- "', user_input_order, '"

# output folder
path_output <- "', user_output_dir,'/"


study_name <- "BiDirect Study"

# regular expressions
regex_subject_id <- "', regex_subject_id,'"


# optional settings
# regex_group_id <- "[:digit:]{1}(?=[:digit:]{4})"
regex_remove_pattern <- "', regex_remove_pattern,'"

# session ids
sessions_id_old <- c("', subject_session_df_BIDS$session %>% unique() %>% paste0(., collapse = '", "'), '")
sessions_id_new <- c("', subject_session_df_BIDS$session_BIDS %>% unique() %>% paste0(., collapse = '", "'), '")

# edit this string only, if you know, what you are doing

dcm2niix_argument_string <- "-ba y -f %d -z y -w 0 -i y"

# -ba y = BIDS anonymisation (yes - anonymise JSON sidecar files)
# -f %d = filename string (please do not change this one)
# -z y = zip these files (yes - gunzip, nii.gz output)
# -w 0 = name conflicts (0 = skip)
# -i y = ignore derived, localicer and 2d images (yes)

# mri sequence ids
mri_sequences <- c("T1|T2|DTI|fmr|rest|rs|func|FLAIR|smartbrain|survey|smart|ffe|tse")')

  if(!dir.exists(folder)){
    path_to_folder(folder)
  }

  path <- paste0(folder, "/user_settings.R")


  if(!file.exists(path)){
    print(paste("The file was created in this folder:", folder))
    writeLines(settings_string, path)
    # print("The file will be opened in 5 seconds. Please edit the file to your needs.")
    # Sys.sleep(5)
    # file.edit(path)
  } else {
    print(paste("The file already exists:", path))
  }
  settings_file <<- path
  return(path)
}


