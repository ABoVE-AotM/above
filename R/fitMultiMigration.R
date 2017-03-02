##' Fit multiple migrations
##' 
##' This function allows for the analysis of multiple migration in a single movement time series. 
##' 
##' @param data A processed daily averaged data frame, i.e. output of \code{\link{processMovedata}}
##' @param span1 A vector of *initial* times for analysis windows.  Should be of length *k*, where *k* is the number of migrations to fit.
##' @param span2 A vector of *final* times for analysis windows
##' @param plot Whether or not to visualize the output with \code{\link{plotMultimigrationFit}}
##' 
##' @return a data frame with the date, duration, estimated ranging areas of each of the migrations.  

fitMultiMigration <- function(data, span1, span2, plot = TRUE){
  id <- data$id[1]
  fits <- list()
  for(i in 1:length(span1)){
    myfit <- try(with(subset(me, day >= span1[i] & day <= span2[i]), 
                      estimate.shift(T = day, X = x/1e3, Y = y/1e3, model = "WN")))
    fits[[length(fits)+1]] <- list(span = c(span1 + span2), fit = myfit)
  }
  names(fits) <- paste0("M", 1:length(span1))
  
  # Collect all the migrations
  M.summary <- data.frame(id = id, span1 = span1, span2 = span2, 
                          ldply(fits, function(l){
                            if(inherits(l$fit, "try-error")) 
                              data.frame(t1 = NA, dt = NA, x1 = NA, x2 = NA, y1 = NA, y2 = NA, A = NA) else 
                                l$fit$p.hat
                          }) %>% 
                            mutate(t1 = finddate(t1, year(data$time[1])), 
                                   yday1 = yday(t1), 
                                   month = month(t1), 
                                   year = year(t1), 
                                   season = ifelse(month < 6, "spring", "fall")))
  if(plot)	plotMultimigrationFit(data, M.summary)	
  return(M.summary)
}


finddate <- function(t, year){
  day0 <- ymd(paste(year, 1, 1))
  as.POSIXct(day0 + ddays(round(t)))
}