##' process Move data
##' 
##' Transforms a movebank object into an (optionally) daily averaged simplified data frame that is a "movetrack" class object.
##' 
##' @param movedata movement data - can be a \code{Move} object (or stack) from movebank
##' @param idcolumn name of the id column - depends on properties of the movebank data.  The default "individual_id" is often good.  Other options are "deployment_id" or maybe ""individual_id" ... this is confusing!
##' @param proj4 the projection (as a crs string) for input data.  If it is left empty and \code{movedata} is a \code{Move} object, it will carry over the projection from the original data.  If \code{movedata} is a data frame, it will use the "WGS84" projection, using the midpoint of the longitudes and latitudes in the data, i.e. (min(long,lat) + max(long,lat))/2.
##' @param projTo a crs string for (re)projecting input data.
##' @param keepCols vector of column names to retain in output (e.g., c('deployment_id', 'sex')).
##' @param dailymean whether or not to compute the daily mean - useful for the migration analysis.
##' 
##' @return Returns a data frame with columns "id", "time" (POSIXct), '"lon", "lat", "x", "y", "time", and any columns named in keepCols argument.  If getVT = TRUE, "z", "z.start", "z.end" (complex numbers indicating location), 'stepLength' (step length), 'phi' and 'theta' (absolute and relative turning angles, respectively), 't.start', 't.end', 't.mid' (numeric time), dT (difference in time over step), 'v' (velocity, default meters / hour), 't.mid.POSIX' (time mid point in POSIX), and if dailymean = TRUE, "day" (day since Jan 1 of first year) and "day.time". If returnOutliers = TRUE and returnSPDF = FALSE, a list of two elements containing the valid locations ($valid or list[[1]]) or outliers ($flaggedOutliers or list[[2]]).
##' 
##' @example ./examples/example1.r
##' @seealso \link{map.track}, \link{plot.track}, \link{SpatialPointsDataFrame}, \link{pointDistance}
##' @export



processMovedata <- function(movedata, xyNames = c('location_long', 'location_lat'), 
                            idcolumn = "individual_id", proj4 = NULL, projTo = NULL, keepCols = NULL, 
                            dailymean = FALSE) {
  
  # Define for later class instantiation
  dateDownloaded <- as.POSIXct(NA)
  mb_study <- as.character(NA)
  mb_citation <- as.character(NA)
  mb_license <- as.character(NA)
  
  if(inherits(movedata, "Move") | inherits(movedata, "MoveStack")){
    dateDownloaded <- movedata@dateCreation
    if (length(movedata@study) > 0) 
      mb_study <- movedata@study
    if (length(movedata@citation) > 0) 
      mb_citation <- movedata@citation
    if (length(movedata@license) > 0) 
      mb_license <- movedata@license
    if(is.null(proj4)) proj4 <- as.character(movedata@proj4string)
    movedata <- as(movedata, "data.frame")
  } else if(is.null(proj4)) {
    lon.center <- round(mean(range(movedata[, xyNames[1]])))
    lat.center <- round(mean(range(movedata[, xyNames[2]])))
    proj4 <- paste0("+proj=lcc +lat_1=",lat.center," +lat_2=",lat.center," +lon_0=",lon.center," +ellps=WGS84")
  }
  
  # if a variable call 'id' exists rename it to 'id_movebank'
  # so that we call the appropriate 'id' variable later
  if (any(names(movedata) == 'id') & idcolumn != 'id') {              
    movedata <- dplyr::rename(movedata, id_movebank = id)    
    names(movedata)[names(movedata) == idcolumn] <- "id"
  } else names(movedata)[names(movedata) == idcolumn] <- "id"
  
  if(!is.null(projTo)){
    #xy <- project(cbind(movedata$location_long, movedata$location_lat), projTo)
    xy <- project(as.matrix(movedata[, xyNames]), projTo)
    movedata$x <- xy[,1]
    movedata$y <- xy[,2]
  } else {
    xy <- quickUTM(movedata$location_long, movedata$location_lat)
    movedata$x <- xy[,1]
    movedata$y <- xy[,2]
    #projTo <- paste(attr(xy, 'projection'), 'Zone', attr(xy, 'zone'))
    projTo <- attr(xy, 'projection')
  }
  
  movedata.setup <- (mutate(movedata, id = factor(id), time = ymd_hms(timestamp)) %>% 
                       ddply("id", function(df){
                         day1 <- ymd(paste(year(df$time[1]), 1, 1))
                         mutate(df, day = as.numeric(floor(difftime(df$time, day1))),
                                day.date = ymd_hms(paste(year(df$time[1]),1,1,12,0,0)) + ddays(day),
                                lon = df[, xyNames[1]], 
                                lat = df[, xyNames[2]])
                       }))
  
  # Summarizing by day
  if(dailymean){
    md.processed <- ddply(movedata.setup, c("id", "day", "day.date"), summarize, 
                          time = mean(time),
                          lon = mean(lon), 
                          lat = mean(lat), 
                          x = mean(x), y = mean(y))
    if (!is.null(keepCols))
      md.processed <- merge(md.processed, 
                            unique(movedata.setup[, c('id', 'day.date', keepCols)]), 
                            by = c('id', 'day.date'), all.x = T)
  } else md.processed <- movedata.setup[,c("id", "time", "lon", "lat", "x", "y", keepCols)]
  
  # Building output
  p4s <- ifelse(is.null(projTo), proj4, projTo)
  out <- cbind(movebank_study = mb_study, md.processed)
  attr(out, 'projection') <- p4s 
  attr(out, 'dateDownloaded') <- dateDownloaded
  class(out) <- c('track', 'data.frame')
  
  return(out)
}
