##' process Move data
##' 
##' Transforms a movebank object into an (optionally) daily averaged simplified data frame that is a "movetrack" class object.
##' 
##' @param movedata movement data - can be a \code{Move} object (or stack) from movebank
##' @param idcolumn name of the id column - depends on properties of the movebank data.  The default "individual_id" is often good.  Other options are "deployment_id" or maybe ""individual_id" ... this is confusing!
##' @param proj4 the projection for conversion to UTM.  If it is left empty and \code{movedata} is a \code{Move} object, it will carry over the projection from the original data.  If \code{movedata} is a data frame, it will use the "WGS84" projection, using the midpoint of the longitudes and latitudes in the data, i.e. (min(long,lat) + max(long,lat))/2.
##' @param dailymean whether or not to compute the daily mean - useful for the migration analysis
##' @param keepCols vector of column names to retain in output (e.g., c('deployment_id', 'sex')).
##' 
##' @return Returns a data frame with columns "id", "x", "y", (UTM easting/northing), "lat", "lon", "time", "day" (day since Jan 1 of first year), "day.time". 
##' 
##' @example ./examples/example1.r
##' @seealso \link{map.track}, \link{plot.movetrack}


processMovedata <- function(movedata, 
                            idcolumn = "individual_id",
                            proj4 = NULL,
                            dailymean = TRUE,
                            keepCols = NULL){
  
  if(inherits(movedata, "Move") | inherits(movedata, "MoveStack")){
    if(is.null(proj4)) proj4 <- as.character(movedata@proj4string)
    movedata <- as(movedata, "data.frame")
  } else if(is.null(proj4)) {
    lon.center <- round(mean(range(movedata$location_long)))
    lat.center <- round(mean(range(movedata$location_lat)))
    proj4 <- paste0("+proj=lcc +lat_1=",lat.center," +lat_2=",lat.center," +lon_0=",lon.center," +ellps=WGS84")
  }
  
  # if a variable call 'id' exists rename it to 'id_movebank'
  # so that we call the appropriate 'id' variable later
  
  if (any(names(movedata) == 'id') & idcolumn != 'id') {              
    movedata <- dplyr::rename(movedata, id_movebank = id)    
    names(movedata)[names(movedata) == idcolumn] <- "id"
  }  else names(movedata)[names(movedata) == idcolumn] <- "id"
  

  if(!("utm.easting" %in% names(movedata))){
    xy <- project(cbind(movedata$location_long, movedata$location_lat), proj4)
    movedata$x <- xy[,1]
    movedata$y <- xy[,2]
  } else movedata <- rename(utm.easting = "x", utm.northing = "y")
  
  movedata.setup <- (mutate(movedata, id = factor(id), time = ymd_hms(timestamp)) %>% 
    ddply("id", function(df){
      day1 <- ymd(paste(year(df$time[1]), 1, 1))
      mutate(df, day = as.numeric(floor(difftime(df$time, day1))),
             day.date = ymd_hms(paste(year(df$time[1]),1,1,12,0,0)) + ddays(day),
             lon = location_long, 
             lat = location_lat)
    }))
  
  if(dailymean){
    movedata.processed <- ddply(movedata.setup, c("id", "day", "day.date"), summarize, 
                                  time = mean(time),
                                  lon = mean(lon), 
                                  lat = mean(lat), 
                                  x = mean(x), y = mean(y))
    if (!is.null(keepCols))
      movedata.processed <- merge(movedata.processed, 
                                  unique(movedata.setup[, c('id', 'day.date', keepCols)]), 
                                  by = c('id', 'day.date'), all.x = T)
    } else movedata.processed <- movedata.setup[,c("id", "time", "lon", "lat", "x", "y", keepCols)]
  
  class(movedata.processed) <- c("movetrack", "data.frame")
  
  return(movedata.processed)
}
