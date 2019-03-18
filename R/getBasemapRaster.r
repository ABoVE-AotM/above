#' getBasemapRaster
#' 
#' This function obtains an RGB raster from any of the available base maps in the (incredible!) open source leaflet package.  It is meant to replace - in a way - the \code{\link{ggmap}} function, which now requires an API key with Google.  It is in some ways more flexible: you can set the lat and long limits strictly, it returns a projected raster which can be reprojected to any other resolution, and it can access any of the remarkable diversity of high quality mapping option at:  http://leaflet-extras.github.io/leaflet-providers/preview/.  Note that it creates a "png" and "html" and places it in a given directory, and does not delete them. 
#'  
#' @param {xmin, ymin, xmax, ymax} Limits (in longitude and latitude) of desired map raster.
#' @param map.types Character specification for the base maps. see http://leaflet-extras.github.io/leaflet-providers/preview/ for available options. Favorites include: \code{Esri.WorldPhysical} (default), \code{Esri.WorldTerrain}, \code{Esri.NatGeoWorldMap}
#' @param filename name of png and html files
#' @param directory directory to save the htlm and png files
#' @param zoom a resolution parameter. The default 4 gives approximately a 2000 x 2000 raster, 8 gives a 4000 x 4000, etc. 
#' @param plotme whether or not to plot the raster with \code{\link{plotRGB}}. Note that high resolution rasters are reduced in rendering within R by default ... this can be modified with \code{\link{plotRGB}} options.  
#' @param ... Additional paramters to pass to \code{\link{mapview}}
#' @return An RGB raster, i.e. one with three levels for each of the colors
#' @export
#' @examples
#' # SE Alaska
#' SEalaska.topo <- getBasemapRaster(-138,-130, 56, 60, "OpenTopoMap")
#' # for a ggPlot use this function (from RStoolbox): 
#' ggRGB(SEalaska.topo, 1, 2, 3, coord_equal = FALSE)
#' # DC map, high resolution
#' dc.natgeo <- getBasemapRaster(-77.5,-76.5, 38.5, 39.25, "Esri.NatGeoWorldMap", zoom = 8, plotme = FALSE)
#' ggRGB(dc.natgeo, 1, 2, 3, coord_equal = FALSE)


getBasemapRaster <- function(xmin, xmax, ymin, ymax, map.types = "Esri.WorldPhysical",
                              directory = ".", 
                              filename = "basemap",
                              zoom = 4, 
                              plotme = TRUE, ...)
{
  # creating a white rectangular donut
  outer = cbind(lon = c(-180,-180,180,180,-180), lat = c(-90,90,90,-90,-90))
  hole = cbind(lon = c(xmin, xmax, xmax, xmin, xmin), 
               lat = c(ymin, ymin, ymax, ymax, ymin))
  earthwithhole = st_polygon(list(outer, hole)) %>% st_sfc(crs = 4326)
  
  basemap <- mapview(earthwithhole, map.types = map.types, alpha = 0.5,
                     col.regions = "white", alpha.regions = 1) 
  basemap@map <- fitBounds(basemap@map, xmin, ymin, xmax, ymax)
  
  mapurl <- paste0(directory, '/', filename, '.html')
  mappng <- paste0(directory, '/', filename, '.png')

  # create local html  
  mapshot(basemap, url = mapurl)
  # create png from local html
  webshot(url = mapurl, file = mappng, zoom = zoom)
  m <- brick(paste0(directory, '/', filename, '.png'))
  
  # trim off legend and other mapview text at bottom 
  m <- crop(m, extent(0.1 * dim(m)[1],
                      0.9 * dim(m)[1],
                      0.1 * dim(m)[2],
                      0.9 * dim(m)[2]))
  
  innercore <- m[[1]] != 255
  innercore[!innercore] <- NA
  trimextent <- trim(innercore) %>% extent
  
  m2 <- crop(m, trimextent)
  extent(m2) <- extent(xmin, xmax, ymin, ymax)
  crs(m2) <- (st_crs(earthwithhole) %>% as.character)[2]
  
  if(plotme) plotRGB(m2)
  return(m2)
}



