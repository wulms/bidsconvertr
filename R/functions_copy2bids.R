# copy2BIDS ---------------------------------------------------------------


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
      cat("\014")
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
                       lazy = FALSE) %>%
    select(-total, -possible_sequence)

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
    count() %>%
    print.data.frame()

  cat("\n\n")
  cat("\n\n")
  print("Irrelevant sequences files (skipped)")
  cat("\n\n")

  file_paths %>%
    filter(relevant == 0) %>%
    select(sequence) %>%
    count() %>%
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
    print(duplicate_output_paths)
    Sys.sleep(10)
  }

  file_paths %>%
    readr::write_csv(., output_file)

  path_to_folder(file_paths$output_file_path)

  copy_files(from = file_paths$input_file_paths,
             to = file_paths$output_file_path,
             "Copy2BIDS: all relevant files")

  add_BIDS_metadata()
}






