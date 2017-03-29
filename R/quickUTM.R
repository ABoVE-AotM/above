##' Find UTM zone
##' 
##' Uses longitude to identify the UTM zone and converts Long/Lat coords to UTMs.  
##' This function is buried in \code{\link{processMovedata}}
##' 
##' @param {lon} a vector of longitudes.
##' @param {lat} a vector of latitudes.
##' @return data frame with columns X and Y in automatically selected zone. 
##' @export

quickUTM <- function(lon, lat) {
  zone <- (floor((lon + 180)/6) %% 60) + 1
  zones <- unique(zone)
  xy <- cbind(lon, lat)
  flag <- rep(0, nrow(xy))

  for (z in zones) {
      indz <- which(zone == z)
      xy[indz,] <- project(xy[indz,, drop=F], paste0('+proj=utm +zone=', z))
      flag[indz] <- 1
  }
  
  if (any(flag == 0))
    warning('Some xy were not converted to UTMs')
  
  if (length(zones) > 1)
    attr(xy, 'projection') <- paste('Mixed UTM Zones:', min(zones), '-', max(zones)) else
      attr(xy, 'projection') <- paste('UTM Zone:', zones[1])
  
  return(xy)
}

#quickUTM <- function(lon, lat){
#  ll <- data.frame(X = lon, Y = lat)
#  attributes(ll)$projection <- "LL"
#  return(convUL(ll, km=TRUE))
#}
