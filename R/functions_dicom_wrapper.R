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
