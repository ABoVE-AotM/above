##' Convert data frame to Movebank Env-Data request file
##' 
##' Takes a data frame of latitudes, longitudes and times and generates the strictly formatted data frame needed to upload to Env-Data to obtain covariates for movebank.  
##' 
##' @param {lats,lons} vectors of latitude and longitude 
##' @param {times} vectors of POSIX times
##' @param savefile whether to save a csv file
##' @param fileout name of csv file to save
##' @seealso createEnvDataGrid, createEnvDataRequest, uploadEnvDataRequest
##' 
##' @return Either nothing (if csv file saved) or the character string data frame with correct formatting. 
##' @examples 
##'  lats <- seq(38.8, 39.0, length = 40)
##'  lons <- seq(-77.12, -76.91, length = 40) 
##'  times <- seq(ymd("2010-12-31"), ymd("2011-12-31"), length = 40)
##'  example <- createEnvDataFrame(lats, lons, times, savefile = FALSE)
##'  head(example)
##' 
##' @export

createEnvDataFrame <- function(lats, lons, times, savefile = TRUE, fileout = NULL){  
  
  times <- times + hms("00:00:00.001")
  times.formatted <- paste0(as.character(times), ".000") 
  
  latlongtime.formatted <- data.frame(timestamp = times.formatted, 
                                      'location-long' = lons,
                                      'location-lat' = lats,
                                      'height-above-ellipsoid' = "")
  if(savefile){ 
    if(is.null(fileout))
      fileout <- readline(prompt="Please provide filename to save to: ")
    
    cat("Saving formatted data to", fileout, "\n")
    write.csv(latlongtime.formatted, file = fileout, row.names = FALSE)
  } else
  return(latlongtime.formatted)
}  


