##' Summary method for a track
##' 
##' @param object a AotM or AotM_df object, output from \code{\link{processMovedata}}
##' @return a data frame with a column of id's, number of observations, start time, duration and median observation interval of the track.
##' 
##' @S3method summary track
##' @example ./examples/example1.r

setMethod(f="summary", 
          signature=c(object="trackSPDF"),
          definition = function(object){
            ddply(object@data, 'id', function(df)
              with(df, data.frame(n = length(time), 
                                  start = min(time), 
                                  duration = round(difftime(max(time), min(time), unit="days")),
                                  dt.median = round(mean(difftime(time[-1], time[-length(time)], unit="hour")), 2))))
          })

setMethod(f="summary", 
          signature=c(object="track"),
          definition = function(object){
            ddply(object, 'id', function(df)
              with(df, data.frame(n = length(time), 
                                  start = min(time), 
                                  duration = round(difftime(max(time), min(time), unit="days")),
                                  dt.median = round(mean(difftime(time[-1], time[-length(time)], unit="hour")), 2))))
          })