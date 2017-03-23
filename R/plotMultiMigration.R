##' Plot Multiple Migration Fit 
##' 
##' This function plots a multiple migration fit using the summary output of \code{\link{fitMultiMigration}}. 
##' 
##' @param data A processed daily averaged data frame, i.e. output of \code{\link{processMovedata}}
##' @param M.summary A data frame with the multi-migration summary (output of \code{\link{fitMultiMigration}})
##' 
##' @example ./examples/example3.r



plotMultiMigration <- function(data, M.summary, ...) {   
  
  if(!inherits(data, 'track') | (inherits(data, 'track') & !all(c('day', 'day.date') %in% names(data)))) 
    stop("Data must be of class 'track' with processMovedata(..., dailymean=TRUE)")
  
  layout(rbind(c(1,2), c(1,3)))
  par(mar = c(0,4,0,0), oma = c(4,4,2,2))
  
  with(data, plot(x/1000, y/1000, type="o", asp=1, pch = 21, bg = rgb(1:length(x)/length(x), 1:length(x)/length(x), 1:length(x)/length(x)), col = "grey", cex=0.8))
  
  with(subset(M.summary, season == "spring"),{
    points(c(x1, x2), c(y1, y2), col="darkgreen", pch = 4, cex=2, lwd=2)
    lines(c(x1, x2), c(y1, y2), col="darkgreen", lwd=2)})
  
  with(subset(M.summary, season == "fall"),{
    points(c(x1, x2), c(y1, y2), col="red", pch = 4, cex=2, lwd=2)
    lines(c(x1, x2), c(y1, y2), col="red", lwd=2)})
  
  with(data, plot(time, x/1000, type="o", pch = 21, bg = rgb(1:length(x)/length(x), 1:length(x)/length(x), 1:length(x)/length(x)), col = "grey", cex=0.8, xaxt="n", xlab=""))
  with(M.summary, segments(t1, x1, t1 + ddays(dt), x2, col="blue", lwd=2))
  with(M.summary, segments((t1 + ddays(dt))[-length(t1)], x2[-length(x2)], t1[-1], x1[-1], col="blue", lwd=2))
  with(M.summary, segments(min(data$time), x1[1], t1[1], x1[1], col="blue", lwd=2))
  with(M.summary, segments((t1+ddays(dt))[length(t1)], x2[length(x2)], max(data$time), x2[length(x2)], col="blue", lwd=2))
  
  with(data, plot(time, y/1000, type="o", pch = 21, bg = rgb(1:length(y)/length(y), 1:length(y)/length(y), 1:length(y)/length(y)), col = "grey", cex=0.8))
  with(M.summary, segments(t1, y1, t1 + ddays(dt), y2, col="blue", lwd=2))
  with(M.summary, segments((t1 + ddays(dt))[-length(t1)], y2[-length(y2)], t1[-1], y1[-1], col="blue", lwd=2))
  with(M.summary, segments(min(data$time), y1[1], t1[1], y1[1], col="blue", lwd=2))
  with(M.summary, segments((t1+ddays(dt))[length(t1)], y2[length(y2)], max(data$time), y2[length(y2)], col="blue", lwd=2))
}

#setGeneric("plotMultiMigration", function(data, M.summary, ...)
#  standardGeneric("plotMultiMigration"))

#setMethod(f="plotMultiMigration", 
#          signature=c(data='trackSPDF'),
#          definition = function(data, M.summary, ...){ 
#            data <- data@data 
#            callGeneric()
 #         })
