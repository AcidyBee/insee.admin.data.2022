#' Get file path to the extdata directory
#'
#' INSEE files comes bundled with `.csv` or `.txt` files in their own directory
#' nested in `inst/extdata`. This function make them easy to access.
#'
# #' The data in each file is the same as \code{\link{CONTOURS-IRIS.shp}} table and its kind.
#' The function is adapted from https://github.com/allisonhorst/palmerpenguins/blob/main/R/penguins.R
#'
#' @param path Name of file in quotes with extension;
#' `"decoupage-admin/reference_IRIS_geo2022.xlsx"` and `"IGN/CONTOURS-IRIS/CONTOURS-IRIS.shp"` will work.
#' If `NULL`, the example directory or files will be listed.
#' @export
#' @examples
#' path_to_extdata()
#' path_to_extdata("IGN/CONTOURS-IRIS")
#' @source This function is adapted from `readxl::readxl_example()`.
path_to_extdata <- function(path = NULL) {
  if (is.null(path)) {
    dir(system.file("extdata", package = "insee.admin.data.2022"))
  } else {
    system.file("extdata", path, package = "insee.admin.data.2022", mustWork = TRUE)
  }
}
