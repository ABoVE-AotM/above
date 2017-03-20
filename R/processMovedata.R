##' process Move data
##' 
##' Transforms a movebank object into an (optionally) daily averaged simplified data frame that is a "movetrack" class object.
##' 
##' @param movedata movement data - can be a \code{Move} object (or stack) from movebank
##' @param idcolumn name of the id column - depends on properties of the movebank data.  The default "individual_id" is often good.  Other options are "deployment_id" or maybe ""individual_id" ... this is confusing!
##' @param proj4 the projection (as a crs string) for input data.  If it is left empty and \code{movedata} is a \code{Move} object, it will carry over the projection from the original data.  If \code{movedata} is a data frame, it will use the "WGS84" projection, using the midpoint of the longitudes and latitudes in the data, i.e. (min(long,lat) + max(long,lat))/2.
##' @param projTo a crs string for (re)projecting input data.
##' @param keepCols vector of column names to retain in output (e.g., c('deployment_id', 'sex')).
##' @param getVT a logical indicating whether or not to estimate trajectory statistics (default = TRUE).
##' @param geoDist a logical (default is FALSE) indicating whether or not to estimate distance using geographic coordinates along an ellipsoid (see pointDistance in raster package).
##' @param units if getVT = TRUE, a string representing the time units used to define time periods (default = 'hour').
##' @param returnSPDF if the returned object should be in a SPDF format.
##' @param dailymean whether or not to compute the daily mean - useful for the migration analysis.
##' @param returnOutliers a logical indicating whether or not to return flagged outliers within the Movebank data set.
##' 
##' @return Returns a data frame with columns "id", "time" (POSIXct), '"lon", "lat", "x", "y", "time", and any columns named in keepCols argument.  If getVT = TRUE, "z", "z.start", "z.end" (complex numbers indicating location), 'stepLength' (step length), 'phi' and 'theta' (absolute and relative turning angles, respectively), 't.start', 't.end', 't.mid' (numeric time), dT (difference in time over step), 'v' (velocity, default meters / hour), 't.mid.POSIX' (time mid point in POSIX), and if dailymean = TRUE, "day" (day since Jan 1 of first year) and "day.time". If returnOutliers = TRUE and returnSPDF = FALSE, a list of two elements containing the valid locations ($valid or list[[1]]) or outliers ($flaggedOutliers or list[[2]]).
##' 
##' @example ./examples/example1.r
##' @seealso \link{map.track}, \link{plot.movetrack}, \link{SpatialPointsDataFrame}, \link{pointDistance}


setGeneric("processMovedata", function(movedata, xyNames = c('location_long', 'location_lat'), 
                                       idcolumn = "individual_id", proj4 = NULL, projTo = NULL, keepCols = NULL,
                                       getVT = FALSE, geoDist = FALSE, units = 'hour', returnSPDF = FALSE, 
                                       dailymean = FALSE, returnOutliers = FALSE) standardGeneric("processMovedata"))
setMethod(f="processMovedata", 
          signature=c(movedata=".OptionalMove"),
          definition = function(movedata, xyNames, idcolumn, proj4, projTo, keepCols, getVT, geoDist, units,
                                returnSPDF, dailymean, returnOutliers){
            
            if (returnOutliers) {
              if (length(movedata@trackIdUnUsedRecords) > 0) {
                flaggedOutliers <- data.frame(local_identifier = movedata@trackIdUnUsedRecords, 
                                              movedata@dataUnUsedRecords)
              } else returnOutliers = FALSE
            }
            
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
              movedata$x <- movedata[, xyNames[1]]
              movedata$y <- movedata[, xyNames[2]]
            }
            
            movedata.setup <- (mutate(movedata, id = factor(id), time = ymd_hms(timestamp)) %>% 
                                 ddply("id", function(df){
                                   day1 <- ymd(paste(year(df$time[1]), 1, 1))
                                   mutate(df, day = as.numeric(floor(difftime(df$time, day1))),
                                          day.date = ymd_hms(paste(year(df$time[1]),1,1,12,0,0)) + ddays(day),
                                          lon = df[, xyNames[1]], 
                                          lat = df[, xyNames[2]])
                                 }))
            
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
            
            if (getVT) {
              if (grepl('+proj=longlat', proj4) & is.null(projTo) & !geoDist)
                warning('Estimating distance using LongLat without accounting for ellipsoid, stepL and v are likely biased. Consider changing geoDist argument to TRUE.')
              
              if (is.null(units))
                stop('If estimating trajectories, please specify a time unit.')
              
              ids <- unique(md.processed$id)
              mo <- c()
              for (i in 1:length(unique(ids))) {
                mi <- subset(md.processed, id == ids[i])
                mi$z <- mi$x + (0+1i) * mi$x
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
                  time <- time/ifelse(units == "sec", 1, 
                                      ifelse(units == "min", 60, 
                                             ifelse(units == "hour", 60*60, 
                                                    ifelse(units == "day", 60*60*24, 
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
                #mo <- rbind(mo, cbind(mi, trajTab))
                mo <- rbind(mo, trajTab)
              }
              #md.processed <- mo
            } else mo <- NULL
            
            if (returnSPDF) {
              p4s <- CRS(ifelse(is.null(projTo), proj4, projTo))
              md.processed <- SpatialPointsDataFrame(md.processed[, c('x', 'y')], data = md.processed, proj4string = p4s)
              out <- new("trackSPDF", md.processed, VT = mo, dateDownloaded = dateDownloaded, movebank_study = mb_study, 
                         movebank_citation = mb_citation, movebank_license = mb_license)
            } else {
              p4s <- ifelse(is.null(projTo), proj4, projTo)
              if (getVT)
                out <- cbind(movebank_study = mb_study, md.processed, mo, proj4string = p4s,  
                                     dateDownloaded = dateDownloaded) else
                                       out <- cbind(movebank_study = mb_study, md.processed, proj4string = p4s,  
                                                             dateDownloaded = dateDownloaded)
              class(out) <- c('track', 'data.frame')
            }
            
            if (returnOutliers & returnSPDF) {
              out@flaggedOutliers <- flaggedOutliers
            } else if (returnOutliers) {
              out <- list(valid = out, flaggedOutliers = flaggedOutliers) 
            }
            
            return(out)
          })
