library('raster')
library('sf')

#read the landuse raster
landuse <- raster('C:/Users/Paul Coderre/Documents/Thesis/HYPE/HYPE_geospatial/separated_geospacial/landsat/stmary_landsat_repro.tif')
#read the soil texture raster
soiltex <- raster('C:/Users/Paul Coderre/Documents/Thesis/HYPE/HYPE_geospatial/separated_geospacial/soil/stmary_soilsoil_classes.tif')

#resample landuse to match soil resolution
landuse <- resample(landuse, soiltex, method='ngb')
#overlay both rasters to get SLCs

SLC_ras <- landuse*100+soiltex

nSLC <- length(unique(getValues(SLC_ras)))
slc_val <- as.numeric(na.omit(unique(getValues(SLC_ras))))
#get SLC per subbasin
#read subbasin shp

# catchments polygon
cat_poly <- read_sf('C:/Users/Paul Coderre/Documents/Thesis/HYPE/HYPE_geospatial/stmary_shapefile/stmary_shapefile.shp')

# Shapefile reprojection
cat_poly <- st_transform(cat_poly, crs(SLC_ras))

#create empty data.frame with slc_val and hru_nhm
slc_frac <- matrix(data = 0, nrow = length(cat_poly$hru_nhm),
                   ncol = length(slc_val))
colnames(slc_frac) <- slc_val
rownames(slc_frac) <- cat_poly$hru_nhm

for (i in 1:length(cat_poly$hru_nhm)) {
  print(i)
  maski <- cat_poly[i,]
  
  ## crop and mask extraction
  slc_ras_i <- crop(SLC_ras, maski)
  slc_ras_i <- mask(slc_ras_i,maski)
  
  # getvalues of the cropped raster
  vali <- unlist(getValues(slc_ras_i))
  #remove pixel values of 0,2,4 because they have no LC data no_data
  vali[vali %in% c(0)] <- NA
  # combine SLCs with no ST info into the water class
  #combine water class with different ST into one class
  vali <- vali[!is.na(vali)] #remove na
  
  ncells <- length(vali)
  
  for (j in 1:length(slc_val)) {
    
    ncell_j <- length(which(vali == slc_val[j]))
    fracj <- ncell_j/ncells
    slc_frac[i,j] <- fracj
    
  }
}

write.csv(x = slc_frac, file = 'stmary_landsat_slc.csv', quote = F)
# # Plot them, one layer after another
# plot(slc_ras_i)
# plot(maski, add=TRUE)

