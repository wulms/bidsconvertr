
#' Prints progress of files in list of files
#'
#' @param item item in for loop
#' @param list_of_files list, where the item comes from
#' @param start Sys.time() of start, used to calculate the time difference
#' @param string String, to describe the function of the loop

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





#' The core function, which converts the DICOM to NII, extracts the JSON information, opens the sequence mapper and converts the data to BIDS.
#'
#' @param user_settings_file The path to the user settings file from the "create_user_settungs()" function.
#' @param sequence_table "on" or "off" - turns the sequence mapper shiny app on or off.
#'
#' @return
#' @export
#'
#' @examples
convert_to_BIDS <- function(user_settings_file = "",
                            sequence_table = "off"){

  # dcm2niix - niftis
  dcm2nii_converter_anon()

  # dcm2niix - jsons
  dcm2nii_converter_json()

  # read all metadata from JSON files
  read_json_headers(json_path = path_output_converter_temp_json, suffix = "")

  read_json_headers(json_path = path_output_converter_temp_nii, suffix = "_anon")


  sequence_mapper(edit_table = sequence_table)

  check_sequence_map()

  copy2BIDS()

  create_dashboard_internal()

}
