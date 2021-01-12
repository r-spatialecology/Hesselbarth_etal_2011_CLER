library(ggplot2)
library(sf)
library(raster)
library(rnaturalearth)
library(tmap)

# get precipitation data
precipitation <- raster::getData("worldclim", lon = 3, lat = 38,
                                 res = 0.5, var = "prec", path = "R/")

# calculate total precipitation
precipitation_sum <- raster::calc(x = precipitation, fun = sum)

# crop and mask
precipitation_ch <- raster::crop(precipitation, switzerland)
precipitation_ch <- raster::mask(precipitation_ch, switzerland)
plot(precipitation_ch[[1]])

# reproject to geographical CRS
precipitation_sum <- raster::projectRaster(precipitation_sum, crs = "+init=epsg:21781")

# get admin boundaries of Switzerland
switzerland <- rnaturalearth::ne_countries(country = "switzerland",
                                           returnclass = "sf")

# reproject to geographical CRS
switzerland <- sf::st_transform(x = switzerland, crs = "epsg:21781")

# crop and mask with buffer
precipitation_sum_ch <- raster:::crop(x = precipitation_sum,
                                      y = sf::st_buffer(x = switzerland, dist = 5000))

# create base plot
# pdf(file = "R/Figures/base_plot.pdf")

plot(precipitation_sum_ch)

plot(switzerland$geometry, add = TRUE)

# dev.off()

# reclassify into 5 classes
precipitation_class_ch <- raster::cut(precipitation_sum_ch, breaks = 5)

# create ggplot
# MH: Why is this on long/lat? Coordinates seem to be okay?
plot_gg <- ggplot(raster::as.data.frame(precipitation_class_ch, xy = TRUE)) +
    geom_raster(aes(x = x, y = y, fill = factor(layer))) +
    geom_sf(data = switzerland, fill = NA, col = "white") +
    scale_fill_viridis_d(name = "Precipitation\nclassified") +
    coord_sf() +
    labs(x = "", y = "") +
    theme_classic()

ggplot2::ggsave(filename = "R/Figures/ggplot2.pdf")

# create interactive tmap (take screenshot for paper)
tmap_mode("view")

tm_shape(precipitation_class_ch) +
    tm_raster() +
    tm_shape(switzerland) +
    tm_borders()
