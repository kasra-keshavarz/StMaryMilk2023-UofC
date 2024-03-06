install.packages("HYPEtools")
install.packages("backports")

library('HYPEtools')
geodata <- read.delim(file = '../model/GeoData.txt')

sorted_geodata <- SortGeoData(gd = geodata, progbar = T)

# Save the sorted geodata as GeoData.txt
write.table(sorted_geodata, file = '../model/GeoData.txt', sep = "\t", row.names = FALSE, quote = FALSE)
