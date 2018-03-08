#' 24km Lat-Lon data
#'
#' The NCSID 24 km snow coverage products is provided as an ascii file with 1024 rows x 1024 columns using a polar projection centered around the north pole and covering the northern hemisphere.  The actual latitude and longitude coordinates of the data are provided separately as bin files - which are converted to a matrix here. 
#' 
#' The raw lat-lon bin files are posted by NSIDC here: \link{ftp://sidads.colorado.edu/pub/DATASETS/NOAA/G02156/metadata/}
#' 
#' @format  Two 1024 x 1024 matrices: \code{lon.matrix} and \code{lat.matrix} - of the longitudes and latitudes, respectively, of the snow grid.   A vector of \code{xs} and \code{ys} - coordinates that map the longituded and latitude to a unit circle.  Finally, a data frame \code{lonlat.df} which contains the midpoint, ll, ul, ur, and lr corners of each of the 1024 x 1024 = 1048576 lat-lon polygons 
#' 
#' @name lonlat24km
#' @docType data
#' @usage data(lonlat24km)
#' @examples
#' data(lonlat24km)
#' dim(lat.matrix)
#' dim(lon.matrix)
#' require(fields)
#' image.plot(xs, ys, lat.matrix, main = "latitude")
#' image.plot(xs, ys, lon.matrix, main = "longitude")
#' @source National Ice Center. 2008, updated daily. IMS Daily Northern Hemisphere Snow and Ice Analysis at 1 km, 4 km, and 24 km Resolutions, Version 1. Boulder, Colorado USA. NSIDC: National Snow and Ice Data Center. doi: \link{http://dx.doi.org/10.7265/N52R3PMC}. 
NULL

#' Sample 24km snow data frames
#'
#' Two data frames: \code{snow.2011.016} and \code{snow.2011.150} containing grid coordinates and snow coverage in North America from two days in 2011: Jan 16 (day 016) and May 30 (day 150).   The raw data files are located here: \link{ftp://sidads.colorado.edu/pub/DATASETS/NOAA/G02156/24km/2011/}
#' 
#' @format  data frame with 11 columns:
#' \describe{
#'   \item{lon,lat}{longitude and latitude - midpoint of grid cell}
#'   \item{lon.ll,lon.ul,lon.ur,lon.lr}{longitudes of corners of grid}
#'   \item{lat.ll,lat.ul,lat.ur,lat.lr}{latitudes of corners of grid}
#'   \item{snow}{snow coverage: 2 = no snow, 3 = sea ice, 4 = snow}
#'   \item{area}{of grid cell, in km^2}
#' }
#' 
#' @name snow24km
#' @docType data
#' @usage data(snow24km)
#' @examples
#' data(snow24km)
#' par(mfrow = c(1,2))
#' plotSnowData(snow.2011.016); title("Jan 16, 2011")
#' plotSnowData(snow.2011.150); title("May 30, 2011")
#' 
#' @source National Ice Center. 2008, updated daily. IMS Daily Northern Hemisphere Snow and Ice Analysis at 1 km, 4 km, and 24 km Resolutions, Version 1. Boulder, Colorado USA. NSIDC: National Snow and Ice Data Center. doi: \link{http://dx.doi.org/10.7265/N52R3PMC}. 
NULL

#' Oscillations
#'
#' Monthly averages of large-scaled climate oscillations in the northern hemisphere: Pacific Decadal (PDO), Arctic (AO) and North Atlantic (NAO) from January 1950 to December 2017.
#' 
#' @format  data frame with 7 columns:
#' \describe{
#'   \item{year}{beginning 1950}
#'   \item{month}{1-12}
#'   \item{PDO}{indices are roughly standard normal ...}
#'   \item{AO}{}
#'   \item{NAO}{}
#'   \item{season}{October:March = winter;  April:September = summer}
#'   \item{Y2}{assigns January:March to the previous year}
#' }
#' @references PDO: \link{http://research.jisao.washington.edu/pdo/}; AO: \link{http://www.cpc.noaa.gov/products/precip/CWlink/daily_ao_index/ao_index.html}; NAO: \link{https://www.ncdc.noaa.gov/teleconnections/nao/}
#' @name Oscillations
#' @docType data
#' @usage data(Oscillations)
#' @examples
#' data(Oscillations)
#' require(gridExtra)
#' ggplot.osc <- function(data = Oscillations, var, title = ""){
#'   ggplot(data %>% mutate(year = factor(year)), 
#'          aes(year, get(var))) + 
#'     geom_boxplot() + 
#'     ggtitle(title) + ylim(-2.5,2.5)
#' }
#' 
#' o <- subset(Oscillations, year >= 1990 & season == "winter") %>% mutate(year = Y2)
#' pdo <- ggplot.osc(o, "PDO", "Pacific Decadal Oscillation")
#' ao <- ggplot.osc(o, "AO", "Arctic Oscillation")
#' nao <- ggplot.osc(o, "NAO", "North Atlantic Oscillation")
#' grid.arrange(pdo, ao, nao,  nrow = 3)
NULL