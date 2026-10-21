## code to prepare insee_spatial_2022 and decoupage_admin_2022 datasets goes here
## Ce code n'est pas exécuté, mais la commande ci-dessous est une sécurité sup.
if (FALSE) {
  devtools::load_all(".")
  library(dplyr)
  ## Données relatives aux datasets utilisés par l'application
  path_to_decoupage_IRIS <- insee.admin.data.2022::path_to_extdata("decoupage-admin/reference_IRIS_geo2022.xlsx")
  path_to_decoupage_communal <- insee.admin.data.2022::path_to_extdata("decoupage-admin/table-appartenance-geo-communes-22.xlsx")
  insee_admin_decoupage <- insee.admin::pipeline_decoupage_admin(path_to_decoupage_IRIS, path_to_decoupage_communal)
  usethis::use_data(insee_admin_decoupage, overwrite = TRUE)
  # ✔ Saving 'insee_admin_decoupage_2022' to 'data/insee_admin_decoupage_2022.rda'
  # • Document your data (see 'https://r-pkgs.org/data.html')
  # path_to_contours_IRIS_2022 <- "/Users/Alexis/Documents/Travail/DB/IGN/IRIS/2022/CONTOURS-IRIS_2-1__SHP__FRA_2022-01-01/CONTOURS-IRIS/1_DONNEES_LIVRAISON_2022-06-00180/CONTOURS-IRIS_2-1_SHP_LAMB93_FXX-2022"

  ## Création de la nested lut qui relie label à code pour les différents niveaux geographiques
  lut_code_label <- insee.admin::create_cog_nested_lut(path_to_decoupage_communal)
  usethis::use_data(lut_code_label, overwrite = TRUE)

  # ✔ Setting active project to "/Users/Alexis/Documents/Travail/R/Packages/insee.admin.data.2022".
  # ✔ Saving "lut_code_label" to "data/lut_code_label.rda".
  # ☐ Document your data (see <https://r-pkgs.org/data.html>).

  path_to_contours_IRIS <- insee.admin.data.2022::path_to_extdata("IGN/CONTOURS-IRIS")
  insee_admin_spatial <- insee.admin::pipeline_sf_IRIS(dsn = path_to_contours_IRIS) %>%
    # ajout des autres entités géographiques du COG
    dplyr::left_join(insee_admin_decoupage %>%
                       dplyr::select(dplyr::all_of(c("iris_code", "cv_code", "dep_code", "reg_code"))),
                     by = "iris_code")
  usethis::use_data(insee_admin_spatial, overwrite = TRUE, compress = "bzip2")
  ## Vérification que l'encodage est bien en UTF-8
  # insee_spatial_2022 %>%
  #   as.data.frame() %>%
  #   dplyr::select(-geometry) %>%
  #   purrr::map(\(x) Encoding(x))
  # ✔ Creating 'data/'
  # ✔ Setting LazyData to 'true' in 'DESCRIPTION'
  # ✔ Saving 'insee_admin_spatial_2022' to 'data/insee_admin_spatial_2022.rda'
  # • Document your data (see 'https://r-pkgs.org/data.html')

}
