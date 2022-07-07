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
start_bids_validator_docker <- function(bids_path = user_output_dir){

  if (system("docker", show.output.on.console = FALSE) == 127) {
    #  | system2("docker") == 127
    browseURL("https://docs.docker.com/desktop/windows/install/")
    stop("Please install DOCKER")
  }
  cat("\014")

  command <- paste0("docker run --rm -v ", bids_path, ":/data:ro bids/validator /data")

  print(command)

  system(command)
}
