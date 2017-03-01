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
  day0 + ddays(round(t))
}


plotMultimigrationFit <- function(data, M.summary){

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

processMovedata <- function(d){
  d <- rename(d, c(individual.local.identifier = "id", 
                   utm.easting = "x", utm.northing = "y")) %>% 
    mutate(id = factor(id), time = ymd_hms(timestamp)) %>% 
    ddply("id", function(df){
      day1 <- ymd(paste(year(df$time[1]), 1, 1))
      mutate(df, day = as.numeric(floor(difftime(df$time, day1))),
             day.date = ymd_hms(paste(year(df$time[1]),1,1,12,0,0)) + ddays(day))
    }) %>% 
    ddply(c("id", "day", "day.date"), summarize, 
          x = mean(x), y = mean(y),  
          lon = mean(location.long), 
          lat = mean(location.lat), 
          time = mean(time))
}

scan.track.z <- function(time, x, y, z, title = "",...)
{
  par(mar = c(0,3,0,0), oma = c(4,4,2,2))
  layout(rbind(c(1,2), c(1,3), c(1,4))) 
  
  MakeLetter <- function(a, where="topleft", cex=2)
    legend(where, pt.cex=0, bty="n", title=a, cex=cex, legend=NA)
  
  plot(x,y,asp=1, type="o", pch=19, col=rgb(z/max(z),(1-z/(max(z))),0,.5), cex=0.5, ...); MakeLetter(title)
  plot(time,x, type="o", pch=19, col=rgb(0,0,0,.5), xaxt="n", xlab="", cex=0.5, ...); MakeLetter("X")
  plot(time,y, type="o", pch=19, col=rgb(0,0,0,.5), xaxt="n", xlab="", cex=0.5, ...); MakeLetter("Y")
  plot(time,z, type="o", pch=19, col=rgb(0,0,0,.5), cex=0.5, ...); MakeLetter("Z")
}