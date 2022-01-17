# install dcm2niix
#' installs dcm2niix from Chris Rordens Github Repository, also depending on OS
#'
#' @param dcm2niix_release The version number of dcm2niix that you need. E.g. "v1.0.20211006".
#'
#' @examples install_dcm2niix()
#' @export
install_dcm2niix <- function(dcm2niix_release = "v1.0.20211006") {

  dcm2niix_release_path <- paste0("https://github.com/rordenlab/dcm2niix/releases/download/",
                                  dcm2niix_release, "/dcm2niix_")

  if (length(list.files(path = path_output,
                        pattern = "dcm2niix")) == 0) {
    os <- Sys.info()["sysname"]
    if (os == "Darwin") {
      message("Identified MacOs. Not officially supported!")
      dcm2niix <- paste0(dcm2niix_release_path, "mac.zip")
    }
    else if (os == "Linux") {
      message("Identified Linux.")
      dcm2niix <- paste0(dcm2niix_release_path, "lnx.zip")
    }
    else if (os == "Windows") {
      message("Identified windows.")
      dcm2niix <-
        paste0(dcm2niix_release_path, "win.zip")

    } else {
      print(Sys.info()["sysname"])
      stop("OS not identified. Please issue the sysname on Github.")
    }




    print(paste("The dcm2niix files are at the following location: ", dcm2niix_path))

    download.file(dcm2niix, paste0(dcm2niix_path, ".zip"))
    unzip(zipfile = paste0(dcm2niix_path, ".zip"),
          exdir = normalizePath(path_output))
    file.remove(paste0(dcm2niix_path, ".zip"))
    if (os == "Linux") {
      Sys.chmod(dcm2niix_path, mode = "0777")
    }
  }
}
