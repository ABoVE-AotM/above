##' process Move data
##' 
##' Transforms raw-ish move data into a daily averaged move data.
##' 
##' @param movedata movement data - can be a \code{Move} object (or stack) from movebank
##' @param idcolumn name of the id column - depends on properties of the movebank data.  The default "individual.local.identifier" is often good.  Other options are "deployment_id" or maybe ""individual_id" ... this is confusing!
##' @param proj4 the projection for conversion to UTM.  If it is left empty and \code{movedata} is a \code{Move} object, it will carry over the projection from the original data.  If \code{movedata} is a data frame, it will use the "WGS84" projection, using the midpoint of the longitudes and latitudes in the data, i.e. (min(long,lat) + max(long,lat))/2.
##' @param dailymean whether or not to compute the daily mean - useful for the migration analysis
##' @return   
##' 
##' @example ./examples/example1.r


processMovedata <- function(movedata, 
                            idcolumn = "individual.local.identifier",
                            proj4 = NULL,
                            dailymean = TRUE){
  
  if(inherits(movedata, "Move") | inherits(movedata, "MoveStack")){
    if(is.null(proj4)) proj4 <- as.character(movedata@proj4string)
    movedata <- as.data.frame(movedata)
  } else if(is.null(proj4)) {
    lon.center <- round(mean(range(movedata$location_long)))
    lat.center <- round(mean(range(movedata$location_lat)))
    proj4 <- paste0("+proj=lcc +lat_1=",lat.center," +lat_2=",lat.center," +lon_0=",lon.center," +ellps=WGS84")
  }

  names(movedata)[names(movedata) == idcolumn] <- "id"

  if(!("utm.easting" %in% names(movedata))){
    xy <- project(cbind(movedata$location_long, movedata$location_lat), proj4)
    movedata$x <- xy[,1]
    movedata$y <- xy[,2]
  } else movedata <- rename(utm.easting = "x", utm.northing = "y")
  
  movedata.processed <- (mutate(movedata, id = factor(id), time = ymd_hms(timestamp)) %>% 
    ddply("id", function(df){
      day1 <- ymd(paste(year(df$time[1]), 1, 1))
      mutate(df, day = as.numeric(floor(difftime(df$time, day1))),
             day.date = ymd_hms(paste(year(df$time[1]),1,1,12,0,0)) + ddays(day),
             lon = location_long, 
             lat = location_lat)
    }))[,c("id", "day", "day.date", "time", "lon", "lat", "x", "y")]
  
  if(dailymean)
    movedata.processed <-   ddply(movedata.processed, c("id", "day", "day.date"), summarize, 
                                  time = mean(time),
                                  lon = mean(lon), 
                                  lat = mean(lat), 
                                  x = mean(x), y = mean(y))
  return(movedata.processed)
}
