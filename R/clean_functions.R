


# helper functions ---------------------------------------------------------------------




#' Prints progress of files in list of files
#'
#' @param item item in for loop
#' @param list_of_files list, where the item comes from
#' @param start Sys.time() of start, used to calculate the time difference
#' @param string String, to describe the function of the loop
#' @export
#'
#' @examples
print_passed_time <- function(item, list_of_files, start, string) {
  end <- Sys.time()
  time_difference <- difftime(end, start, unit = "mins") %>% round(2)
  time_info <- paste("Time since start: ",
                     time_difference %>%
                       round(0), " min.  ETA: ",
                     (difftime(end,
                               start,
                               unit = "mins")/item*length(list_of_files) - time_difference) %>%
                       round(0),
                     " min. remaining.")
  file_info <- paste(" ", item, " / ",
                     length(list_of_files),
                     " total. (",
                     round(item / length(list_of_files) * 100, 0),
                     "%)")
  list_item <- list_of_files[item]
  print(paste(string, time_info))
  cat("\n")
  print(file_info)
  cat("\n")
  print("List item: ")
  print(list_item)
}

#' Create folders from (list of) filenames
#'
#' @param list_of_files filename, list of filenames containing path
#'
#' @return Nothing - creates folders for these files on the system
#' @export
#'
#' @examples
#' path_to_folder("folder/subfolder/file.txt")
path_to_folder <- function(list_of_files) {
  paths_folder <- sub("[/][^/]+$", "", list_of_files)
  paths_folder <- unique(paths_folder)

  paths_folder <- paths_folder[!dir.exists(paths_folder)]
  # print(head(paths_folder))
  lapply(paths_folder,
         dir.create,
         recursive = TRUE,
         showWarnings = FALSE)
}



# user dialogue -----------------------------------------------------------

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
    # settings_file <<- file.choose() %>%
    #   normalizePath(., winslash = "/")

    settings_file <<- choose.files(default = "user_settings.R",
                                   caption = "Select 'user_settings.R file.",
                                   multi = FALSE,
                                   filter = Filters[c("R"),]) %>%
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

    create_user_settings(folder = user_output_dir)

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

  # input folder
  print("Configuring input (root folder containing DICOM's), the order of 'session' and 'subject' folders and the output path.\n\n")
  svDialogs::dlg_message("Please select your input folder now. It contains folders per session & subject or subject & session with the DICOM data. Your folder must be structured as follows: \n\n 'root/sessions/subjects/dicoms' \n\n 'root/subjects/sessions/dicoms'")


  switch_input_folder <- 2
  while (switch_input_folder == 2) {
    # DICOM Input folder on root level
    user_input_dir <<- shinyDirectoryInput::choose.dir(caption = "Select the input directory of DICOM folders:") %>%
      normalizePath(., winslash = "/")

    # Check input data
    cat("Input data check: \n\n")
    print(create_subject_session_df()$folder_short)

    # switch
    switch_input_folder <- menu(graphics = TRUE,
                                choices = c("Yes, these folders contain the DICOMs",
                                            "No, please let me select the folder again."),
                                title="Do these folders contain the DICOMs?")
  }

  # folder order
  cat("\n\n Now please select the order of folders in your input directory: Are they like '../subject_001/session_001/..' or like '../session_001/subject_001..'?\n\n" )
  svDialogs::dlg_message(c("Select input data structure (order of folders):",
                           "",
                           "'.../subject_id/session_id/...'",
                           "'.../session_id/subject_id/...'?"))

  print(create_subject_session_df()$folder_short)

  switch_input_order <- 2
  while (switch_input_order == 2) {
    # DICOM folder order
    user_input_order <<- ifelse(test = menu(graphics = TRUE,
                                            choices = c("'../sessions/subjects/DICOM' ?",
                                                        "'../subjects/sessions/DICOM' ?"),
                                            title="Select input data structure:") == 1,
                                yes = "session_subject",
                                no = "subject_session")

    # diagnostic check
    subject_session_df <<- check_folder_order_df(create_subject_session_df(), user_input_order)

    subject_session_df %>%
      select(-dicom_folder) %>%
      print.data.frame()

    # switch
    switch_input_order <- menu(graphics = TRUE,
                               choices = c("Yes, the 'subject' and 'session' column are valid.",
                                           "No, please let me select the folder order again."),
                               title="Are 'subject' and 'session' correct?")
  }

  # output directory
  # Selection of output directory
  svDialogs::dlg_message("Now please select your output directory. All BIDS data and the `user_settings.R` file will be stored here.")

  user_output_dir <<- shinyDirectoryInput::choose.dir(caption = "Select output directory:") %>%
    normalizePath(., winslash = "/")





}



#' Function to clean the input subject-ID's from redundant prefixes, suffices or strings.
#'
#' @return
#' @export
#'
#' @examples
cleaning_subject_ids <- function() {

  svDialogs::dlg_message("Optional data cleaning: \n\n You are able in case of redundant information in your subject-IDs to: \n\n (1) define the IDs (e.g. [:digit:]{5} for 5 digit IDs) and/or \n (2) remove redundant prefixes, suffices or strings using regular expressions (e.g. 'study_a' from 'study_a_0001'). \n\n Skip this step, if your IDs are fine.")

  # regex cleaning subject ID
  data_cleaning_needed = menu(
    graphics = TRUE,
    choices = c(
      "Yes, I need to remove some prefixes, suffices or else.",
      "No, my subject-ID's are fine."
    ),
    title = "Clean subject-IDs?"
  )

  if (data_cleaning_needed == 1) {
    print("--- Configuring data cleaning of subject names. --- \n\n")

    switch_subject_regex = 2
    while (switch_subject_regex == 2) {

      svDialogs::dlg_message(c("You can define your subject-ID with a regular expression in the next step: \n\n",
                             "[:digit:]{3} = three digit subject-IDs (e.g. 001-999)\n",
                             "[:alnum:]{5} = five alphanumerical signs (e.g. I0001, C0001)\n",
                             "(Control|Intervention)_[:digit:]{3} = Control_001 OR Intervention_001 to Control_999 OR Intervention_999"

                             ))

      regex_subject_id <<- svDialogs::dlg_input("Set subject-ID regular expression: \n\n e.g. [:digit:]{3} for a three digit ID. \n\n Press cancel, if you don't know what to do, or want to keep the subject folder name.")$res

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

    # regex pattern to remove
    cat("--- Configuring data cleaning of patterns, that needs to be removed from the subject-ID's --- \n\n")

    switch_pattern_regex = 2
    while (switch_pattern_regex == 2) {

      svDialogs::dlg_message("Set the regular expressions, you want to remove from your subject-IDs. \n\n E.g. the string 'my_study' removes this string from each of the subject-IDs. \n\n If you want to use multiple patterns just connect them with the '|' operator: 'study_a|study_b'")

      regex_remove_pattern <<- svDialogs::dlg_input("Set the regular expressions, you want to remove from your subject-IDs. \n\n Click 'cancel' to skip.")$res

      if (!length(regex_remove_pattern) | isTRUE(str_detect(regex_remove_pattern, "nothing_configured"))) {
        # The user clicked the 'cancel' button. Using the sequence-ID from the folder
        cat("OK, I am using the session folder name as session-ID.")
        regex_remove_pattern <<- "nothing_configured"

      } else {

        cat("You selected: \n\n", regex_remove_pattern, "\n\n")
        regex_remove_pattern <<- stringr::regex(regex_remove_pattern)
        subject_session_df_BIDS <<- subject_session_df_BIDS %>%
          dplyr::mutate(removed = stringr::str_extract_all(subject_BIDS, regex_remove_pattern),
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
      dplyr::mutate(subject_BIDS = paste0("sub-", subject) %>%
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
    dplyr::mutate(
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
                                 title="Rename session-IDs?")

  if(session_cleaning_needed == 1){
    subject_session_df_BIDS <<- edit_session_df() %>%
      dplyr::mutate(session_BIDS = paste0("ses-", session_BIDS) %>%
                      str_replace("ses-ses-", "ses-"))
  } else {
    subject_session_df_BIDS <<- subject_session_df_BIDS %>%
      dplyr::mutate(session_BIDS = paste0("ses-", session) %>%
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

  sessions_fine <- 0

  while (sessions_fine == 0) {
    df <- subject_session_df_BIDS %>%
      select(session) %>%
      unique() %>%
      dplyr::mutate(session_BIDS = as.character(session))

    for (i in 1:nrow(df)) {
      df$session_BIDS[i] <- svDialogs::dlg_input(paste0("Please set your new session-ID for the old session-ID: \n The BIDS-prefix 'ses-' will be added automatically.",
                                                        df$session[i], " (", i, " of ", nrow(df), ")"),
                                                 default = df$session_BIDS[i])$res}

    df_out <- subject_session_df_BIDS %>%
      left_join(df, by = "session")

    cat("Sessions are edited:")

    print(df)

    df_out %>%
      select(-dicom_folder) %>%
      print()

    sessions_fine <- menu(graphics = TRUE,
                          choices = c("Yes.",
                                      "No, please let me edit them again."),
                          title="Do your session-ID's look fine?")
  }


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

# preparation -------------------------------------------------------------
#' Sets up the environment, creates needed variables variables
#'
#' @param input_path The path for the BIDSconvertR output
#'
#' @return
#' @export
#'
#' @examples
create_environment_variables <- function(input_path = path_output){
  print("Creating all environment variables")

  dcm2niix_path <<- paste0(path_output, "/dcm2niix")
  # dcm2niix_path <<- system.file("dcm2niix", package = "BIDSconvertR")
  #
  # if(str_length(dcm2niix_path) == 0){
  #   dcm2niix_path <<- system.file("dcm2niix.exe", package = "BIDSconvertR")
  #   if(str_length(dcm2niix_path) == 0){stop("Error: dcm2niix not found.")}
  # } else {
  #   print(paste("dcm2niix by Chris Rorden was identified on your system: ", dcm2niix_path))
  # }

  # output converter folder

  if(str_detect(input_path, "/$") == 0){
    input_path <- paste0(input_path, "/")
  }

  if(str_detect(path_input_dicom, "/$") == 0){
    path_input_dicom <- paste0(path_input_dicom, "/")
  }

  path_output_converter <<- paste0(input_path, "/bidsconvertr")

  # user files
  path_output_user <<- paste0(path_output_converter, "/user")
  path_output_user_templates <<- paste0(path_output_user, "/templates")
  path_output_user_diagnostics <<- paste0(path_output_user, "/diagnostics")
  path_output_user_settings <<- paste0(path_output_user, "/settings")

  # converter outputs
  path_output_converter_temp <<- paste0(path_output_converter, "/dcm2niix_converted")
  path_output_converter_temp_nii <<- path_output_converter_temp
  path_output_converter_temp_json <<- paste0(path_output_converter, "/identifying_information/json_sensitive")

  # BIDS output
  path_output_bids <<- paste0(path_output_converter, "/bids")

  # Dashboards
  path_output_user <<- paste0(path_output_converter, "/dashboard")

}

#' Prepares the environment with custom variables based on the user settings file.
#'
#' @param user_settings_file The path to the user settings file, created by "create_user_setting()".
#'
#' @return A mapping of the DICOM to NII mapping
#' @export
#'
#' @examples
prepare_environment <- function(user_settings_file = settings_file){

  print("Preparing the environment")
  # source("new_version/user_settings_home.R") # Home
  source(user_settings_file)

  create_environment_variables()

  # indexing all folders
  input_dicom_folders <<- list_dicom_folders()
  return(input_dicom_folders)
}





# indexing and checks -----------------------------------------------------


#' Finds dicom folders in dicom/session/subject folder structure
#'
#'
#' @return dataframe containing list, session and subject id
#' @export
#'
#' @examples \dontrun{list_dicom_folders("dicom")}
list_dicom_folders <- function() {

  print(paste("Your old session IDs:", sessions_id_old))
  print(paste("Your new session IDs:", sessions_id_new))

  string_sessions <<- sessions_id_old %>%
    paste0(collapse = "|")

  string_sessions <<- paste0("(", string_sessions, ")") %>%
    regex(., ignore_case = TRUE)


  if(!dir.exists(path_input_dicom)){
    stop("ERROR: The 'path_input_dicom' does not exist. Please set up a valid existing folder.")
  }

  df <- check_folder_order()

  df <- check_filenames(df)

  check_dataframe(df)

  path_to_folder(paste0(path_output_converter, "/dicom_paths.tsv"))
  write_tsv(df, file = paste0(path_output_converter, "/dicom_paths.tsv"))

  return(df)
}






#' Checks the folder order, reads the directory, extracts session and subject folder.
#'
#' @return
#' @export
#'
#' @examples
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


#' Checks the filenames
#'
#' @param df
#'
#' @return
#' @export
#'
#' @examples
check_filenames <- function(df = df){
  cat("\n\n Preparing filenames \n\n")


  # create short filenames
  df1 <- create_short_ids(df)

  df_out <- df1 %>%
    # output path
    dplyr::mutate(
      # switch session-IDS
      new_session_id = reduce2(paste0(sessions_id_old, "$"),
                               sessions_id_new,
                               .init = session,
                               str_replace),
      output_path_nii = paste0(path_output_converter_temp_nii,
                               "/sub-", your_subject_id,
                               "/ses-", new_session_id) %>%
        str_replace_all("ses-ses-", "ses-"),
      output_path_json = paste0(path_output_converter_temp_json,
                                "/sub-", your_subject_id,
                                "/ses-", new_session_id) %>%
        str_replace_all("ses-ses-", "ses-")
    ) %>%
    relocate(dicom_folder, your_subject_id,
             session, new_session_id)

  cat("\n\n")
  print(df_out)
  cat("\n\n")

  return(df_out)
}


#' Create short IDs
#'
#' @param df
#'
#' @return
#' @export
#'
#' @examples
create_short_ids <- function(df){
  df_out <- df %>%
    dplyr::rowwise() %>%
    dplyr::mutate(your_subject_id = ifelse(regex_subject_id == "nothing_configured",
                                           yes = stringr::str_remove(subject, "^sub-"),
                                           no = stringr::str_remove(subject, "^sub-") %>%
                                             stringr::str_extract(., stringr::regex(regex_subject_id)))
                  ) %>%
    # if one is NA, switch with extracted info before regex
    dplyr::mutate(your_subject_id = ifelse(is.na(your_subject_id),
                               yes = subject,
                               no = your_subject_id)) %>%
    # create rest string
    dplyr::mutate(
      rest_string = stringr::str_remove(subject, "^sub-") %>%
        stringr::str_remove(your_subject_id) %>%
        stringr::str_remove("//"),
      rest_string2 = stringr::str_remove_all(rest_string,
                                             stringr::regex(regex_remove_pattern, ignore_case = TRUE))
    )
  return(df_out)
}


#' Checks dataframe for plausibility
#'
#' @param df
#'
#' @return
#' @export
#'
#' @examples
check_dataframe <- function(df){
  # checks
  cat("\n\n Running diagnostics on the data. \n\n")

  print(head(df))

  cat("\n\n")

  if(df %>% dplyr::count(rest_string, rest_string2) %>% nrow() > 0){
    print("The following strings are unmatched strings. These are automatically removed from the file")
    print(df %>% dplyr::count(rest_string, rest_string2))
    cat("\n\n")
    Sys.sleep(2)
  }

  if(df %>% dplyr::count(session, new_session_id) %>% nrow() > 0){
    print("This is the amount of data per session:")
    print(df %>% dplyr::count(session, new_session_id))
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
    filter(is.na(session))

  if(unmatched_sessions %>% nrow() > 0){
    print(paste("Unmatched session-IDs identified: ", nrow(unmatched_sessions)))
    print(unmatched_sessions)
    cat("\n\n")
    Sys.sleep(2)
    stop("Please start a new user file or edit the old one manually, until all session-IDs are matched!")

  }

  # Preview
  print("Preview of extracted data: ")
  print.data.frame(df, max = 100)
  Sys.sleep(2)
  # cat("\014")
}




# dicom2niix installation -------------------------------------------------

# install dcm2niix
#' installs dcm2niix from Chris Rordens Github Repository, also depending on OS
#'
#' @param dcm2niix_release The version number of dcm2niix that you need. E.g. "v1.0.20211006".
#'
#' @examples install_dcm2niix()
#' @export
install_dcm2niix <- function(dcm2niix_release = "v1.0.20211006") {

  dcm2niix_release_path <- paste0("https://github.com/rordenlab/dcm2niix/releases/download/",
                                  dcm2niix_release, "/dcm2niix_")

  if (length(list.files(path = path_output,
                        pattern = "dcm2niix")) == 0) {
    os <- Sys.info()["sysname"]
    if (os == "Darwin") {
      message("Identified MacOs. Not officially supported!")
      dcm2niix <- paste0(dcm2niix_release_path, "mac.zip")
    }
    else if (os == "Linux") {
      message("Identified Linux.")
      dcm2niix <- paste0(dcm2niix_release_path, "lnx.zip")
    }
    else if (os == "Windows") {
      message("Identified windows.")
      dcm2niix <-
        paste0(dcm2niix_release_path, "win.zip")

    } else {
      print(Sys.info()["sysname"])
      stop("OS not identified. Please issue the sysname on Github.")
    }




    print(paste("The dcm2niix files are at the following location: ", dcm2niix_path))

    download.file(dcm2niix, paste0(dcm2niix_path, ".zip"))
    unzip(zipfile = paste0(dcm2niix_path, ".zip"),
          exdir = normalizePath(path_output))
    file.remove(paste0(dcm2niix_path, ".zip"))
    if (os == "Linux") {
      Sys.chmod(dcm2niix_path, mode = "0777")
    }
  }
}


# dicom conversion --------------------------------------------------------

#' Creates the dcm2niix system commands for the conversion
#'
#' @param input Folder path(s) containing dicoms
#' @param output Folder path(s) where the nii images should be exported to
#' @param scanner_type MRI scanner vendor type
#' @param dcm2niix_path Path to dcm2niix tool on your system
#'
#' @export
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
  cat("\n\n =================================== \n\n")
  print("Congratulation - the conversion was successful. \n\n")
}


#' Converts the DICOM to anonymized NII and JSON files.
#' @return
#' @export
#'
#' @examples
dcm2nii_converter_anon <- function(){
  dcm2nii_converter(dcm2niix_string = dcm2niix_argument_string,
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




# json extraction ---------------------------------------------------------
#' This function lists all json files in the folder. It extracts possible sequences based on the "mri_sequences" regex. Furthermore it outputs a "sequence_overview" TSV file containing sequence information and the observations per category. This file is needed for the sequence mapper.
#'
#' @param input_path File path containing all json files
#' @param output_suffix Suffix, which will be added to the "sequence_overview" TSV file.
#'
#' @return
#' @export
#'
#' @examples
list_json_files <- function(input_path,
                            output_suffix = ""){

  cat("Listing up the json sidecar files\n\n")
  json_files <- list.files(input_path, pattern = "json$",
                           recursive = TRUE, full.names = TRUE)

  json_files <- str_replace(json_files, "//", "/")

  json_df <- tibble(json_path = json_files) %>%
    mutate(short_strings = str_extract(json_path,
                                       "(?<=(dcm2niix_converted|json_sensitive)/)sub-.*$")) %>%
    separate(short_strings, c("subject", "session", "sequence"), "/") %>%
    mutate(sequence = str_remove(sequence, "\\.json"),
           possible_sequence = str_extract_all(sequence,
                                               regex(mri_sequences, ignore_case = TRUE),
                                               simplify = FALSE)) %>%
    rowwise() %>%
    mutate(possible_sequence = paste(possible_sequence, collapse=", ")) %>%
    ungroup() %>%
    mutate(possible_sequence = str_replace(possible_sequence,
                                           pattern = regex("(survey|smartbrain|smart)",
                                                           ignore_case = TRUE),
                                           replacement = "localizer"))

  cat("\n")
  print("Sequences by session")

  json_temp <- json_df%>%
    mutate(subject_session = paste0(subject, "_", session)) %>%
    select(sequence, subject_session) %>%
    group_by(sequence) %>%
    summarise(subject_session_merge = paste(subject_session, collapse = ", "))

  json_overview <- json_df %>%
    select(-json_path, -subject) %>%
    group_by(session, sequence, possible_sequence) %>%
    dplyr::count() %>%
    pivot_wider(names_from = session, values_from = n) %>%
    group_by(sequence, possible_sequence) %>%
    mutate(total = sum(c_across(contains("ses-")), na.rm = TRUE)) %>%
    arrange(desc(possible_sequence), desc(total)) %>%
    left_join(json_temp) %>%
    mutate(subject_session_merge = ifelse(test = total > 30,
                                          yes = "to many observations (>30)",
                                          no = subject_session_merge)
    )

  json_overview %>%
    print(n = Inf)

  cat("\n\n Sequence overview saved to file:\n\n")

  if(output_suffix == "_anon"){
    output_tsv <- paste0(path_output_converter, "/sequence_overview", output_suffix, ".tsv")
  } else {
    output_tsv <- paste0(path_output_converter, "/identifying_information/sequence_overview", output_suffix, ".tsv")
  }

  print(output_tsv)
  readr::write_tsv(json_overview,
                   file = output_tsv,
                   append = FALSE)

  cat("\n")
  cat("\n")

  return(json_df)
}


#' Extracts json headers from multiple files with different headers
#'
#' @param json a list of json files
#' @param working_dir directory
#'
#' @return empty dataframe with each unique column found in one json file
#' @export
#'
#' @examples get_json_headers(list_of_jsons)
get_json_headers <- function(json) {
  cat("\n\n Extracting the headers of the json sidecars.\n\n")
  start_timer <- Sys.time()
  mri_properties <- vector()
  # str(mri_properties)
  for (i in 1:length(json)) {
    if(i %% 10000 == 0){
      print_passed_time(i, json, start_timer, "Extraction of Headers: ")
    }
    if(file.info(json[i])$size > 0){
      # Reading json headers
      mri_properties_new <- names(rjson::fromJSON(file = json[i]))
      mri_properties <- union(mri_properties, mri_properties_new)
    } else {
      print(paste("This file", json[i], "is empty. Please check manually."))
    }
  }
  # Building df
  names = mri_properties %>% sort()
  empty_df <- data.frame()
  for (k in names)
    empty_df[[k]] <- as.character()
  cat("Extracted all json headers - Success!\n\n")
  empty_df <- empty_df %>% mutate(Path = NULL)
  return(empty_df)
}

#' Extracts the information from each json and merges it to the dataframe.
#' Depends on existing columns! Identified by get_json_headers
#'
#' @param json_path path containing the json files
#' @param output_suffix suffix, which will be appended to the output file
#'
#' @return writes a tsv (prefix "json_metadata") containing all headers and the contained information from the JSON files.
#' @export
#'
#' @examples read_json_headers(json_list, empty_df_with_headers)
read_json_headers <- function(json_path, suffix = "") {


  if(suffix == "_anon"){
    json_metadata_output_tsv <- paste0(path_output_converter, "/json_metadata", suffix, ".tsv")
  } else {
    json_metadata_output_tsv <- paste0(path_output_converter, "/identifying_information/json_metadata", suffix, ".tsv")
  }

  json_files <- list_json_files(json_path, output_suffix = suffix) %>%
    filter(str_detect(json_path, "participants\\.json", negate = TRUE))

  json = json_files$json_path


  empty_df <- get_json_headers(json)

  if (file.exists(json_metadata_output_tsv) == 1) {
    cat("Comparing the json metadata tsvs")
    length_output <- readr::read_tsv(json_metadata_output_tsv, show_col_types = FALSE) %>% nrow()
    length_input <- nrow(json_files)
    print(paste("Output length", length_output))
    print(paste("Input length", length_input))
    Sys.sleep(5)
    if(length_output == length_input){
      print("Both have equal length - file alread contains all data. Extraction is skipped.")
    } else {
      # print("Delete file")
      file.remove(json_metadata_output_tsv)
    }}

  if(file.exists(json_metadata_output_tsv) == 0){
    cat("\n\n Merged json file does not exists. Will be extracted. \n\n")
    start_timer <- Sys.time()

    for (i in 1:length(json)) {
      if(i %% 10000 == 0){
        print_passed_time(i, json, start_timer, "Extracting metadata of Headers: ")
      }
      if(file.info(json[i])$size > 0) {
        result_new <- rjson::fromJSON(file = json[i], simplify = TRUE) %>%
          lapply(paste, collapse = ", ") %>%
          lapply(str_replace_all, pattern = "\\n|\\r", replacement = " ") %>%
          bind_rows() %>%
          mutate(Path = json[i])
        result_new <- merge(empty_df, result_new, all = TRUE, sort = F)
        result_new <- result_new[sort(names(result_new))]

        results_table <- result_new %>%
          mutate(subject = str_extract(Path, "sub-.*(?=/ses-)"),
                 #group = str_extract(subject, regex_group_id),
                 session = str_extract(Path, "ses-.*(?=/)"),
                 sequence = str_extract(Path, "ses-.*$") %>%
                   str_remove("ses-.*/") %>%
                   str_remove("\\.json")
          ) %>%
          relocate(subject, session, sequence, Path)

        if (file.exists(json_metadata_output_tsv) == 1) {
          readr::write_tsv(results_table, json_metadata_output_tsv,
                           append = TRUE)
        }
        if (file.exists(json_metadata_output_tsv) == 0) {
          readr::write_tsv(results_table, json_metadata_output_tsv,
                           append = FALSE)
        }
      } else {
        print(paste("The file", json[i], "is empty. Please check manually."))
      }
    }
    print("Extracted all json metadata - Success!")
  }
}



# sequence editing and mapping --------------------------------------------
#' The sequence mapper function (1) checks if there is already a 'sequence_map.tsv'. (2) If it exists it will merged with the new sequences from the 'sequence_overview.tsv'. If not a new 'sequence_map.tsv' will be created. (3) Finally a shiny app is started to edit the sequence information manually. All "please edit" fields need to be filled out.
#'
#' @param sequence_overview_file The name of the file, which contains the sequence overview.
#' @param output_name The name of the output file. In general named 'sequence_map.tsv'
#'
#' @return
#' @export
#'
#' @examples
sequence_mapper <- function(sequence_overview_file = "sequence_overview_anon",
                            output_name = "sequence_map"){

  cat("\n\nPrepare data and start sequence_mapper\n\n")

  input_file = paste0(path_output_converter, "/", sequence_overview_file, ".tsv")

  mapper_file = str_replace(input_file, sequence_overview_file, output_name)

  tsv_input <- readr::read_tsv(input_file, show_col_types = FALSE, lazy = FALSE)

  tsv_input_sequences <- tsv_input %>%
    select(sequence) %>%
    unique()

  if(file.exists(mapper_file)){
    tsv_map <- readr::read_tsv(mapper_file, show_col_types = FALSE, lazy = FALSE)%>%
      mutate(relevant = as.character(relevant))

    tsv_difference <- anti_join(tsv_input_sequences, tsv_map, by = "sequence") %>%
      mutate(BIDS_sequence = "please edit (T1w/T2w/etc)",
             BIDS_type = "please edit (anat/dwi/func/etc)",
             relevant = "1") %>%
      select(sequence, BIDS_type, BIDS_sequence, relevant)

    final_df <- full_join(tsv_map, tsv_difference)
  } else {
    sequence_mapper_df <- tsv_input_sequences %>%
      mutate(BIDS_sequence = "please edit (T1w/T2w/etc)",
             BIDS_type = "please edit (anat/dwi/func/etc)",
             relevant = "1") %>%
      select(sequence, BIDS_type, BIDS_sequence, relevant)

    final_df <- sequence_mapper_df
  }
  cat("Writing the dataframe.\n\n")
  print(final_df)
  cat("\n\n")
  readr::write_tsv(final_df, file = mapper_file)

  # if(edit_table == "on"){
  #   editTable(DF = final_df,
  #             outdir = paste0(path_output_converter),
  #             outfilename = output_name)
  # }
  return(final_df)

}


#' Checks sequence map
#'
#' @param sequence_map_file
#'
#' @return
#' @export
#'
#' @examples
check_sequence_map <- function(sequence_map_file = "sequence_map"){

  print("Checking sequence_map.tsv")

  df <- paste0(path_output_converter, "/", sequence_map_file, ".tsv")
  print(df)

  df_import <- readr::read_tsv(df, show_col_types = FALSE, lazy = FALSE)
  print(df_import, n = Inf)

  df_to_edit <- df_import %>%
    filter_all(any_vars(str_detect(., "please edit")))

  while(nrow(df_to_edit) > 0){

    cat("\n\n\n")
    cat("ERROR: Sequence map still contains columns that are not edited.\n")
    cat("Please take care, that every column (that contains 'please edit') is edited manually.\n")
    cat("The following columns need to be edited again. Start the sequence mapper again.\n\n")
    print(df_to_edit, n = Inf)

    cat("\n\n The sequence mapper is started. Please wait...\n\n")

    editTable(DF = df_import,
              outdir = paste0(path_output_converter),
              outfilename = "sequence_map")


    cat("\n\n")

    cat("\n\nChecking again if there are unedited cells.\n\n")

    df_import <- readr::read_tsv(df, show_col_types = FALSE, lazy = FALSE)
    print(df_import, n = Inf)

    df_to_edit <- df_import %>%
      filter_all(any_vars(str_detect(., "please edit")))

    if(nrow(df_to_edit) > 0){
      cat("\n\nError: you still have unchanged cells (containing 'please edit')")
      print(df_to_edit)
      stop("\n\nCode stopped. You still have unedited cells. Restart the 'convert_to_BIDS()' function AND edit the sequences.")
    }



  }
  print("Your sequences look fine.\n\n")

}


# sequence mapper ---------------------------------------------------------

#' Creates the BIDS regular expression
#'
#' @return one regular expression containing the BIDS nomenclature
#' @export
#'
#' @examples
create_BIDS_regex <- function(){
  valid_BIDS_prefixes <- c("^(task-[:alnum:]+_)?",
                           "(acq-[:alnum:]+_)?",
                           "(ce-[:alnum:]+_)?",
                           "(rec-[:alnum:]+_)?",
                           "(dir-[:alnum:]+_)?",
                           "(run-[:digit:]+_)?",
                           "(mod-[:alnum:]+_)?",
                           "(echo-[:digit:]+_)?",
                           "(flip-[:digit:]+_)?",
                           "(inv-[:digit:]+_)?",
                           "(mt-(on|off)_)?",
                           "(part-(mag|phase|real|imag)_)?",
                           "(recording-[:alnum:]+_)?") %>% paste(collapse = "")



  valid_BIDS_sequences <- c(
    ### anatomy https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html#anatomy-imaging-data
    "(T1w",
    "T2w",
    "PDw",
    "T2starw",
    "FLAIR",
    "inplaneT1",
    "inplaneT2",
    "PDT2",
    "UNIT1",
    "angio",
    ### anatomy - phase images
    "T1map",
    "R1map",
    "T2map",
    "R2map",
    "T2starmap",
    "R2starmap",
    "PDmap",
    "MTRmap",
    "MTsat",
    "T1rho",
    "MWFmap",
    "MTVmap",
    "PDT2map",
    "Chimap",
    "TB1map",
    "RB1map",
    "S0map",
    "M0map",
    ### anatomy - file collections https://bids-specification.readthedocs.io/en/stable/99-appendices/10-file-collections.html
    "VFA",
    "IRT1",
    "MP2RAGE",
    "MESE",
    "MEGRE",
    "MTR",
    "MTS",
    "MPM",
    ### diffusion
    "dwi",
    "sbref",
    ### task
    "bold",
    "cbv",
    "phase",
    ### asl
    "asl",
    "m0scan",
    "aslcontext",
    "asllabeling",
    "physio",
    "stim",
    ### fieldmap
    "magnitud(e|e1|e2)",
    "phase(1|2|diff)",
    "fieldmap",
    "epi",
    ### fieldmap - file collection
    "TB1DAM",
    "TB1EPI",
    "TB1AFI",
    "TB1TFL",
    "TB1RFM",
    "TB1SRGE",
    "RB1COR){1}$") %>% paste(collapse = "|")

  valid_BIDS_regex <- paste0(valid_BIDS_prefixes, valid_BIDS_sequences)

  return(valid_BIDS_regex)
}

#' Checks the plausibility of entered BIDS sequences based on regular expressions.
#'
#' @param df
#'
#' @return
#' @export
#'
#' @examples
check_BIDS_plausibility <- function(df){

  valid_BIDS_regex <- create_BIDS_regex()

  df <- df %>%
    mutate(valid = str_detect(BIDS_sequence, valid_BIDS_regex) %>%
             as.numeric(),
           valid = ifelse(str_detect(BIDS_type, "^(anat|dwi|func|fmap|perf)$",
                                     negate = TRUE), yes = 0, no = valid),
           valid = ifelse(str_detect(relevant, "^(0|1)$",
                                     negate = TRUE), yes = 0, no = valid)#,
           #matched = str_extract(BIDS_sequence, valid_BIDS_regex),
           #unmatched = str_remove_all(BIDS_sequence, valid_BIDS_regex)
    )
  return(df)
}

#' Title
#'
#' @param df
#'
#' @return
#' @export
#'
#' @examples
check_BIDS_plausibility2 <- function(df){

  valid_BIDS_regex <- create_BIDS_regex()

  df <- df %>%
    mutate(valid = ifelse(test =
                            str_detect(BIDS_sequence, valid_BIDS_regex) == 1 &
                            str_detect(BIDS_type, "^(anat|dwi|func|fmap|perf)$") == 1 &
                            str_detect(relevant, "^(0|1)$") == 1
                          , yes = "yes", no = "no"))
  return(df)
}


#' Sequence mapper shiny app.
#'
#' @param DF
#' @param outdir
#' @param outfilename
#'
#' @return
#' @export
#'
#' @examples
editTable <- function(DF, outdir=getwd(), outfilename="table"){

  # based on these: https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html#anatomy-imaging-data

  cat("\n\n\nSequence mapper started:...\n\n\n")

  svDialogs::dlg_message("The 'sequence mapper' starts now. Please edit each 'bold' text inside a cell. \n\n Set the BIDS type and BIDS sequence. The rows turn green on valid BIDS types and sequence-IDs. \n\n You can disable the export of irrelevant sequences by changing '1' to '0' in the 'relevant' column. \n\n If you are ready click save and close the app to start the validation and BIDS export.")

  DF <- check_BIDS_plausibility2(DF)

  # print(DF)


  dt_output = function(title, id) {
    fluidRow(column(
      12, p(paste0(title)),
      hr(), DTOutput(id)
    ))
  }

  ui <- shinyUI(fluidPage(theme = shinytheme("readable"),

                          titlePanel("BIDS sequence mapper "),
                          sidebarLayout(
                            sidebarPanel(

                              p("BIDS sequence information from: V1.1.2 (2019-01-10)"),
                              a("BIDS documentation",
                                href = "https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html#anatomy-imaging-data"),

                              br(),
                              h4("Edit your BIDS sequence"),

                              p("T1 weighted images = T1w"),
                              p("T2 weighted images = T2w"),
                              p("Proton density weighted images = PDw"),
                              p("T2star weighted images = T2starw"),
                              p("Fluid attenuated inversion recovery images = FLAIR"),
                              p("BOLD = task-fMRI_bold"),
                              p("BOLD = task-rsfMRI_bold"),
                              p("diffusion weighted images = dwi"),

                              h6("Edit your BIDS sequence type"),
                              p("Select the type (anat/func/dwi/perf/fmap)"),
                              h6("Edit the relevance of the sequence"),
                              p("Only relevant (relevance = 1) sequences are copied to BIDS-specification."),

                              h4("Shiny app information"),
                              helpText("Shiny app based on an example given in the rhandsontable package.",
                                       "Double-click on a cell to edit",
                                       "Change all cells that contain an 'edit here'"),

                              a("The code for this shiny app is adapted from here",
                                href = "http://stla.github.io/stlapblog/posts/shiny_editTable.html"),

                              width = 3

                            ),

                            mainPanel(
                              actionButton("save", "Save"),

                              #br(),
                              dt_output('Please edit the red & bold columns (double-click) and "save". Red indicates non-valid BIDS strings. Green indicates a valid "BIDS_sequence", "BIDS_type" and "relevant" column.', 'x1'),
                              width = 9



                            )
                          )
  ))

  server <- shinyServer(function(input, output) {

    values <- reactiveValues()

    data_reactive <- reactiveVal(DF)



    # DF formatting
    output$x1 <- DT::renderDT({
      DF %>%
        check_BIDS_plausibility2() %>%
        DT::datatable(selection = 'none',
                      # height = 1000,
                      #fill = TRUE,
                      #fillContainer = TRUE,
                  # container = sketch,
                  editable = list(target = 'cell',
                                  disable = list(columns = c(0, 1, 5))),
                  # plugins = "scrollResize",
                  # rownames = FALSE,
                  options = list(pageLength = 80,
                                 scrollX = TRUE,

                                 #scrollResize = TRUE, paging = FALSE, scrollY = "100px", scrollCollapse = TRUE,

                                 dom = "t",
                                 autoWidth = FALSE,
                                 #headerCallback = JS(headerCallback),
                                 initComplete = JS("
                        function(settings, json) {
                          $(this.api().table().header()).css({
                          'font-size': '12px',
                          });
                        }")
                  )
        )%>%
        formatStyle('valid',
                    target = "row",
                    color = 'black',
                    backgroundColor = JS("(/^no$/).test(value) ? 'tomato' : (/^yes$/).test(value) ? 'lightgreen' : ''")
                    #backgroundColor = styleEqual(c('no', 'yes'),
                    #                             c('tomato', 'lightgreen'))
                    )  %>%
        # formatStyle(c("BIDS_sequence", "BIDS_type"),
        #             backgroundColor = 'white') %>%
        formatStyle(c("BIDS_type", "BIDS_sequence", "relevant"),
                    # target = "row",
                    backgroundColor = JS("(/please edit/).test(value) ? 'red' : (/^(anat|dwi|func|fmap|perf)$/).test(value) ? 'lightgreen' : ''"),
                    fontWeight = "bold") %>%
        formatStyle('relevant',
                    #target = "row",
                    backgroundColor = styleEqual(c(0, 1),
                                                 c('grey', 'lightgreen')),
                    fontWeight =  styleEqual(c(0, 1),
                                             c('italics', 'bold')))  %>%
        formatStyle(columns = c(0:5), fontSize = '75%')
    },
    server = TRUE)



    #  update the table, apply the BIDS plausibility check
    proxy <- DT::dataTableProxy("x1")

    observeEvent(input$x1_cell_edit, {
      info <- input$x1_cell_edit

      new_DF <<- DT::editData(data_reactive(), info, proxy, resetPaging = FALSE) %>%
        check_BIDS_plausibility2()

      replaceData(proxy, new_DF, resetPaging = FALSE)
      data_reactive(new_DF)
    })


    ## Save
    observeEvent(input$save, {

      fileType <- "TSV"
      finalDF <- isolate(values[["new_DF"]])
      finalDF <- new_DF

      finalDF <- finalDF %>%
        select(-valid)

      # print(finalDF)

      readr::write_tsv(finalDF, file.path(outdir, sprintf("%s.tsv", outfilename)))

    })


    onStop(function() {
      stopApp("Sequence mapper stopped.")

      cat("Sequence mapper stopped. \n\nValidate 'sequence_map.tsv' for BIDS plausibility. Only sequences marked as 'relevant' are checked. \n\n ")

      bids_unmatched <- file.path(outdir, sprintf("%s.tsv", outfilename)) %>%
        readr::read_tsv(file = ., show_col_types = FALSE) %>%
        check_BIDS_plausibility2(.) %>%
        filter(relevant == 1 & valid == "no")

      if(nrow(bids_unmatched) > 0){
        cat("Possible unplausible BIDS sequence-ID's were found among those that were selected as 'relevant'. Please investigate these:\n\n")
        print(bids_unmatched)
      } else {
        cat("Your BIDS-sequences are valid.\n\n")

      }

      # Sys.sleep(5)

    })

  })





  ## run app
  runApp(list(ui=ui, server=server))
  return(invisible())


}


# validator ---------------------------------------------------------------

#' Open BIDS validator homepage
#'
#' @return
#' @export
#'
#' @examples
start_bids_validator_online <- function(){
  browseURL("https://bids-standard.github.io/bids-validator/")
}


#' Open BIDS validator in DOCKER
#'
#' @param bids_path The path to the BIDS folder, which is the input file to the BIDS validator
#'
#' @return
#' @export
#'
#' @examples
start_bids_validator <- function(bids_path = path_output_bids){

  #if system("docker", show.output.on.console = FALSE) == 127) {
  if (suppressWarnings({system2("docker") == 127})){
    #  | system2("docker") == 127
    browseURL("https://docs.docker.com/desktop/windows/install/")
    cat("Starting the online version of the BIDS-Validator. \n\n")
    start_bids_validator_online()
    cat("Please install DOCKER on your local terminal, if you want the offline version. \n\n")
  } else {
    cat("\n\n Docker seems to be installed locally. Setting up the command and starting Docker. \n\n")
    command <- paste0("docker run --rm -v ", bids_path, ":/data:ro bids/validator /data")

    print(command)

    system(command)
  }


}



# copy to bids ------------------------------------------------------------


#' Copies files, if they don't exist in target
#'
#' @param from A list: File source
#' @param to A list: File destination
#' @param string Which step?
#'
#' @return
#' @export
#'
#' @examples \dontrun{copy_files(path_input, path_output, "Copy files to output.")}
copy_files <- function(from, to, string){
  df <- tibble(from = from,
               to = to)
  # filter(file.exists(to) == 0)
  if(nrow(df) > 0) {
    start_timer <- Sys.time()
    for (i in seq(df$from)) {
      #cat("\014")
      # print(paste("Copied file ", i, " of ", length(from),  " to: ", to[i]))
      # if(file.exists(to[i]) == 0) {
      print_passed_time(i, df$to, start_timer, "Copying2BIDS: ")

      if(file.exists(df$from[i])){
        if(file.exists(df$to[i])){
          print(paste("The file:", df$to[i], "already exists. Skipping."))
          cat("\n")
        } else {
          file.copy(df$from[i], df$to[i], overwrite = FALSE)
        }
      } else {
        print(paste("The file:", df$from[i], "does not exist"))
        cat("\n")
      }

    }
    print(string)
    cat("\n\n")
  } else {print(paste0(string, " already existing - skipped"))}
}

#' Prepares and copies files to BIDS
#'
#' @param tsv_file
#'
#' @return
#' @export
#'
#' @examples
copy2BIDS <- function(sequence_map = "sequence_map",
                      sequence_file = "json_metadata_anon"){
  check_sequence_map()

  # sequence_map = "sequence_map"
  # sequence_file = "json_metadata_anon"

  path = paste0(path_output_converter, "/", sequence_map, ".tsv")
  path_jsons <- paste0(path_output_converter, "/", sequence_file, ".tsv")

  output_file = paste0(path_output_converter, "/",  "copy2bids.tsv")

  tsv_file <- read_tsv(path,
                       show_col_types = FALSE,
                       lazy = FALSE) #%>%
    #select(-total, -possible_sequence)

  file_paths <- read_tsv(path_jsons,
                         show_col_types = FALSE,
                         lazy = FALSE) %>%
    select(Path, subject, session, sequence) %>%
    left_join(tsv_file) %>%
    # filter(relevant == 1) %>%
    rename(path_json = Path) %>%
    mutate(path_nii = str_replace(path_json, "json$", "nii\\.gz"),
           path_bval = ifelse(str_detect(BIDS_type, "dwi"),
                              yes = str_replace(path_json, "json$", "bval"),
                              no = NA),
           path_bvec = ifelse(str_detect(BIDS_type, "dwi"),
                              yes = str_replace(path_json, "json$", "bvec"),
                              no = NA)
    ) %>%
    relocate(starts_with("path")) %>%
    pivot_longer(starts_with("path"),
                 names_to = "file_types",
                 values_to =  "input_file_paths",
                 values_drop_na = TRUE) %>%
    mutate(file_types = str_remove(file_types, "path_"),
           output_file_path = paste0(path_output_bids, "/",
                                     subject, "/",
                                     session, "/",
                                     BIDS_type, "/",
                                     subject, "_",
                                     session, "_",
                                     BIDS_sequence, ".",
                                     file_types) %>%
             str_replace("nii$", "nii\\.gz")
    )
  # checks if NII or NIIGZ files are present.
  file_paths %>%
    mutate(input_exists = file.exists(input_file_paths),
           input_file_paths = ifelse(test = input_exists,
                                     yes = input_file_paths,
                                     no = str_remove(input_file_paths, "\\.gz")),
           output_file_path =  ifelse(test = input_exists,
                                      yes = output_file_path,
                                      no = str_remove(output_file_path, "\\.gz"))
    ) %>%
    select(-input_exists) -> file_paths

  cat("\n\n")
  print("Relevant sequences files (copied2BIDS)")
  cat("\n\n")

  file_paths %>%
    filter(relevant == 1) %>%
    select(sequence) %>%
    dplyr::count() %>%
    print.data.frame()

  cat("\n\n")
  cat("\n\n")
  print("Irrelevant sequences files (skipped)")
  cat("\n\n")

  file_paths %>%
    filter(relevant == 0) %>%
    select(sequence) %>%
    dplyr::count() %>%
    print.data.frame()

  cat("\n\n")
  cat("\n\n")

  file_paths <- file_paths %>%
    filter(relevant == 1)

  # duplicate paths
  duplicate_output_paths <- file_paths %>%
    dplyr::count(output_file_path) %>%
    filter(n > 1)

  if(nrow(duplicate_output_paths) > 1){
    print("WARNING - Duplicates identified")
    cat("\n\n")
    readr::write_tsv(duplicate_output_paths, file = paste0(path_output, "duplicate_paths.tsv"))
    cat("Writing 'duplicate_paths.tsv' to your output folder.")
    print(duplicate_output_paths)
    Sys.sleep(10)
  }

  file_paths %>%
    readr::write_csv(., output_file)

  path_to_folder(file_paths$output_file_path)

  copy_files(from = file_paths$input_file_paths,
             to = file_paths$output_file_path,
             "Copy2BIDS: all relevant files")

  cat("\n\nCopied the relevant files to BIDS.\n\n")
  cat("Adding BIDS metadata\n\n")

  add_BIDS_metadata()
}

#' Deletes temporary files
#'
#' @param path_to_search
#'
#' @return
#' @export
#'
#' @examples
delete_temp_nii_files <- function(path_to_search = path_output_converter_temp){
  cat("\n\n\n Searching for all '.nii' and '.nii.gz' files from the temporary folder: \n\n")
  print(path_to_search)

  files_to_delete <- list.files(path = path_to_search, pattern = "(nii|nii\\.gz)$",
                                recursive = TRUE, full.names = TRUE, all.files = TRUE)

  cat("\n\n The following files will be deleted. Are you sure?\n\n")

  print(files_to_delete)

  delete_nii_switch <- menu(graphics = TRUE,
                            c("No, I want to keep my data.",
                              "Yes, I want to delete the temporary NII data."),
                            title="Do you want to delete temporary files?")

  if(delete_nii_switch == 2){
    delete_nii_switch2 <<- menu(graphics = TRUE,
                                c("No, I want to keep my data.",
                                  "Yes, I want to delete the temporary NII data."),
                                title="Are you REALLY sure?")
    if(delete_nii_switch2 == 2){
      cat("\n\n Deleting the temporary files. \n\n")
      lapply(files_to_delete, file.remove)

    } else {
      cat("\n\n Ok, I will keep these files. \n\n")
    }
  } else {
    cat("\n\n Ok, I will keep these files. \n\n")

  }
}










# bids metadata creation --------------------------------------------------


#' Creates template strings for BIDS
#'
#' @return
#' @export
#'
#' @examples
create_metadata <- function(){

  settings_string <<-'# Path that contains one folder per session, containing all DICOMS in subject folders
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
mri_sequences <- c("T1|T2|DTI|fmr|rest|rs|func|FLAIR|smartbrain|survey|smart|ffe|tse")'

  dataset_description <<- '{
\t"Name": "The BIDS-Direct-ConverteR study",
\t"BIDSVersion": "1.1.0rc4",
\t"License": "This dataset was made available by You. We hope that the users of the data will acknowledge the BIDS-Direct-ConverteR team and the funding by the Federal Ministry of Education and Research, Germany (grants #01ER0816, #01ER1205 and #01ER1506) in any publications.",
\t"Authors":  ["Niklas Wulms", "Sven Eppe", "Benedikt Sundermann", "Klaus Berger", "Heike Minnerup"],
\t"HowToAcknowledge": "Please cite publications in References and Links",
\t"Funding": ["Here comes the fund"],
\t"ReferencesAndLinks": [
\t\t"Teismann, H., Wersching, H., Nagel, M., Arolt, V., Heindel, W., Baune, B. T., … Berger, K. (2014). Establishing the bidirectional relationship between depression and subclinical arteriosclerosis - rationale, design, and characteristics of the BiDirect Study. BMC Psychiatry, 14(1). https://doi.org/10.1186/1471-244X-14-174",
\t\t"Teuber, A., Sundermann, B., Kugel, H., Schwindt, W., Heindel, W., Minnerup, J., … Wersching, H. (2017). MR imaging of the brain in large cohort studies: feasibility report of the population- and patient-based BiDirect study. European Radiology, 27(1), 231–238. https://doi.org/10.1007/s00330-016-4303-9",
\t\t"nwulms, & wulms. (2019, October 2). wulms/BiDirect_BIDS_Converter: Runable script (Version 0.1). Zenodo. http://doi.org/10.5281/zenodo.3469539"
\t],
\t"DatasetDOI": "Add here your DOI"
}'

  participants <<- '{
  "session": {
    "LongName": "session",
    "Description": "Session of study",
    "Units": "Session Name, Ordinal"
  },
  "birthdate": {
    "LongName": "birthdate",
    "Description": "birthdate of the participant - extracted from dicom header",
    "Units": "datetime"
  },
  "acquisitiondate": {
    "LongName": "acquisitiondate",
    "Description": "acquisitiondate of the participant at the mentioned session - extracted from dicom header",
    "Units": "datetime"
  },
    "sex": {
    "LongName": "sex",
    "Description": "sex of the participantas reported by the participant - extracted from dicom header",
    "Levels": {
      "m": "male",
      "f": "female"
    }
  },
    "weight": {
    "LongName": "weight",
    "Description": "weight of the participant as reported by the participant - extracted from dicom header",
    "Levels": {
      "Units": "kg"
    }
  },
  "age": {
    "LongName": "age",
    "Description": "age of the participant - time difference between birthdate and acquisitiondate",
    "Units": "years"
  }
}'

  participants_anon <<- '{
  "session": {
    "LongName": "session",
    "Description": "Session of study",
    "Units": "Session Name, Ordinal"
  }
}'



  README <<-
    "This dataset was acquired at the BiDirect study, Institute for Epidemiology and Social Medicine, University of Muenster, Germany.

Description: BiDirect study neuroimaging data in BIDS format

We hope that all users of the data will acknowledge and refer to the BiDirect project.
Please cite the following references if you use these data:

General Study information:
Teismann, H., Wersching, H., Nagel, M., Arolt, V., Heindel, W., Baune, B. T., … Berger, K. (2014). Establishing the bidirectional relationship between depression and subclinical arteriosclerosis - rationale, design, and characteristics of the BiDirect Study. BMC Psychiatry, 14(1). https://doi.org/10.1186/1471-244X-14-174 \n

Neuroimaging Study information:
Teuber, A., Sundermann, B., Kugel, H., Schwindt, W., Heindel, W., Minnerup, J., … Wersching, H. (2017). MR imaging of the brain in large cohort studies: feasibility report of the population- and patient-based BiDirect study. European Radiology, 27(1), 231–238. https://doi.org/10.1007/s00330-016-4303-9\n

Code used for processing: dicom2nii conversion, file management and BIDS:
nwulms, & wulms. (2019, October 2). wulms/BiDirect_BIDS_Converter: Runable script (Version 0.1). Zenodo. http://doi.org/10.5281/zenodo.3469539

2019-12-04: Initial release, added references.

This dataset can be made available Univ.-Prof. Dr. med. Klaus Berger (mail: bergerk@uni-muenster.de).
The BiDirect Study is funded by the Federal Ministry of Education and Research, Germany (grants #01ER0816, #01ER1205 and #01ER1506)."


  CHANGES <<-
    "1.0.0 2019-12-04
	- initial release
	- BIDS converter working
	- actual version containing all subjects up to 2019-11-18"
}

#' This function creates the required BIDS files 'participants.tsv' and 'participants.json'. The '.tsv' contains the actual data per subject from the 'json_metadata.tsv'. The '.json' contains a description of the extracted variables. The following variables are extracted: subject, session, group, PatientBirthDate, AcquisitionDateTime, Patientsex, PatientWeight.
#'
#' @param tsv_path the path to the 'json_metadata.tsv'
#'
#' @return
#' @export
#'
#' @examples
add_participants_tsv <- function(tsv_path = paste0(path_output_converter, "/identifying_information/json_metadata.tsv")){
  # Select columns from json dataframe, mutate relevant columns

  #tsv_path = paste0(path_output_converter, "/json_metadata.tsv")

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
                      #"group",
                      "PatientBirthDate",
                      "AcquisitionDateTime",
                      "PatientSex",
                      "PatientWeight")
  if(needed_columns[!needed_columns %in% column_names] %>% length() == 0){
    print("Every needed column was found.")
    cat("\n")

    patient_tsv <- df %>%
      select(subject, session, #group,
             PatientBirthDate, AcquisitionDateTime, PatientSex, PatientWeight) %>%
      rename(participant_id = subject,
             #group_id = group,
             birthdate = PatientBirthDate,
             acquisitiondate = AcquisitionDateTime,
             sex = PatientSex,
             weight = PatientWeight) %>%
      mutate(acquisitiondate = as.Date(acquisitiondate),
             age = time_length(difftime(acquisitiondate, birthdate), "years") %>%
               round(digits = 2)) %>%
      unique()

    patient_tsv_anon <- patient_tsv %>%
      select(-birthdate, -acquisitiondate, -sex, -weight, -age)

    # Write participants_anon file
    write_tsv(patient_tsv_anon,
              paste0(path_output_bids, "/participants.tsv"))
    writeLines(participants_anon,
               paste0(path_output_bids, "/participants.json"))

    # write the anonymized ones to
    write_tsv(patient_tsv,
              paste0(path_output_converter_temp_json, "/participants.tsv"))
    writeLines(participants,
               paste0(path_output_converter_temp_json, "/participants.json"))






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
  print(paste("Write following text: ", txt_input))
  print(paste("To this file: ", file_path))
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
create_taskname_metadata <- function(tsv_path = paste0(path_output_converter, "/identifying_information/json_metadata.tsv"),
                                     tsv_map = paste0(path_output_converter, "/sequence_map.tsv")){
  taskname <- tsv_path %>%
    readr::read_tsv(show_col_types = FALSE, lazy = FALSE) %>% names()

  if("RepetitionTime" %in% taskname){
    print(paste("Column 'RepetitionTime found. Everything is fine."))

    taskname_df <- tsv_path %>%
      readr::read_tsv(show_col_types = FALSE, lazy = FALSE) %>%
      select(sequence, RepetitionTime) %>% unique()

    task_df <- tsv_map %>%
      readr::read_tsv(show_col_types = FALSE, lazy = FALSE) %>%
      select(-relevant) %>%
      filter(BIDS_type == "func")

    if(nrow(task_df) > 0){
      task_df2 <- task_df %>%
        left_join(taskname_df) %>%
        unique() %>%
        mutate(string = paste0('{\n\t"TaskName": "',
                               BIDS_sequence,
                               '",\n\t"RepetitionTime": ',
                               RepetitionTime, '\n}'),
               filename = paste0(path_output_bids, "/", BIDS_sequence, ".json"))

      print(task_df2)

      for (i in 1:nrow(task_df2)){
        write_metadata_bids(task_df2$string[i],
                            task_df2$filename[i])
      }
    } else {
      print("No functional sequences found. Skipping.")
    }
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

  create_metadata()
  add_participants_tsv()
  # add CHANGES, README, dataset_description

  write_metadata_bids(CHANGES, paste0(path_output_bids, "/CHANGES"))
  write_metadata_bids(README, paste0(path_output_bids, "/README"))
  write_metadata_bids(dataset_description, paste0(path_output_bids, "/dataset_description.json"))



  create_taskname_metadata()

  print("The files were added to your /sourcedata folder. You can edit CHANGES and README manually in the folder with a text editor. Please go to http://bids-standard.github.io/bids-validator/ and check, that your dataset is valid. If the NIfTI Headers produce error messages in the validator select 'ignore NIfTI Headers'.")

}


# create dashboards -------------------------------------------------------


#' Creates the internal dashboard. This one contains sensitive participant information like age, sex and ID.
#'
#' @param rmd_file The rmd file to render
#' @param converter_path The path to the converter, which contains the bids files
#'
#' @return
#' @export
#'
#' @examples
create_dashboard <- function(rmd_file = system.file("rmd", "bids_dashboard.Rmd", package = "bidsconvertr"),
                             converter_path = path_output_converter){

  output_dir = paste0(converter_path, "/dashboard")
  bids_path <- paste0(converter_path, "/bids/sourcedata")

  # read from paths
  dataset_description <- paste0(bids_path, "/dataset_description.json") %>% jsonlite::read_json(.)
  study <- dataset_description$Name


  path_to_folder(output_dir)
  rmarkdown::render(rmd_file,
                    output_dir = output_dir,
                    params=list(study=study,
                                converter_path = converter_path)
  )

}


#' Starts the BiDirect BIDS viewer
#'
#' @param shiny_app_path Path to the viewer RMD file
#' @param bids_directory Directory of the images
#'
#' @return
#' @export
#'
#' @examples
run_shiny_BIDS <- function(bids_directory = shinyDirectoryInput::choose.dir(caption = "Please select the BIDS folder."),
                           shiny_app_path = system.file("rmd", "bids_viewer.Rmd", package = "bidsconvertr")
){

  print(paste("Shiny app path:", shiny_app_path))

  print(paste("BIDS directory:", bids_directory))


  image_df <- tibble(nii_files = list.files(path = bids_directory,
                                            pattern = "\\.nii\\.gz|\\.nii",
                                            recursive = TRUE,
                                            full.names = TRUE),
                     short_string = str_remove(nii_files, bids_directory) %>%
                       str_remove("^/")) %>%
    separate(short_string, into = c("subject", "session", "type", "sequence"), sep = "/") %>%
    mutate(sequence = str_remove_all(sequence, paste0(subject, "_")) %>%
             str_remove(paste0(session, "_")) %>%
             str_remove("\\.nii\\.gz|\\.nii")
    )

  print(image_df)
  #stop(image_df)

  if(nrow(image_df) == 0){stop("Error: No .nii.gz or .nii files found.")}

  rmarkdown::run(file = shiny_app_path,
                 auto_reload = FALSE,
                 shiny_args = list(launch.browser = TRUE),
                 render_args = list(params = list(df = image_df)
                 ))
}









# dashboard functions -----------------------------------------------------
datatable_setting <- function(df) {
  DT::datatable(
    df,
    extensions = c('Scroller'),
    options = list(
      search = list(regex = TRUE),
      searchHighlight = TRUE,
      pageLength = 25,
      dom = 'Bfrtip',
      deferRender = TRUE,
      scrollY = 200,
      scroller = TRUE
    ),
    filter = 'top'
  )
}


df_select_n <- function(df) {
  df <- df %>%
    select(session, BIDS_type, BIDS_sequence, relevant) %>%
    group_by(across(everything())) %>%
    dplyr::count() %>%
    ungroup()
  # spread(. ,session, value = n)
  return(df)
}

df_select_n_group <- function(df) {
  df <- df %>%
    select(session, BIDS_type, BIDS_sequence, group, PatientSex, relevant) %>%
    filter(relevant == 1) %>%
    group_by(across(everything())) %>%
    dplyr::count() %>%
    ungroup()
  return(df)
}

df_select_patient_info <- function(df){
  df2 <- df %>% mutate(group = "all")
  df <- df %>%
    rbind(df2) %>%
    select(subject, session, group, PatientSex, PatientWeight, PatientBirthDate, AcquisitionDateTime) %>%
    mutate(AcquisitionDateTime = as.Date(AcquisitionDateTime),
           Age = time_length(difftime(AcquisitionDateTime, PatientBirthDate), "years") %>% round(digits = 2)) %>%
    unique()
  return(df)
}


plot_bar <- function(df){
  p_relevant <- df %>%
    filter(relevant == 1) %>%
    # filter(BIDS_type == "anat") %>%
    ggplot(aes(x = BIDS_sequence, y = freq, fill = session)) +
    geom_bar(position="dodge", stat = "identity") +
    facet_grid(. ~ BIDS_type, scales = "free_x", space = "free_x") +
    theme(legend.position="top",
          axis.text.x = element_text(angle = 45, hjust=1)) +
    xlab("")+
    ggtitle("Relevant Sequences") +
    ylab("Number of scans")

  df_irrelevant <- df %>%
    filter(relevant == 0)

  if(nrow(df_irrelevant > 0)){
    p_irrelevant <- df %>%
      filter(relevant == 0) %>%
      ggplot(aes(x = BIDS_sequence, y =freq, fill = session)) +
      geom_bar(position="dodge", stat = "identity") +
      facet_grid(. ~ BIDS_type, scales = "free_x", space = "free_x") +
      theme(legend.position="none") +
      xlab("")+
      ylab("Number of scans") +
      ggtitle("Irrelevant Sequences")

    p_relevant / p_irrelevant +
      plot_annotation(
        title = 'Sequence overview'
      ) &
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust=1),
            legend.position="none")
  } else {
    p_relevant +
      ggtitle("Sequence Overview") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust=1),
            legend.position="none")
  }


  #ggplotly(p) %>% layout(margin = list(l = 100, r = 20, b = 50, t = 100))
}

calculate_comp_subjects <- function(df, sessions) {
  df <- df %>%
    select(subject, session, group, BIDS_sequence, relevant) %>%
    filter(relevant == 1) %>%
    select(-relevant) %>%
    group_by(across(everything())) %>%
    dplyr::count() %>%
    ungroup %>%
    spread(session, freq) %>%
    mutate("RatioCompleteSurveys" = rowSums(select(., contains("ses-")), na.rm = TRUE)/sessions) %>%
    group_by(subject) %>%
    mutate("RatioCompleteSubjects" = mean(RatioCompleteSurveys)) %>%
    ungroup()
  return(df)
}


show_settings <- function(df) {
  df <- df %>%
    select(-filename,
           -subject,
           -session,
           -level,
           -input_json,
           -BIDS_json,
           -sequence,
           -BIDS_sequence_ID,
           -SeriesDescription,
           -ProtocolName,
           -InstitutionalDepartmentName,
           -InstitutionName,
           -Manufacturer,
           -ManufacturersModelName,
           -MagneticFieldStrength,
           -Modality,
           -DeviceSerialNumber,
           -SoftwareVersions,
           -StationName) %>%
    select(-AcquisitionNumber,
           -ImageOrientationPatientDICOM,
           -ImageBIDS_type,
           -ProcedureStepDescription,
           #   -AccessionNumber,
           -StudyID,
           -StudyInstanceUID,
           -SeriesNumber,
           -SeriesInstanceUID
    ) %>%
    select(
      -AcquisitionDateTime,
      -AcquisitionTime,
      -PatientBirthDate,
      -PatientID,
      -PatientSex,
      -PatientName,
      -PatientWeight,
      #      -PhilipsRescaleSlope
    ) %>%
    mutate(across(where(is.numeric), round, digits = 2)) %>%
    group_by(across(everything())) %>%
    dplyr::count() %>%
    ungroup() %>%
    select(BIDS_sequence, BIDS_type, n, group_BIDS, relevant, everything())
  return(df)
}


