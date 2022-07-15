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
start_bids_validator <- function(bids_path = path_output_bids){

  #if system("docker", show.output.on.console = FALSE) == 127) {
  if (suppressWarnings({system2("docker") == 127})){
    #  | system2("docker") == 127
    browseURL("https://docs.docker.com/desktop/windows/install/")
    cat("Starting the online version of the BIDS-Validator. \n\n")
    start_bids_validator_online()
    cat("Please install DOCKER on your local terminal, if you want the offline version. \n\n")
  } else {
    cat("\n\n Docker seems to be installed locally. Setting up the command and starting Docker. \n\n")
    command <- paste0("docker run --rm -v ", bids_path, ":/data:ro bids/validator /data")

    print(command)

    system(command)
  }


}
