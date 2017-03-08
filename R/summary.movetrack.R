##' Summary method for a movetrack
##' 
##' @param movetrack output of \code{\link{processMovedata}}
##' @return a data frame with a column of id's, number of observations, start time, duration and median observation interval of the track.
##' @S3method summary movetrack

summary.movetrack <- function(movetrack){
  ddply(movetrack, "id", function(df)
  with(df, data.frame(n = length(time), 
                      start = min(time), 
                      duration = round(difftime(max(time), min(time), unit="days")),
                      dt.median = round(mean(difftime(time[-1], time[-length(time)], unit="hour")), 2))))
}