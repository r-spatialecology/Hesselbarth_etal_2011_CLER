library(ggplot2)
library(cowplot)
library(sf)
library(raster)
library(rnaturalearth)
library(tmap)

# get precipitation data
precipitation <- raster::getData("worldclim", lon = 3, lat = 38,
                                 res = 0.5, var = "prec", path = "R/")

# get admin boundaries of switzerland
switzerland <- rnaturalearth::ne_countries(country = "switzerland", returnclass = "sf")

# crop and mask
precipitation_ch <- raster::crop(precipitation, switzerland)
precipitation_ch <- raster::mask(precipitation_ch, switzerland)
plot(precipitation_ch[[1]])


precipitation_ch_mean <- raster::calc(x = precipitation_ch, fun = mean)

plot(precipitation_ch_mean)

plot(switzerland$geometry, add = TRUE)

plot_base <- recordPlot()

precipitation_ch_class <- raster::cut(precipitation_ch_mean, breaks = 5)

plot_gg <- ggplot(raster::as.data.frame(precipitation_ch_class, xy = TRUE)) +
    geom_raster(aes(x = x, y = y, fill = factor(layer))) +
    geom_sf(data = switzerland, fill = NA, col = "white") +
    scale_fill_viridis_d(name = "Precipitation\nclassified") +
    coord_sf() +
    labs(x = "", y = "") +
    theme_classic()

cowplot::plot_grid(plot_base, plot_gg,
                   rel_widths = c(1, 1))
