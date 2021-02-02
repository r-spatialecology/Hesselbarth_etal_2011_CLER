
#---------------------------------------------------#
#                                                   #
#   Code to reproduce Fig. 2 in                     #
#   "Open-source tools in R for landscape ecology"  #
#                                                   #
#   Code created by MHKH, JN, JS and LJG            #
#                                                   #
#   Contact: mhk.hesselbarth@gmail.com              #
#                                                   #
#---------------------------------------------------#

# load libraries
library(ggplot2)
library(sf)
library(raster)
library(rnaturalearth)
library(tmap)
library(viridis)

# get precipitation data
precipitation <- raster::getData("worldclim", lon = 3, lat = 38,
                                 res = 0.5, var = "prec", path = "R/")

# calculate total precipitation
precipitation_sum <- raster::calc(x = precipitation, fun = sum)

# reproject to geographical CRS
precipitation_sum <- raster::projectRaster(precipitation_sum, crs = "+init=epsg:21781")

# get admin boundaries of Switzerland
switzerland <- rnaturalearth::ne_countries(scale = 50,
                                           country = "switzerland",
                                           returnclass = "sf")

# reproject to geographical CRS
switzerland <- sf::st_transform(x = switzerland, crs = "epsg:21781")

# crop and mask with buffer
precipitation_sum_ch <- raster::crop(x = precipitation_sum,
                                     y = sf::st_buffer(x = switzerland, dist = 5000))

# reclassify into 5 classes
precipitation_class_ch <- raster::cut(precipitation_sum_ch, breaks = 5)

# create base plot

# pdf(file = "R/Figures/base_plot.pdf")

plot(precipitation_class_ch, col = viridis::viridis(5))
plot(st_geometry(switzerland), add = TRUE, lwd = 4, border = "white")
plot(st_geometry(switzerland), add = TRUE)

# dev.off()

# create ggplot
plot_gg <- ggplot(raster::as.data.frame(precipitation_class_ch, xy = TRUE)) +
    geom_raster(aes(x = x, y = y, fill = factor(layer))) +
    geom_sf(data = switzerland, fill = NA, col = "white") +
    scale_fill_viridis_d(name = "Precipitation\nclassified") +
    coord_sf() +
    labs(x = "", y = "") +
    theme_classic() +
    theme(legend.position = "bottom")

# ggplot2::ggsave(filename = "R/Figures/ggplot2.pdf")

plot_tm <- tm_shape(precipitation_class_ch) +
    tm_graticules() +
    tm_raster(title = "Precipitation\nclassified",
              style = "cat",
              palette = "viridis",
              legend.is.portrait = FALSE) +
    tm_shape(switzerland) +
    tm_borders(lwd = 2, col = "white") +
    tm_scale_bar(breaks = c(0, 25, 50),
                 bg.color = "white") +
    tm_layout(legend.outside = TRUE,
              legend.outside.position = "bottom")

# tmap::tmap_save(plot_tm, "R/Figures/tmap.pdf")

