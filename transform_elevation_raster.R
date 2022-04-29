rm(list = ls())

library(raster)
library(rgdal)

### Indicates file with raster with elevation data ###
file_name <- choose.files(default = "", caption = "Select files",
                          multi = FALSE, filters = Filters,
                          index = nrow(Filters))

### Folder where the outputs will be salved ###
diretorio<-choose.dir(default = "", caption = "Select folder")
setwd(diretorio)

raster <- raster(file_name)

### Indicates shapefile which determines the extension to clip the raster ###
shp_clip <- readOGR(choose.files(default = "", caption = "Select files",
                                 multi = FALSE, filters = Filters,
                                 index = nrow(Filters)))
raster_crop <- crop(raster, shp_clip)

### Indicates the desidered resolution in x and y axis to resamble the clipped raster  ###
raster_base <- raster_crop
x_resolution <- 20
y_resolution <- 20
res(raster_base) <- c(x_resolution,y_resolution)

raster_res <- raster::resample(raster_crop,
                             raster_base,
                             method='ngb')

### Generates table with easting, northing and elevation values from raster ###
tabela <- as.data.frame(raster_res, xy = TRUE)

### Eliminates NA values from table ###
tabela_noNA = tabela[!is.na(tabela[,3]),]

### Write txt with table created ###
write.table(tabela_noNA,"elevation_points.txt", append = FALSE, sep = ";", dec = ".",
            row.names = FALSE, col.names = FALSE)

### Write raster clipped and resambled ###
writeRaster(raster_res, "raster_clip_resamble.tif", format="GTiff", overwrite=TRUE)
