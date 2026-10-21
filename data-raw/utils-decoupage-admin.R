## extracted from spatial.INSEE to prepare the data: 2025-03-29
# ## Extrait les codes IRIS qui peuvent être trouvés dans 2 communes distinctes
# decoupage_iris_2022 %>%
#   dplyr::distinct(CODE_IRIS, DEPCOM) %>%
#   dplyr::group_by(CODE_IRIS) %>%
#   dplyr::filter(dplyr::n() > 1)

# Création de la fonction
## on recherche si un même enfant peut avoir plus d'un unique parent
#' Extract rows corresponding to a non-hierarchical relationship
#'
#' Extract rows corresponding to a non-hierarchical relationship between two variables.
#' @param data A dataset with the hierarchy between variables to check.
#' @param parent A column with a role of parent compared to the other variable.
#' @param child A column with a role of child compared to the other variable.
#'
#' @return The same dataset as the input keeping only rows not diplaying the expected hierarchical relationship between parent and child columns.
#' @export
#'
# #' @examples
keep_non_hierarchic_rows <- function(data, parent, child) {
  data %>%
    dplyr::distinct({{ parent }}, {{ child }}) %>%
    dplyr::group_by({{ child }}) %>%
    dplyr::filter(dplyr::n() > 1)
}
## note:
## - le nombre d'éléments distinct d'une classe peut nous permettre de vérifier l'ordre de la hiérarchie, cependant
## - il est possible d'avoir plus de parents que d'enfants ET une relation hiérarchique, si par exemple il y a des NA pour les enfants
## TODO: imaginer un contrôle d'erreur adapté...


## Création de la fonction inverse
#' Discard rows corresponding to a non-hierarchical relationship
#'
#' Discard rows corresponding to a non-hierarchical relationship between two variables.
#' @param data A dataset with the hierarchy between variables to check.
#' @param parent A column with a role of parent compared to the other variable.
#' @param child A column with a role of child compared to the other variable.
#'
#' @return The same dataset as the input keeping only rows diplaying the expected hierarchical relationship between parent and child columns.
#' @export
#'
# #' @examples
discard_non_hierarchic_rows <- function(data, parent, child) {
  data %>%
    dplyr::distinct({{ parent }}, {{ child }}) %>%
    dplyr::group_by({{ child }}) %>%
    dplyr::filter(dplyr::n() < 2)
}



#' Augment insee administrative dataset with com_arm_code and com_arm_lib
#'
#' @param data A insee dataset containing at least the 4 olumns required for computation:
#'   c("arm_code", "arm_lib", "com_code", "com_lib").
#'
#' @return The input dataset augmented with com_arm_code and com_arm_lib columns
#' @export
#'
#' @examples
#' data.frame(
#'   id = 1:5,
#'   arm_code = c("75101", "75102", "75111", "ZZZZZ", NA_character_),
#'   com_code = c("75056", "75056", "75056", "72191", "72191")
#' ) %>%
#'   augment_com_arm_cols()
#' data.frame(
#'   id = 1:5,
#'   arm_code = c("75101", "75102", "75111", "ZZZZZ", NA_character_),
#'   com_code = c("75056", "75056", "75056", "74037", "74037"),
#'   arm_lib = c("Paris 1er Arrondissement", "Paris 2e Arrondissement", "Paris 11e Arrondissement", "ZZZZZ", NA_character_),
#'   com_lib = c("Paris", "Paris", "Paris", "Boëge", "Boëge")
#' ) %>%
#'   augment_com_arm_cols()
augment_com_arm_cols <- function(data) {
  # Vérifier que les colonnes arm_code, arm_lib, com_code & com_lib existent bien
  if (!all(c("arm_code", "com_code") %in% colnames(data))) {
    stop('Columns `c("arm_code", "com_code")` required for `com_arm_code` computation can not be found in `data`.\n')
  }
  if (!all(c("arm_lib", "com_lib") %in% colnames(data))) {
    warning("Columns required for `com_arm_lib` computation can not be found in `data`.\n")
  }
  data <- data %>%
    ## Création des codes com_arm_(code|lib) qui sont utilisés dans le découpage infracommunal.
    ## creates com_arm_code & com_arm_lib
    dplyr::mutate(
      com_arm_code = dplyr::if_else(.data$arm_code == "ZZZZZ", .data$com_code, .data$arm_code)
    )
  if (all(c("arm_lib", "com_lib") %in% colnames(data))) {
    data <- data %>%
      dplyr::mutate(
        com_arm_lib  = dplyr::if_else(.data$arm_code == "ZZZZZ", .data$com_lib, .data$arm_lib)
      )
  }
  data
}
