#' Dataset of the administrative hierarchy for France, from the IRIS granularity to the REGION for millesime 2022
#'
#' Dataset relating the various levels of the administrative hierarchy for France,
#' starting from the IRIS granularity to the REGION for millesime 2022.
#' The dataset includes all geographic levels for France including territories appart from metropole.
#' @format Data frame with 25 columns and 49397 rows
#' \describe{
#'   \item{iris_code}{Code IRIS du lieu de résidence, 9 character}
#'   \item{iris_label}{Nom de l'IRIS}
#'   \item{iris_type}{Type de l'IRIS, 1 character}
#'   \item{grd_quart}{Code Grand Quatier, 7 character}
#'   \item{com_arm_code}{Code commune ou arrt municipal du lieu de résidence, 5 character}
#'   \item{com_arm_label}{Nom de la commune ou arrt municipa de résidence}
#'   \item{dep_code}{Code département, 2 character}
#'   \item{reg_code}{Code région, 2 character}
#'   \item{cv_code}{Code canton ou ville, 4 character}
#'   \item{com_code}{Code commune (concaténation DEPCOM) du lieu de résidence, 5 character}
#'   \item{com_label}{Nom de la commune de résidence}
#'   \item{arm_code}{Code arrt municipal du lieu de résidence, 5 character}
#'   \item{arm_label}{Nom de arrt municipal de résidence}
#'   \item{arr_code}{Code arrondissement, 3 character}
#'   \item{epci}{Code EPCI, 9 character}
#'   \item{nature_epci}{nature EPCI, 2 character}
#'   \item{ze2020}{ze2020, 4 character}
#'   \item{uu2020}{uu2020, 5 character}
#'   \item{tuu_2017}{tuu_2017, 1 character}
#'   \item{tduu2017}{tduu2017, 2 character}
#'   \item{aav2020}{aav2020, 3 character}
#'   \item{taav2017}{taav2017, 1 character}
#'   \item{tdaav2017}{tdaav2017, 2 character}
#'   \item{cateaav2020}{cateaav2020, 2 character}
#'   \item{bv2012}{bv2012, 5 character}
#' }
#' @examples
#'   insee_admin_decoupage
#' @source {IRIS}<https://www.insee.fr/fr/information/7708995> {decoupage supracommunal}<https://www.insee.fr/fr/information/7671844>
"insee_admin_decoupage"
