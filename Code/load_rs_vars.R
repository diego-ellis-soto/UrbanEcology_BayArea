# Look at NDVI:
require(sf)
require(mapview)
require(raster)
library(rnaturalearth)
require("rnaturalearthdata")

# NDVI
ndvi  = raster('/Users/diegoellis/Desktop/Projects/Postdoc/Misc_proj_data/BayArea/SF_EastBay_NDVI_Sentinel_10.tif')
# Mask the water:
continents <- ne_countries(scale = "medium", returnclass = "sf")
america_continents <- continents[continents$continent %in% c("North America"), ]
america_continents <- st_transform(america_continents, crs(ndvi))

# puzzles_lauren_spatial <- as(puzzles_lauren_sf_buffered_trans, "Spatial")
# ndvi_masked <- mask(ndvi, america_continents)
mapview(ndvi)

# Impervious surface: from this paper: https://essd.copernicus.org/articles/14/1831/2022/
imp_surf_30 =raster('/Users/diegoellis/Desktop/Projects/Postdoc/Misc_proj_data/BayArea/SF_EastBay_GISD30_Impervious_Surface_30m.tif')
mapview(imp_surf_30)


# Did not work:
# imp_surf_MODIS =raster('/Users/diegoellis/Desktop/Projects/Postdoc/Misc_proj_data/BayArea/SF_EastBay_Impervious_Surface_MODIS_500m.tif')
# mapview(imp_surf_MODIS)

#  
human_mod_americas_masked = raster('/Users/diegoellis/Downloads/PressPulsePause/hmod_americas_masked.tif')
continents <- ne_countries(scale = "medium", returnclass = "sf")
bio1_masked = raster('/Users/diegoellis/Downloads/PressPulsePause/bio1_americas_masked.tif')
# High Res Landcover
bayarea = raster('/Users/diegoellis/Desktop/Projects/Postdoc/OSM_for_Ecology/BayArea_OSM-enhanced_lcover_map.tif')

bayarea <- projectRaster(bayarea, crs = crs(america_continents))

# Landcover
CEC_map <- rast(
  "/Users/diegoellis/Desktop/Projects/Postdoc/OSM_for_Ecology/land_cover_2020v2_30m_tif/NA_NALCMS_landcover_2020v2_30m/data/NA_NALCMS_landcover_2020v2_30m.tif"
) 
# Clip to My Study area:
puzzles_lauren_sf_anno_sp_sf = st_transform(st_as_sf(puzzles_lauren_sf_anno_sp) , crs = crs(CEC_map))


# Clip landcover to smaller bounding box:
# Define bounding box coordinates in longitude and latitude (WGS84)
lon_min <- -123.0  
lon_max <- -121.0  
lat_min <- 37.0    
lat_max <- 38.5    


# Create a data frame with bounding box coordinates
bbox_df <- data.frame(
  lon = c(lon_min, lon_max, lon_max, lon_min, lon_min),
  lat = c(lat_min, lat_min, lat_max, lat_max, lat_min)
)

# Convert to an sf polygon
bbox_sf <- st_as_sf(bbox_df, coords = c("lon", "lat"), crs = 4326) %>%
  summarise(geometry = st_combine(geometry)) %>%
  st_cast("POLYGON")

# Get the CRS of the raster
raster_crs <- crs(CEC_map)

# Transform the bounding box to match the raster's CRS
bbox_sf_proj <- st_transform(bbox_sf, crs = crs(CEC_map))

bbox_vect <- vect(bbox_sf_proj) # convert to spatvector
cropped_raster <- crop(CEC_map, bbox_vect)

plot(cropped_raster)

# Clip 
require(terra)
puzzles_lauren_sf_anno_sp_sf_vect = vect(puzzles_lauren_sf_anno_sp_sf)

plot(crop(CEC_map, puzzles_lauren_sf_anno_sp_sf_vect))

# landcovermap_coarse_lauren_study_area = crop(CEC_map, puzzles_lauren_sf_anno_sp_sf_vect)

# crop(bayarea, st_bbox(puzzles_lauren_sf_anno_sp_sf_vect[! puzzles_lauren_sf_anno_sp_sf_vect$Name == 'Fahrer Home',]))

# Fahrer Home 

ncld_imp_surf_2023 <- raster("/Users/diegoellis/Downloads/NLCD_impervious_2021_release_all_files_20230630/nlcd_2021_impervious_l48_20230630.img")

puzzle_sp_tmp <- st_transform(st_as_sf(puzzle_sp), crs(ncld_imp_surf_2021))
cropped_raster <- crop(ncld_imp_surf_2021, extent(st_bbox(puzzle_sp_tmp)))
plot(cropped_raster)
# https://www.mrlc.gov/data/type/urban-imperviousness
puzzle_sp_tmp$imp_surf = raster::extract(cropped_raster, puzzle_sp_tmp)
