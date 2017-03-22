##' Quick UTM
##' 
##' Uses the \code{\link{convUL}} function in \code{\link{PBSmapping}} to convert longitude and latitude to UTM.  This funciton is buried in \code{\link{processMovedata}}
##' 
##' @param {lon,lat} self-explanatory
##' 
##' @return data frame with columns X and Y in automatically selected zone. 
##' 


quickUTM <- function(lon, lat){
  ll <- data.frame(X = lon, Y = lat)
  attributes(ll)$projection <- "LL"
  return(convUL(ll, km=TRUE))
}
