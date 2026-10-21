## extracted from spatial.INSEE to prepare the data: 2025-03-29
#' Unify column names for administrative codes across the various INSEE datasets
#'
#' @param data A INSEE dataset with columns names to be unified.
#'
#' @return The same datasets with unified column names.
#' @export
#'
# #' @examples
unify_admin_code <- function(data) {
  data %>%
    dplyr::rename_with(.fn = \(x) x %>%
                         stringr::str_replace("^(?:CODE_)?IRIS$", "iris_code") %>%
                         stringr::str_replace("^(?:NOM|LIB)_IRIS$", "iris_label") %>%
                         stringr::str_replace("^(?:TYP_|CAT)IRIS$", "iris_type") %>%
                         ## maj 2025-01-14: conservation de la différence entre ARR et ARM
                         # stringr::str_replace("^AR[RM]$", "arr_code") %>%
                         stringr::str_replace("^(AR[RM])$", "\\1_code") %>%
                         stringr::str_replace("^(DEPCOM|COMMUNE|INSEE_COM)$", "com_arm_code") %>%
                         stringr::str_replace("^LIBCOM|NOM_COM$", "com_label") %>%
                         stringr::str_replace("^CV|CANTVILLE$", "cv_code") %>%
                         stringr::str_replace("^DEP$", "dep_code") %>%
                         stringr::str_replace("^REG(?:ION)?$", "reg_code") %>%
                         stringr::str_to_lower()
    )
}

# unify_admin_code <- function(data) {
#   data %>%
#     dplyr::rename_with(.fn = \(x) x %>%
#                          stringr::str_replace("^(?:CODE_)?IRIS$", "iris_code") %>%
#                          stringr::str_replace("^(?:NOM|LIB)_IRIS$", "iris_lib") %>%
#                          stringr::str_replace("^(?:TYP_|CAT)IRIS$", "iris_typ") %>%
#                          ## maj 2025-01-14: conservation de la différence entre ARR et ARM
#                          # stringr::str_replace("^AR[RM]$", "arr_code") %>%
#                          stringr::str_replace("^(AR[RM])$", "\\1_code") %>%
#                          stringr::str_replace("^(DEPCOM|COMMUNE|INSEE_COM)$", "com_arm_code") %>%
#                          stringr::str_replace("^LIBCOM|NOM_COM$", "com_lib") %>%
#                          stringr::str_replace("^CV|CANTVILLE$", "cv_code") %>%
#                          stringr::str_replace("^DEP$", "dep_code") %>%
#                          stringr::str_replace("^REG(?:ION)?$", "reg_code") %>%
#                          stringr::str_to_lower()
#     )
# }

## TODO: Extraire les imports supracommunaux pour améliorer la lisibilité ?
#' Create decoupage admin communal compatible with infracommunal IRIS
#'
#' @param path Path to `table-appartenance-geo-communes` xlsx file for a given millesime.
#' @param skip Number of rows to skip (meta data in the first five lines of the xls file).
#'   Data is stored in the first 2 sheets of the excel file (first no ARRT, 2nd comunnes with ARRT).
#'
#' @return A dataset of the supra-communal administrative partitionning of France, compatible with the infra-communal partitionning to IRIS granularity.
#' @export
#'
#' @examples
#' path_to_extdata("decoupage-admin/table-appartenance-geo-communes-22.xlsx") %>%
#'   bind_decoupage_admin_commune()
bind_decoupage_admin_commune <- function(path, skip = 5) {
  dplyr::left_join(
    ## Communes sans decoupage par ARM
    readxl::read_excel(path, skip = skip, sheet = 1) %>%
      ## dans ce fichier les colonnes de référence sont associée aux COM sans découpage par ARM
      dplyr::rename(
        com_code = "CODGEO",
        com_label = "LIBGEO"
      ) %>%
      unify_admin_code(), ## retrait des communes spécifiques Marseille, Lyon et Paris, que l'on retrouve dans l'onglet suivant avec un code plus pratique pour la jointure avec le fichier CONTOURS-IRIS
    ## Communes avec découpage ARM: Lyon, Marseille et Paris
    readxl::read_excel(path, skip = skip, sheet = 2) %>%
      ## dans ce fichier les colonnes de référence sont associée aux COM avec découpage par ARM
      dplyr::select(arm_code = "CODGEO", arm_label = "LIBGEO", com_code = "COM"),
    ## jointure sur les communes sans découpage ARM...
    by = "com_code",
    ## la relation est donc "one-to-many"
    multiple = "all", relationship = "one-to-many"
  ) %>%
    ## Remplacement des NA de arm_code obtenus après la jointure pour les communes non-découpées en ARM par des "ZZZZZ"
    tidyr::replace_na(replace = list(arm_code = "ZZZZZ")) %>%
    ## Création des codes com_arm_(code|lib) qui sont utilisés dans le découpage infracommunal.
    ## creates com_arm_code & com_arm_label
    # dplyr::mutate(
    #   com_arm_code = dplyr::if_else(is.na(.data$arm_code), .data$com_code, .data$arm_code),
    #   com_arm_label  = dplyr::if_else(is.na(.data$arm_label), .data$com_label, .data$arm_label)
    # ) %>%
    augment_com_arm_cols() %>% # Creation d'une fonction spécifique
    ## Déplacement des colonnes pour mettre en avant com_arm_code, et cv_code...
    dplyr::relocate(
      dplyr::all_of(c("com_arm_code", "com_arm_label", "cv_code", "com_code", "com_label", "arm_code", "arm_label")),
      .before = "dep_code")
}
# bind_decoupage_admin_commune <- function(path, skip = 5) {
#   dplyr::left_join(
#     ## Communes sans decoupage par ARM
#     readxl::read_excel(path, skip = skip, sheet = 1) %>%
#       ## dans ce fichier les colonnes de référence sont associée aux COM sans découpage par ARM
#       dplyr::rename(
#         com_code = "CODGEO",
#         com_lib = "LIBGEO"
#       ) %>%
#       unify_admin_code(), ## retrait des communes spécifiques Marseille, Lyon et Paris, que l'on retrouve dans l'onglet suivant avec un code plus pratique pour la jointure avec le fichier CONTOURS-IRIS
#     ## Communes avec découpage ARM: Lyon, Marseille et Paris
#     readxl::read_excel(path, skip = skip, sheet = 2) %>%
#       ## dans ce fichier les colonnes de référence sont associée aux COM avec découpage par ARM
#       dplyr::select(arm_code = "CODGEO", arm_lib = "LIBGEO", com_code = "COM"),
#     ## jointure sur les communes sans découpage ARM...
#     by = "com_code",
#     ## la relation est donc "one-to-many"
#     multiple = "all", relationship = "one-to-many"
#   ) %>%
#     ## Remplacement des NA de arm_code obtenus après la jointure pour les communes non-découpées en ARM par des "ZZZZZ"
#     tidyr::replace_na(replace = list(arm_code = "ZZZZZ")) %>%
#     ## Création des codes com_arm_(code|lib) qui sont utilisés dans le découpage infracommunal.
#     ## creates com_arm_code & com_arm_lib
#     # dplyr::mutate(
#     #   com_arm_code = dplyr::if_else(is.na(.data$arm_code), .data$com_code, .data$arm_code),
#     #   com_arm_lib  = dplyr::if_else(is.na(.data$arm_lib), .data$com_lib, .data$arm_lib)
#     # ) %>%
#     augment_com_arm_cols() %>% # Creation d'une fonction spécifique
#     ## Déplacement des colonnes pour mettre en avant com_arm_code, et cv_code...
#     dplyr::relocate(
#       dplyr::all_of(c("com_arm_code", "com_arm_lib", "cv_code", "com_code", "com_lib", "arm_code", "arm_lib")),
#       .before = "dep_code")
# }
## maj 2025-01-18: on réalise un left_join pour ajouter les variables com_arm_
# bind_decoupage_admin_commune <- function(path, skip = 5) {
#   dplyr::bind_rows(
#     readxl::read_excel(path, skip = skip, sheet = 1) %>%
#       dplyr::filter(!.data$CODGEO %in% c("13055", "69123", "75056")), ## retrait des communes spécifiques Marseille, Lyon et Paris, que l'on retrouve dans l'onglet suivant avec un code plus pratique pour la jointure avec le fichier CONTOURS-IRIS
#     readxl::read_excel(path, skip = skip, sheet = 2)
#   ) %>%
#     dplyr::rename(
#       DEPCOM = "CODGEO",
#       LIBCOM = "LIBGEO"
#     ) %>%
#     dplyr::select(-"COM")
# }

## Jointure infra-supra
#' Join together infra and supra-communal administrative partitionning of France.
#'
#' @param path_to_infracommunal Path to `reference_IRIS_geo` xlsx file for a given millesime.
#' @param path_to_communal Path to `table-appartenance-geo-communes` xlsx file for a given millesime.
#' @param skip_infracommunal,skip_communal Number of rows to skip
#'   (meta data in the first five lines of the xls file).
#'   It's actually the same in both files, but it may change in the future.
#' @importFrom dplyr left_join select all_of
#'
#' @return A dataset combining infra-communal & supra-communal administrative partitionning of France
#' @export
#'
#' @examples
#' path_to_IRIS_2022 <- path_to_extdata("decoupage-admin/reference_IRIS_geo2022.xlsx")
#' path_to_communal_2022 <- path_to_extdata(
#'   "decoupage-admin/table-appartenance-geo-communes-22.xlsx"
#'   )
#' pipeline_decoupage_admin(path_to_IRIS_2022, path_to_communal_2022) %>%
#'   dplyr::slice(1:6)
pipeline_decoupage_admin <- function(path_to_infracommunal, path_to_communal, skip_infracommunal = 5, skip_communal = skip_infracommunal) {
  dplyr::left_join(
    import_decoupage_IRIS(path_to_infracommunal, skip = skip_infracommunal) %>%
      ## Il faut retirer UU2020 qui est fausse pour le fichier IRIS...
      ## https://www.insee.fr/fr/information/7671844
      ## Avertissement : les tables d’appartenance géographique des communes diffusées pour les millésimes 2020 à 2023 contenaient deux erreurs concernant les unités urbaines de Genève-Annemasse (00653) et de Paris (00851). Ces erreurs ont été corrigées dans les tables diffusées le 2 avril 2024 :
      ## - La commune de Boëge (74037) a été retirée de l’unité urbaine de Genève-Annemasse (00653).
      ## - Les communes de Saint-Rémy-l’Honoré (78576), Bazoches-sur-Guyonne (78050) et Le Tremblay-sur-Mauldre (78623) ont été retirée de l’unité urbaine de Paris (00851) et constituent l’unité urbaine de Saint-Rémy-l’Honoré (78109).
      dplyr::select(!dplyr::all_of(c("uu2020"))),
    ## maj 2025-01-06: le join avec le "UU2020" induit des NA
    ## il faut le supprimer du découpage communal pour éviter une redondance...
    ## En fait, il y a eu
    # bind_decoupage_admin_commune(path_to_communal, skip = skip_communal),
    # by = c("DEPCOM", "LIBCOM", "UU2020", "DEP", "REG")
    bind_decoupage_admin_commune(path_to_communal, skip = skip_communal),
    ## 5 variables sont communes aux 2 datasets, mais UU2020 contient 5 erreurs au niveau infracommunal
    by = c("com_arm_code", "com_arm_label", "dep_code", "reg_code")
  ) %>%
    # dplyr::rename(
    #   CODE_COM = "DEPCOM",
    #   LIB_COM = "LIBCOM"
    # )
    unify_admin_code()
}

# pipeline_decoupage_admin <- function(path_to_infracommunal, path_to_communal, skip_infracommunal = 5, skip_communal = skip_infracommunal) {
#   dplyr::left_join(
#     import_decoupage_IRIS(path_to_infracommunal, skip = skip_infracommunal) %>%
#       ## Il faut retirer UU2020 qui est fausse pour le fichier IRIS...
#       ## https://www.insee.fr/fr/information/7671844
#       ## Avertissement : les tables d’appartenance géographique des communes diffusées pour les millésimes 2020 à 2023 contenaient deux erreurs concernant les unités urbaines de Genève-Annemasse (00653) et de Paris (00851). Ces erreurs ont été corrigées dans les tables diffusées le 2 avril 2024 :
#       ## - La commune de Boëge (74037) a été retirée de l’unité urbaine de Genève-Annemasse (00653).
#       ## - Les communes de Saint-Rémy-l’Honoré (78576), Bazoches-sur-Guyonne (78050) et Le Tremblay-sur-Mauldre (78623) ont été retirée de l’unité urbaine de Paris (00851) et constituent l’unité urbaine de Saint-Rémy-l’Honoré (78109).
#       dplyr::select(!dplyr::all_of(c("uu2020"))),
#     ## maj 2025-01-06: le join avec le "UU2020" induit des NA
#     ## il faut le supprimer du découpage communal pour éviter une redondance...
#     ## En fait, il y a eu
#     # bind_decoupage_admin_commune(path_to_communal, skip = skip_communal),
#     # by = c("DEPCOM", "LIBCOM", "UU2020", "DEP", "REG")
#     bind_decoupage_admin_commune(path_to_communal, skip = skip_communal),
#     ## 5 variables sont communes aux 2 datasets, mais UU2020 contient 5 erreurs au niveau infracommunal
#     by = c("com_arm_code", "com_arm_lib", "dep_code", "reg_code")
#   ) %>%
#     # dplyr::rename(
#     #   CODE_COM = "DEPCOM",
#     #   LIB_COM = "LIBCOM"
#     # )
#     unify_admin_code()
# }

#' Import administrative splitting from IRIS granularity
#'
#' @inheritParams readxl::read_excel
#' @importFrom readxl read_excel
#' @importFrom dplyr select all_of
#'
#' @return A dataset with 9 columns:
#'   iris_code, iris_label, iris_typ, grd_quart_code, com_arm_code, com_arm_label,
#'   uu2020, dep_code and reg_code.
#' @export
#'
#' @examples
#' path_to_decoupage_IRIS_2022 <- path_to_extdata("decoupage-admin/reference_IRIS_geo2022.xlsx")
#' import_decoupage_IRIS(path_to_decoupage_IRIS_2022, skip = 5)
import_decoupage_IRIS <- function(path, skip = 5) {
  readxl::read_excel(path = path, skip = skip) %>%
    dplyr::select(dplyr::all_of(
      c(iris_code = "CODE_IRIS", iris_label = "LIB_IRIS", iris_typ = "TYP_IRIS",
        grd_quart_code = "GRD_QUART",
        com_arm_code = "DEPCOM", com_arm_label = "LIBCOM",
        uu2020 = "UU2020", dep_code = "DEP", reg_code = "REG"))) #%>%
  ## maj 2025-01-18: modification des noms directement dans la fonction principale
  ## TODO: vérifier la compatibilité pour tous les millésimes
  # unify_admin_code()
}

# import_decoupage_IRIS <- function(path, skip = 5) {
#   readxl::read_excel(path = path, skip = skip) %>%
#     dplyr::select(dplyr::all_of(
#       c(iris_code = "CODE_IRIS", iris_lib = "LIB_IRIS", iris_typ = "TYP_IRIS",
#         grd_quart_code = "GRD_QUART",
#         com_arm_code = "DEPCOM", com_arm_lib = "LIBCOM",
#         uu2020 = "UU2020", dep_code = "DEP", reg_code = "REG"))) #%>%
#   ## maj 2025-01-18: modification des noms directement dans la fonction principale
#   ## TODO: vérifier la compatibilité pour tous les millésimes
#   # unify_admin_code()
# }
