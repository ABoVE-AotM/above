#' Select spans for multimigration analysis
#' 
#' @details This function provides an interactive interface for picking out analysis windows for a multi migration analysis. Basically - follow the instructions at the top of the figure
#' 
#' 
#' @param {time,x,y} migration data

selectSpans <- function(time, x, y){
  
  stop <- FALSE
  span.start <- c()
  span.end <- c()
  count <- 1
  
  while(!stop){

    par(mfrow=c(2,1), mar = c(0,0,0,0), oma = c(5,5,2,5))
    plot(time, x, type='o')
    plot(time, y, type='o')
    mtext(side = 4, outer = TRUE, "Click\nhere\nto\nstop\nselection", font = 2, las = 2, line = 0.5)
    
    title(paste("Click Start of Span", count), outer = TRUE)
    if(count > 1)
    rect(span.start, rep(min(y), count-1), span.end, rep(max(y), count-1), col=rainbow(count-1, alpha = 0.3), bor=NA)
    
    a <- locator(1)
    if(a$x > max(time))
      break() #stop <- TRUE
    
    abline(v = a$x, col=2, xpd=NA)
    span.start <- c(span.start, a$x)
    
    plot(time, x, type='o')
    plot(time, y, type='o')
     
    title(paste("Click End of Span", count), outer = TRUE)
    b <- locator(1)
    span.end <- c(span.end, b$x)
    rect(span.start, rep(min(y), count), span.end, rep(max(y), count), col=rainbow(count, alpha = 0.3), bor=NA)
    
    count <- count + 1
  }
  return(data.frame(span.start, span.end))
}



# setwd("c:/users/Guru/dropbox/Above/metamigration")
# load("./data/M3withElevation.rda")
# with(M3, selectSpans(day, x, y))
