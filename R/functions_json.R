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

  print("Listing up the json sidecar files")
  json_files <- list.files(input_path, pattern = "json$",
                           recursive = TRUE, full.names = TRUE)

  json_files <- str_replace(json_files, "//", "/")

  json_df <- tibble(json_path = json_files) %>%
    mutate(short_strings = str_extract(json_path,
                                       "(?<=temp/(nii|json_sensitive)/)sub-.*$")) %>%
    rowwise() %>%
    mutate(possible_sequence = paste(possible_sequence, collapse=", ")) %>%
    ungroup()  %>%
    separate(short_strings, c("subject", "session", "sequence"), "/") %>%
    mutate(sequence = str_remove(sequence, "\\.json"),
           possible_sequence = str_extract_all(sequence,
                                               regex(mri_sequences, ignore_case = TRUE),
                                               simplify = FALSE) %>%
             str_replace(pattern = regex("(survey|smartbrain|smart)",
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
    count() %>%
    pivot_wider(names_from = session, values_from = freq) %>%
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

  readr::write_tsv(json_overview,
                   file = paste0(path_output_converter, "/sequence_overview", output_suffix, ".tsv"),
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
  print("Extracting the headers of the json sidecars.")
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
  print("Extracted all json headers - Success!")
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

  json_metadata_output_tsv <- paste0(path_output_converter, "/json_metadata", suffix, ".tsv")

  json_files <- list_json_files(json_path, output_suffix = suffix)
  json = json_files$json_path


  empty_df <- get_json_headers(json)

  if (file.exists(json_metadata_output_tsv) == 1) {
    print("Comparing the json metadata tsvs")
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

    start_timer <- Sys.time()

    for (i in 1:length(json)) {
      if(i %% 10000 == 0){
        print_passed_time(i, json, start_timer, "Extracting metadata of Headers: ")
      }
      if(file.info(json[i])$size > 0) {
        result_new <- rjson::fromJSON(file = json[i], simplify = TRUE) %>%
          lapply(paste, collapse = ", ") %>%
          bind_rows() %>%
          mutate(Path = json[i])
        result_new <- merge(empty_df, result_new, all = TRUE, sort = F)
        result_new <- result_new[sort(names(result_new))]

        results_table <- result_new %>%
          mutate(subject = str_extract(Path, paste0("sub-", regex_subject_id)),
                 group = str_extract(subject, regex_group_id),
                 session = str_extract(Path, "ses-.*(?=/)"),
                 sequence = str_extract(Path, "ses-.*$") %>%
                   str_remove("ses-.*/") %>%
                   str_remove("\\.json")
          ) %>%
          relocate(subject, group, session, sequence, Path)

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
