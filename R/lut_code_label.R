#' Geographic Level Codes
#'
#' A tibble containing example codes for various geographic levels used in French administrative data.
#' Each row represents a different type of geographic code (e.g., region, department), and each column
#' provides a list of character vectors (length 6) with example codes for that level.
#'
#' @format A tibble with 9 rows and 2 columns:
#' \describe{
#'   \item{name_geo_level}{Character. The name of the geographic level (e.g., "arr_code", "dep_code").}
#'   \item{data}{List-column of named character vectors representing the labels/codes relation for each geographic level.}
#' }
#' @examples
#' lut_code_label
"lut_code_label"
