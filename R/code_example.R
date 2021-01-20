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

# reproject to geographical CRS
precipitation_sum <- raster::projectRaster(precipitation_sum, crs = "+init=epsg:21781")

# get admin boundaries of Switzerland
switzerland <- rnaturalearth::ne_countries(scale = 50,
                                           country = "switzerland",
                                           returnclass = "sf")

# reproject to geographical CRS
switzerland <- sf::st_transform(x = switzerland, crs = "epsg:21781")

# crop and mask with buffer
precipitation_sum_ch <- raster:::crop(x = precipitation_sum,
                                      y = sf::st_buffer(x = switzerland, dist = 5000))

# create base plot
# pdf(file = "R/Figures/base_plot.pdf")

plot(precipitation_sum_ch)
plot(st_geometry(switzerland), add = TRUE)

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
# tmap_mode("plot")
tmap_mode("view")

plot_tm = tm_shape(precipitation_class_ch) +
    tm_graticules() +
    tm_raster(title = "Precipitation\nclassified", style = "cont",
              palette = "viridis") +
    tm_shape(switzerland) +
    tm_borders(lwd = 2, col = "white") +
    tm_scale_bar(breaks = c(0, 25, 50),
                 bg.color = "white") +
    tm_layout(legend.outside = TRUE)

tmap::tmap_save(plot_tm, "R/Figures/tmap.pdf")
plot_tml = tmap_leaflet(plot_tm)
mapview::mapshot(plot_tml, file = "R/Figures/tmap2.pdf")



# combine plots -----------------------------------------------------------
# https://wilkelab.org/cowplot/articles/mixing_plot_frameworks.html
library(cowplot)
tmap_mode("plot")

# prep
tm_grob = tmap_grob(plot_tm)

p1 = function() {
    plot(precipitation_class_ch)
    plot(st_geometry(switzerland), add = TRUE)
}

plot_all = plot_grid(p1, plot_gg, tm_grob,
          nrow = 1, labels = "auto")

ggsave("R/Figures/plot_all.pdf",
       width = 12, height = 4)
