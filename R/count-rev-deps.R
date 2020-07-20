library(crandep)
library(dplyr)

rev_sug_raster = get_dep_all("raster", type = c("Reverse_suggests"))
rev_imp_raster = get_dep_all("raster", type = c("Reverse_imports"))
rev_dep_raster = get_dep_all("raster", type = c("Reverse_depends"))

rev_sug_sp = get_dep_all("sp", type = c("Reverse_suggests"))
rev_imp_sp = get_dep_all("sp", type = c("Reverse_imports"))
rev_dep_sp = get_dep_all("sp", type = c("Reverse_depends"))

rev_sug_sf = get_dep_all("sf", type = c("Reverse_suggests"))
rev_imp_sf = get_dep_all("sf", type = c("Reverse_imports"))
rev_dep_sf = get_dep_all("sf", type = c("Reverse_depends"))
