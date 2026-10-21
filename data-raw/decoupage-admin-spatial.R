## extracted from spatial.INSEE to prepare the data: 2025-03-29
## TODO: rendre la fonction plus générale `pipeline_sf_INSEE()`
## En fait les codes sont très différents entre le COG et contours IRIS de l'IGN (pas d'unification)
## Il y a donc pour l'instant 2 fonctions distinctes
## - faire le lien entre l'argument `layer`, et les variables sélectionnées dans le `select`
## - ex: var_layer <- dplyr::case_when(
##     layer == "CONTOURS-IRIS" ~ c("CODE_IRIS", "NOM_IRIS", "TYP_IRIS", "INSEE_COM", "NOM_COM"),
##     ...
##     )
##  ...dplyr::select(dplyr::all_of(c(var_layer, "geometry"))) %>%
#' Pipeline to create spatial data from INSEE/IGN files for various granularity
#'
#' @param dsn The path to the shapefile layer. In most cases it will be `CONTOURS-IRIS`.
#' @param layer The name of the shapefile, for instance "CONTOURS-IRIS".
#'
#' @return A simple feature (SF) dataset created from the shapefile, with adapted columns:
#'   for instance with `CONTOURS-IRIS`, it will be iris_code, iris_lib, iris_typ, com_code, com_lib, geometry.
#' @export
#'
#' @examples
#' path_to_shp_cog_2022 <- path_to_extdata("IGN/ADMIN-EXPRESS-COG")
#' pipeline_sf_admin_express_cog(path_to_shp_cog_2022, layer = "COMMUNE")
#' pipeline_sf_admin_express_cog(path_to_shp_cog_2022, layer = "COMMUNE_ASSOCIEE_OU_DELEGUEE") #%>%
#'   # dplyr::filter(cad_code == "14142")
pipeline_sf_admin_express_cog <- function(dsn, layer) {
  ## adaptation des variables à importer en fonction du nom de la layer
  var_layer <- switch(
    layer,
    ## les grands classiques
    "COMMUNE" = c("ID", "COM_LIB" = "NOM", "COM_CODE" = "INSEE_COM", "STATUT", "INSEE_CAN", "INSEE_ARR", "INSEE_DEP", "INSEE_REG", "SIREN_EPCI"),
    "CANTON" = c("ID", "INSEE_CAN", "INSEE_ARR", "INSEE_DEP", "INSEE_REG"),
    "ARRONDISSEMENT" = c("ID", "INSEE_ARR", "INSEE_DEP", "INSEE_REG"),
    "DEPARTEMENT" = c("ID", "DEP_LIB" = "NOM", "INSEE_DEP", "INSEE_REG"),
    "REGION" = c("ID", "REG_LIB" = "NOM", "INSEE_REG"),
    ## les exotiques
    "COMMUNE_ASSOCIEE_OU_DELEGUEE" = c("ID", "CAD_LIB" = "NOM", "INSEE_CAD", "INSEE_COM", "NATURE"),
    "ARRONDISSEMENT_MUNICIPAL" = c("ID", "ARM_LIB" = "NOM", "INSEE_ARM", "INSEE_COM"),
    # "CHFLIEU_ARRONDISSEMENT_MUNICIPAL" ~ c("ID", "NOM", "ID_COM"), geometry sfc_POINT qui relie les ID entre eux...
    # "CHFLIEU_COMMUNE_ASSOCIEE_OU_DELEGUEE" ~ c("ID", "NOM", "ID_COM"), geometry sfc_POINT qui relie les ID entre eux...
    # "CHFLIEU_COMMUNE" ~ c("ID", "NOM", "ID_COM"), geometry sfc_POINT qui relie les ID entre eux...
    "COLLECTIVITE_TERRITORIALE" = c("ID", "COL_LIB" = "NOM", "INSEE_COL"),
    "EPCI" = c("ID", "CODE_SIREN", "NOM", "NATURE")
  )

  sf::st_read(dsn = dsn, layer = layer) %>%
    dplyr::select(dplyr::all_of(c(var_layer, "geometry"))) %>%
    unify_admin_express_cog_code()
}

#' Unify column names for administrative codes across the various INSEE datasets
#'
#' @param data A INSEE dataset with columns names to be unified.
#'
#' @return The same datasets with unified column names.
#' @export
#'
#' @examples
#' tibble::tibble(
#' "ID" = character(), "NOM" = character(), "NOM_M" = character(),
#' "INSEE_COM" = character(), "STATUT" = character(), "POPULATION" = character(),
#' "INSEE_CAN" = character(), "INSEE_ARR" = character(), "INSEE_DEP" = character(),
#' "INSEE_REG" = character(), "SIREN_EPCI" = character(), "geometry" = character()
#' ) %>%
#'   unify_admin_express_cog_code()
unify_admin_express_cog_code <- function(data) {
  data %>%
    dplyr::rename_with(.fn = \(x) x %>%
                         stringr::str_replace("^INSEE_(.*)$", "\\1_code") %>%
                         stringr::str_to_lower()
    )
}


#' Pipeline to create spatial data for IRIS granularity
#'
#' @param dsn The path to the `CONTOURS-IRIS` shapefile layer.
#' @param layer The name of the shapefile, defaults to "CONTOURS-IRIS".
#'
#' @return A simple feature (SF) dataset created from the shapefile, with 6 columns:
#'   iris_code, iris_lib, iris_typ, com_arm_code, com_arm_lib, geometry.
#' @export
#'
#' @examples
#' path_to_shp_contours_iris_2022 <- path_to_extdata("IGN/CONTOURS-IRIS")
#' pipeline_sf_IRIS(path_to_shp_contours_iris_2022, layer = "CONTOURS-IRIS")
pipeline_sf_IRIS <- function(dsn, layer = "CONTOURS-IRIS") {
  sf::st_read(dsn = dsn, layer = layer) %>%
    # dplyr::select("CODE_IRIS", LIB_IRIS = "NOM_IRIS", "TYP_IRIS", CODE_COM = "INSEE_COM", LIB_COM = "NOM_COM", "geometry")
    dplyr::select(dplyr::all_of(
      c(iris_code = "CODE_IRIS", iris_label = "NOM_IRIS", iris_type = "TYP_IRIS",
        com_arm_code = "INSEE_COM", com_arm_lib = "NOM_COM",
        "geometry"))) #%>%
  ## maj 2025-01-18: modification des noms dirrectement dans la fonction principale
  ## TODO: vérifier la compatibilité pour tous les millésimes
    # unify_admin_code()
}

