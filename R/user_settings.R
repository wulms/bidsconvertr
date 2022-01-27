#' Creates a user setting template file at working directory or custom folder. This file is required for all processing.
#'
#' @param folder Set the folder to save your file.
#'
#' @return The path to the folder
#' @export
#'
#' @examples
create_user_settings <- function(folder = getwd()){

  print("Creating the user settings file.")
  settings_string <-'# Path that contains one folder per session, containing all DICOMS in subject folders
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

  if(!dir.exists(folder)){
    path_to_folder(folder)
  }

  path <- paste0(folder, "/user_settings.R")


  if(!file.exists(path)){
    print(paste("The file was created in this folder:", folder))
    writeLines(settings_string, path)
    print("The file will be opened in 5 seconds. Please edit the file to your needs.")
    Sys.sleep(5)
    file.edit(path)
  } else {
    print(paste("The file already exists:", path))
  }
  settings_file <<- path
  return(path)
}


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
  path_output_converter <<- paste0(input_path, "/bids_bidirect_converter")

  # user files
  path_output_user <<- paste0(path_output_converter, "/user")
  path_output_user_templates <<- paste0(path_output_user, "/templates")
  path_output_user_diagnostics <<- paste0(path_output_user, "/diagnostics")
  path_output_user_settings <<- paste0(path_output_user, "/settings")

  # converter outputs
  path_output_converter_temp <<- paste0(path_output_converter, "/temp")
  path_output_converter_temp_nii <<- paste0(path_output_converter_temp, "/nii")
  path_output_converter_temp_json <<- paste0(path_output_converter_temp, "/json_sensitive")

  # BIDS output
  path_output_bids <<- paste0(path_output_converter, "/bids/sourcedata")

  # Dashboards
  path_output_user <<- paste0(path_output_converter, "/dashboard")

}

#' Prepares th environment with custom variables based on the user settings file.
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

  # source("new_version/environment.R")

  # indexing all folders
  input_dicom_folders <<- list_dicom_folders(path_input_dicom)
  return(input_dicom_folders)
}
