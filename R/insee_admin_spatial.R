#' Spatial dataset (sfc_multipolygon) at the IRIS granularity from IGN/INSEE COUTOURS-IRIS file for millesime 2022
#'
#' Spatial dataset (sfc_multipolygon) at the IRIS granularity from IGN/INSEE COUTOURS-IRIS file for millesime 2022.
#' 5 semantic columns + geometry for `metropole` with geodesic representation LAMB93.
#' Attention le fichier contours IRIS est donné dans le système Lambert 93,
#' mais les fichiers de découpage administratif sont donnés en WGS-84 !!!
#' @format Data frame with 6 columns and 48580 rows
#' \describe{
#'   \item{iris_code}{Code IRIS du lieu de résidence, 9 character}
#'   \item{iris_lib}{Nom de l'IRIS}
#'   \item{iris_typ}{Type de l'IRIS, 1 character}
#'   \item{com_code}{Code commune (concaténation DEPCOM) du lieu de résidence, 5 character}
#'   \item{com_lib}{Nom de la commune de résidence}
#'   \item{geometry}{Géométrie de l'IRIS, MULTIPOLYGON}
#' }
#' @examples
#'   insee_admin_spatial
#' @source <https://data.geopf.fr/telechargement/download/CONTOURS-IRIS/CONTOURS-IRIS_2-1__SHP__FRA_2022-01-01/CONTOURS-IRIS_2-1__SHP__FRA_2022-01-01.7z>
"insee_admin_spatial"
