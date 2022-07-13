






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

  select_user_settings_file()
  cat("\n\n\n============ Preparing environment ===============\n\n\n")
  prepare_environment(settings_file)
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

  cat("\n\n\n============ start BIDS validator ===============\n\n\n")
  start_bids_validator_docker()
  Sys.sleep(10)
  cat("\n\n\n============ Create Dashboard ===============\n\n\n")
  # create_dashboard()

  cat("\n\n\n============ Starting Shiny BIDS ===============\n\n\n")
  run_shiny_BIDS()

  cat("\n\n\n============ Deletion of temporary files ===============\n\n\n")
  cat("Only recommended, when:")
  cat("\n\n (1) Your data acquisition is done.")
  cat("\n (2) ALL data is converted.")
  cat("\n (3) Your dataset is validated with the BIDS-Validator.\n\n")

  delete_temp_nii_files()


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
                                       c("Yes, I want to delete the temporary NII data.",
                                         "No, I want to keep my data."),
                                       title="Are you sure to delete the listed files?")

  if(delete_nii_switch == 1){
    delete_nii_switch2 <<- menu(graphics = TRUE,
                                c("Yes, I want to delete the temporary NII data.",
                                  "No, I want to keep my data."),
                                title="Are you REALLY sure?")
    if(delete_nii_switch2 == 1){
      cat("\n\n Deleting the temporary files. \n\n")
      lapply(files_to_delete, file.remove)

      } else {
      cat("\n\n Ok, I will keep these files. \n\n")
      }
  } else {
    cat("\n\n Ok, I will keep these files. \n\n")

    }
  }




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
