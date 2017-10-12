##' Find UTM zone
##' 
##' Uses longitude to identify the UTM zone and converts Long/Lat coords to UTMs.  
##' This function is buried in \code{\link{processMovedata}}
##' 
##' @param {lon,lat} vectors of longitude and latitude.
##' @param singlezone coerce all data to a single zone;  default TRUE, if FALSE, each location gets its own zone, and the vector of UTM zones is returned. 
##' @param zone the zone to coerce to - if NULL (default), use the zone of the mid-point of the longitude 
##' @return data frame with columns X and Y in automatically selected zone. 
##' @export

quickUTM <- function(lon, lat, singlezone = TRUE, zone=NULL) {
  
  if(singlezone){
    if(is.null(zone)){ 
      lon0 <- mean(range(lon, na.rm=TRUE))
      zone <- (floor((lon0 + 180)/6) %% 60) + 1
    }
    xy <- project(cbind(lon, lat), paste0('+proj=utm +zone=', zone))
    attr(xy, 'projection') <- paste('UTM Zone:', zone)
  }
  
  if(!singlezone){
    zone <- (floor((lon + 180)/6) %% 60) + 1
    zones <- unique(zone)
    
    xy <- cbind(lon, lat)
    colnames(xy) <- c("x","y")
    flag <- rep(0, nrow(xy))
  
    for (z in zones) {
        indz <- which(zone == z)
        xy[indz,] <- project(xy[indz,, drop=F], paste0('+proj=utm +zone=', z))
        flag[indz] <- 1
    }
    
    xy <- cbind(xy, zone)
    
    if (any(flag == 0))
      warning('Some xy were not converted to UTMs')
    
    if (length(zones) > 1)
      attr(xy, 'projection') <- paste('Mixed UTM Zones:', min(zones), '-', max(zones)) else
        attr(xy, 'projection') <- paste('UTM Zone:', zones[1])
  }
  return(xy)
}

#quickUTM <- function(lon, lat){
#  ll <- data.frame(X = lon, Y = lat)
#  attributes(ll)$projection <- "LL"
#  return(convUL(ll, km=TRUE))
#}
