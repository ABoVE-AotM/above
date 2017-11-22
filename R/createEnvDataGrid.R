##' Create gridded data for querying Movebank Env-Data 
##' 
##' Takes a vector of latitudes and longitudes (typically evenly spaced) and a vector of times and generates the strictly formatted data frame needed to upload to Env-Data to obtain covariates for movebank.  Essentially, an R-based substitute for the "gridded data" tool. 
##' 
##' @param {lats,lons} vectors of latitude and longitude for the desired grid.  Can also be a single location. 
##' @param {start,finish} vectors of POSIX times of start and finish for the query. 
##' @param dt time interval between desired time points. 
##' @param savefile whether to save a csv file
##' @param fileout name of csv file to save
##' @seealso createEnvDataRequest, uploadEnvDataRequest
##' 
##' @return Either nothing (if csv file saved) or the character string data frame with correct formatting. 
##' @examples 
##'  lats <- seq(38.8, 39.0, length = 40)
##'  lons <- seq(-77.12, -76.91, length = 40) 
##'  start <- ymd("2014-01-01")
##'  finish <- ymd("2014-12-31")
##'  dt <- ddays(20)
##'  example <- createEnvDataGrid(lats, lons, start, finish, dt, savefile = FALSE)
##'  head(example)
##' 
##' @export

createEnvDataGrid <- function(lats, lons, start, finish = start, dt = 0, 
                              savefile = TRUE, fileout = NULL){  
  
  if(dt == as.duration(0)) times <- start + hms("00:00:00.001") else
  times <- seq(start + hms("00:00:00.001"), finish + hms("00:00:00.001"), by = dt)
  times.formatted <- paste0(as.character(times), ".000") 
  
  latlontime <- expand.grid(lats, lons, times.formatted) 
  latlongtime.formatted <- data.frame(timestamp = latlontime$Var3, 
                             'location-long' = latlontime$Var2,
                             'location-lat' = latlontime$Var1,
                             'height-above-ellipsoid' = "")
  if(savefile){ 
    if(is.null(fileout))
      fileout <- readline(prompt="Please provide filename to save to: ")
      
    cat("Saving formatted data to", fileout, "\n")
    write.csv(latlongtime.formatted, file = fileout, row.names = FALSE)
  } else
  return(latlongtime.formatted)
}  
  
  
  