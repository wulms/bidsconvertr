# Core function ----------------------------------------------------------

#' The core function, which converts the DICOM to NII, extracts the JSON information, opens the sequence mapper and converts the data to BIDS.
#'
#' @param user_settings_file The path to the user settings file from the "create_user_settungs()" function.
#' @param sequence_table "on" or "off" - turns the sequence mapper shiny app on or off.
#'
#' @return
#' @export
#'
#' @examples
convert_to_BIDS <- function(sequence_table = "off"){


  options(svDialogs.rstudio = FALSE)
  select_user_settings_file()
  cat("\n\n\n============ Preparing environment ===============\n\n\n")
  prepare_environment(settings_file)


  cat("\n\n\n============ Workflow start? ===============\n\n\n")

  break_workflow <- menu(choices = c("Yes: Start the workflow.",
                                     "Stop the workflow."),
                         graphics = TRUE,
                         title = "Does the diagnostic output in the console fit to your settings?")

  if (break_workflow == 2) {
    stop("User selected to stop the workflow. Please restart the configurator with 'convert_to_BIDS()'.")
  }


  cat("\n\n\n============ Install dcm2niix ===============\n\n\n")
  install_dcm2niix()
  cat("\n\n\n============ dcm2niix conversion ===============\n\n\n")

  # dcm2niix - niftis
  dcm2nii_converter_anon()

  # dcm2niix - jsons
  dcm2nii_converter_json()

  cat("\n\n\n============ Extracting metadata information ===============\n\n\n")
  # read all metadata from JSON files

  read_json_headers(json_path = path_output_converter_temp_json, suffix = "")

  read_json_headers(json_path = path_output_converter_temp_nii, suffix = "_anon")

  cat("\n\n\n============ Sequence Mapper ===============\n\n\n")
  sequence_mapper()
  check_sequence_map()

  cat("\n\n\n============ Copy files to BIDS ===============\n\n\n")
  copy2BIDS()

  cat("\n\n\n============ Potentially identifying data statement ===============\n\n\n")
  svDialogs::dlg_message(c("DATA PRIVACY NOTE:",
                         "ONLY the METADATA contained within the BIDS folder is free of potentially identifiable information.\n",
                         "Please ensure full anonymization according to local data protection regulations. \n",
                         "E.g., defacing for images or pseudonymisation of subject-IDs in the filenames."))

  cat("\n\n\n============ start BIDS validator ===============\n\n\n")
  start_bids_validator()
  # cat("\n\n\n============ Create Dashboard ===============\n\n\n")
  # create_dashboard()

  cat("\n\n\n============ Starting Shiny BIDS ===============\n\n\n")
  run_shiny_BIDS(bids_directory = path_output_bids)

  cat("\n\n\n============ Deletion of temporary files ===============\n\n\n")
  cat("Only recommended, when:")
  cat("\n\n (1) Your data acquisition is done.")
  cat("\n (2) ALL data is converted.")
  cat("\n (3) Your dataset is validated with the BIDS-Validator.\n\n")

  delete_temp_nii_files()
  rm(list = ls(envir = .GlobalEnv), envir = .GlobalEnv)

}
