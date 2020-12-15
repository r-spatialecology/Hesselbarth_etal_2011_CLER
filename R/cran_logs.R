library(cranlogs)
library(devtools)
library(tidyverse)

# raster #
revrep_raster <- devtools::revdep(pkg = "raster")

download_ras <- cranlogs::cran_downloads(packages = revrep_raster,
                                         from = "2012-10-01", to = Sys.Date()) %>%
    dplyr::group_by(package) %>%
    dplyr::summarise(count = sum(count)) %>%
    dplyr::arrange(-count)

# sf #
revrep_sf <- devtools::revdep(pkg = "sf")

download_sf <- cranlogs::cran_downloads(packages = revrep_sf,
                                        from = "2012-10-01", to = Sys.Date()) %>%
    dplyr::group_by(package) %>%
    dplyr::summarise(count = sum(count)) %>%
    dplyr::arrange(-count)

# sp #
revrep_sp <- devtools::revdep(pkg = "sp")

download_sp <- cranlogs::cran_downloads(packages = revrep_sp,
                                        from = "2012-10-01", to = Sys.Date()) %>%
    dplyr::group_by(package) %>%
    dplyr::summarise(count = sum(count)) %>%
    dplyr::arrange(-count)
