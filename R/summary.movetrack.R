##' Summary method for a track
##' 
##' @param object a 'movetrack' object, output from \code{\link{processMovedata}}
##' @return a data frame with a column of id's, number of observations, start time, duration and median observation interval of the track.
##' 
##' @example ./examples/example1.r
##' @export
##' 
summary.movetrack <- function(object){
  m <- attributes(object)$metadata
  if(!is.null(m)) 
    cat(paste(paste(names(m), unlist(m), sep = ": "), collapse = "\n"),"\n")
  
  ddply(object, 'id', function(df)
              with(df, data.frame(n = length(time),
                                  start = min(time),
                                  duration = round(difftime(max(time), min(time), unit="days")),
                                  dt.median = round(mean(difftime(time[-1], time[-length(time)], unit="hour")), 2))))
}

## NOT NECESSARY I THINK
#summary <- function (movetrack, ...) {
#  UseMethod("summary", movetrack)
#}
