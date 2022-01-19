
#' Creates the internal dashboard. This one contains sensitive participant information like age, sex and ID.
#'
#' @param rmd_file The rmd file to render
#' @param converter_path The path to the converter, which contains the bids files
#'
#' @return
#' @export
#'
#' @examples
create_dashboard_internal <- function(rmd_file = system.file("rmd", "bids_dashboard.Rmd", package = "bidsconvertr"),
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
run_shiny_BIDS <- function(bids_directory = path_output_bids,
                           shiny_app_path = system.file("rmd", "bids_viewer.Rmd", package = "bidsconvertr")
                           ){

  print(paste("Shiny app path:", shiny_app_path))

  print(paste("BIDS directory:", bids_directory))


  image_df <- tibble(nii_files = list.files(path = bids_directory,
                                            pattern = "\\.nii\\.gz|\\.nii",
                                            recursive = TRUE,
                                            full.names = TRUE),
                     short_string = str_extract(nii_files, "(?<=sourcedata/)sub-.*$")) %>%
    separate(short_string, into = c("subject", "session", "type", "sequence"), sep = "/") %>%
    mutate(sequence = str_remove_all(sequence, paste0(subject, "_")) %>%
             str_remove(paste0(session, "_")) %>%
             str_remove("\\.nii\\.gz|\\.nii")
    )

  if(nrow(image_df) == 0){stop("Error: No .nii.gz or .nii files found.")}

  rmarkdown::run(file = shiny_app_path,
                 auto_reload = FALSE,
                 shiny_args = list(launch.browser = TRUE),
                 render_args = list(params = list(df = image_df)
                                    ))
}




