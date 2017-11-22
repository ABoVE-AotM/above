#' NSIDC Snow Model Functions
#' 
#' This function processes (and optionally plots) the 24km x 24km snow ice data.  AN additonal function \code{plotSnowData} conveniently maps the output.  
#' 
#' @param {filename,directory} of the ascii raw snow file
#' @param northamerica whether to limit to North America
#' @param water whether or not to include the open water category 
#' @param plot whether to plot the map.
#' @return a data frame that contains:  
#' \describe{
#'   \item{snow}{snow coverage: 1 = open water, 2 = no snow, 3 = sea ice, 4 = snow}
#'   \item{area}{of grid cell, in km^2}
#'   \item{lon,lat}{longitude and latitude - midpoint of grid cell}
#'   \item{lon.ll,lon.ul,lon.ur,lon.lr}{longitudes of corners of grid cell }
#'   \item{lat.ll,lat.ul,lat.ur,lat.lr}{latitudes of corners of grid cell}
#' }
#' 
#' @references National Ice Center. 2008, updated daily. IMS Daily Northern Hemisphere Snow and Ice Analysis at 1 km, 4 km, and 24 km Resolutions, Version 1. [Indicate subset used]. Boulder, Colorado USA. NSIDC: National Snow and Ice Data Center. doi: http://dx.doi.org/10.7265/N52R3PMC. [Date Accessed].
#' @export
#' @examples
#' \dontrun{
#' filename <- "ims2011150_24km_v1.2.asc"
#' directory <- "C:/Users/Elie/Box Sync/ABoVE/springmigrations/Hagos/SnowData"
#' snow.data <- loadSnowData24km(filename, directory)
#' }
#' #  The output is equivalent to the saved examples in \code{\link{snow24km}}
#' data(snow24km)
#' plotSnowData(snow.2011.016); title("Jan 16, 2011")
#' 

loadSnowData24km <- function(filename, directory = ".", plot = FALSE, northamerica = TRUE, water = FALSE){
  
  snow <- read.table(paste0(directory,"/",filename), skip = 30, colClasses = "character",stringsAsFactors = FALSE)[,1] %>% as.matrix
  snow.matrix <- aaply(snow, 1, function(s)
    strsplit(s, "", fixed = TRUE)[[1]] %>% as.numeric
  ) %>% t
  
  # load lonlat24km object - contains - crucially - the lonlat.corners.df
  if(!exists("lonlat.df")) data(lonlat24km)
  
  snow.df <- mutate(lonlat.df, snow = as.vector(snow.matrix)) %>% subset(!is.na(lat) & !is.na(lon))
  if(northamerica) snow.df <- subset(snow.df, lon > -175 & lon < -30 & lat > 30 & lat < 85)
  if(!water) snow.df <- subset(snow.df, snow != 1)
  if(plot) plotSnowData(snow.df)
  return(snow.df)
}

#' @export
plotSnowData <- function(snow.df){
    require(mapdata)
    plot.new()
    cols <- c(NA, NA, "forestgreen", "wheat", "white")
    par(usr = with(snow.df, c(min(lon), max(lon), min(lat), max(lat))))
    rect(-180, 0, 0, 90, col="darkcyan")
    apply(as.matrix(snow.df), 1, function(m) 
      polygon(x = c(m["lon.ll"], m["lon.ul"], m["lon.ur"], m["lon.lr"]), 
              y = c(m["lat.ll"], m["lat.ul"], m["lat.ur"], m["lat.lr"]), 
              col = cols[Re(m["snow"])+1], bor = NA))
    axis(1); axis(2)	
    maps::map("worldHires", add = TRUE, col=grey(.3))
    box(lwd = 2)
    legend("bottomleft", fill = cols[3:5], legend = c("no snow", "sea ice", "snow"), bg = "white")
}
