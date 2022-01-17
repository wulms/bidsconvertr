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
                            output_name = "sequence_map",
                            edit_table = "off"){

  input_file = paste0(path_output_converter, "/", sequence_overview_file, ".tsv")

  mapper_file = str_replace(input_file, sequence_overview_file, output_name)

  tsv_input <- readr::read_tsv(input_file, show_col_types = FALSE, lazy = FALSE)

  tsv_input_sequences <- tsv_input %>%
    select(sequence)

  if(file.exists(mapper_file)){
    tsv_map <- readr::read_tsv(mapper_file, show_col_types = FALSE, lazy = FALSE)%>%
      mutate(relevant = as.character(relevant))

    tsv_difference <- anti_join(tsv_map, tsv_input_sequences) %>%
      mutate(BIDS_sequence = "please edit (T1w/T2/etc)",
             BIDS_type = "please edit (anat/dwi/func/etc)",
             relevant = "please edit (0 = no, 1 = yes)") %>%
      select(sequence, total, possible_sequence, BIDS_sequence, BIDS_type, relevant)

    final_df <- full_join(tsv_map, tsv_difference)
  } else {
    sequence_mapper_df <- tsv_input %>%
      mutate(BIDS_sequence = "please edit (T1w/T2/etc)",
             BIDS_type = "please edit (anat/dwi/func/etc)",
             relevant = "please edit (0 = no, 1 = yes)") %>%
      select(sequence, total, possible_sequence, BIDS_sequence, BIDS_type, relevant)

    final_df <- sequence_mapper_df
  }

  readr::write_tsv(final_df, file = mapper_file)

  if(edit_table == "on"){
    editTable(DF = final_df,
              outdir = paste0(path_output_converter),
              outfilename = output_name)
  }
  return(final_df)

}


check_sequence_map <- function(sequence_map_file = "sequence_map"){

  df <- paste0(path_output_converter, "/", sequence_map_file, ".tsv")
  print(df)

  df_import <- readr::read_tsv(df, show_col_types = FALSE, lazy = FALSE)
  print(df_import, n = Inf)

  df_to_edit <- df_import %>%
    filter_all(any_vars(str_detect(., "please edit")))

  if(nrow(df_to_edit) > 0){
    cat("\n\n\n")
    print("ERROR: Sequence map still contains columns that are not edited.")
    print("Please take care, that every column (that contains 'please edit') is edited manually.")
    print("The following columns need to be edited again. Start the sequence mapper again.")
    print(df_to_edit, n = Inf)

    print("The sequence mapper is started in 10 seconds. Please wait")
    Sys.sleep(10)

    try(editTable(DF = df_import,
                  outdir = paste0(path_output_converter),
                  outfilename = sequence_map_file))

    check_sequence_map()

  } else {
    print("Your sequences look fine.")
  }

}
