#' Quick plot of a track (against x-y-time)
#' 
#' Plotting x-y, time-x, time-y scan of a track.  This function will take x, y, and time coordinates or a \code{track} class object
#' 
#' @param movetrack a \code{movetrack} class object, or any data-frame that contains (at least) three columns labeled "time", "x" and "y"
#' @param ... options to be passed to plot functions
#' @S3method plot movetrack

plot.movetrack <- function(movetrack=NULL, id = NULL, time, x, y=NULL, layout = NULL, auto.par = NULL,  ...)
{
 if(is.null(id)) id <- movetrack$id[1]
 layout(cbind(1:1,2:3))
 par(mar = c(0,4,0,0), oma = c(4,0,4,4), xpd = NA)
 with(subset(movetrack, id == id), {
  plot(x,y,asp=1, type="o", pch=19, col=rgb(0,0,0,.5), cex=0.5, ...)
  plot(time,x, type="o", pch=19, col=rgb(0,0,0,.5), xaxt="n", xlab="", cex=0.5, ...)
  plot(time,y, type="o", pch=19, col=rgb(0,0,0,.5), cex=0.5, ...)
  title(id[1], outer = TRUE, xpd=NA)
 })
}
