##' Get VT
##' 
##' Generates vector (i.e., movement) statistics for a track object.
##' 
##' @title Generate vector statistics
##' @param track a track object generated using \code{processMovedata}
##' @param units one of ('secs', 'mins', 'hours', 'days') used to identify the unit of time for output (default = 'hours').
##' @param geoDist to estimate step lengths using the x/y coordinate units (FALSE) or 
##' the WGS ellipsoidal distances using LonLat (uses the function pointDistance(..., lonlat=TRUE) from raster package).
##' 
##' @return Returns the original data frame with "z", "z.start", "z.end" (complex numbers indicating location), 
##' 'stepLength' (step length), 'phi' and 'theta' (absolute and relative turning angles, respectively), 't.start', 
##' 't.end', 't.mid' (numeric time), dT (difference in time over step), 'v' (velocity, default meters / hour), and
##' 't.mid.POSIX' (time mid point in POSIX).
##' 
##' @example ./examples/example_getVT.r
##' @seealso \link{processMovedata}, \link{pointDistance}
##' @export

getVT <- function (track, ...) {
  UseMethod("getVT", track)
}

##' @export
getVT.track <- function (track, units = 'hours', geoDist = FALSE) {
  if(grepl('+proj=longlat', attr(track, 'metadata')$projection))
    stop('x/y in track object should be projected with a meaningful distance unit.')
  if (is.null(units))
    stop('If estimating trajectories, please specify a time unit.')
  
  vto <- c()
  ids <- unique(track$id)
  for (i in 1:length(unique(ids))) {
    mi <- subset(track, id == ids[i])
    mi$z <- mi$x + (0+1i) * mi$y
    z.start <- mi$z[-nrow(mi)]
    z.end <- mi$z[-1]
    if (!geoDist)
      stepL <- Mod(diff(mi$z)) else
        stepL <- pointDistance(as.matrix(mi[-nrow(mi), c('lon', 'lat')]),
                               as.matrix(mi[-1, c('lon', 'lat')]), longlat = TRUE)
    phi <- Arg(diff(mi$z))
    theta <- c(NA, diff(phi))
    
    t.mid.POSIX <- mi$time[-nrow(mi)] + diff(mi$time)/2
    
    if(inherits(mi$time, "POSIXt")) {  
      time <- as.numeric(mi$time-mi$time[1])
      time <- time/ifelse(units == "secs", 1, 
                          ifelse(units == "mins", 60, 
                                 ifelse(units == "hours", 60*60, 
                                        ifelse(units == "days", 60*60*24, 
                                               stop("Invalid time unit.")))))
    }
    
    t.start <- time[-nrow(mi)]
    t.end <- time[-1]
    dT <- t.end-t.start
    v <- stepL/as.vector(dT)
    t.mid <- (t.start + t.end)/2
    trajTab <- data.frame(z.start, z.end, stepL, phi, theta, 
                          t.start, t.end, t.mid, dT, v, t.mid.POSIX)
    trajTab <- rbind(NA, trajTab)
    mi <- cbind(mi, trajTab)
    vto <- rbind(vto, mi)
  }
  return(vto)
}
