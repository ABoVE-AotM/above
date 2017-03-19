#' ggmap of a track
#' 
#' This is a quick wrapper around the \code{\link{ggmap}} function that plots a \code{track} object (including with multiple individuals) and
#' 

#' @param movetrack a \code{movetrack} class object, or any data-frame that contains (at least) three columns labeled "time", "x" and "y"
#' @param zoom the zoom level, an integer from 3 (continent) to 21 (building)
#' @param individually whether to produce plots individually (TRUE) or as a population (FALSE; default).
#' @param exportPDF a logical indicating whether or not to export plots as a PDF (default = FALSE).
#' @param ... additional parameters to pass to \code{\link{ggmap}}
#' 
#' @return if exportPDF = TRUE, will return a single PDF of all individuals or a population to your working directory.
#' 
#' @example ./examples/example1.r

setGeneric("map", function(movetrack, zoom = 6, individually = FALSE, id = NULL, exportPDF = FALSE, ...)
                    standardGeneric("map"))
setMethod(f="map", 
          signature=c(movetrack = 'trackSPDF'),
          definition = function(movetrack, zoom, individually, id, exportPDF, ...){
            
            if (individually) {
              if (is.null(id)) 
                ids <- unique(movetrack@data$id) else 
                  ids <- id
              
                if (exportPDF)
                  pdf(paste0('maptracks_', movetrack@movebank_study, '.pdf'), onefile = TRUE, width = 11, height = 8.5)
                
                for (i in 1:length(ids)) {
                  di <- subset(movetrack@data, id == ids[i])
                  
                  lon.center <- mean(range(di$lon))
                  lat.center <- mean(range(di$lat))
                  
                  basemap <- get_map(location = c(lon.center, lat.center), 
                                     zoom = zoom, ...)
                  
                  print(ggmap(basemap) + geom_point(data = di, mapping = aes(x = lon, y = lat, col=id)) + 
                    geom_path() + coord_map() + labs(x = "Longitude", y = "Latitude"))
                  
                  if ((length(ids) > 1 & i != length(ids)) & !exportPDF)
                    par(ask=T) else par(ask=F)
                }
                
                if (exportPDF)
                  dev.off()
            } else {
              if (exportPDF)
                pdf(paste0('maptracks_', movetrack@movebank_study, '.pdf'), onefile = TRUE, width = 11, height = 8.5)
              
              di <- movetrack@data
                
              lon.center <- mean(range(di$lon))
              lat.center <- mean(range(di$lat))
                
              basemap <- get_map(location = c(lon.center, lat.center), 
                                 zoom = zoom, ...)
                
              print(ggmap(basemap) + geom_point(data = di, mapping = aes(x = lon, y = lat, col=id)) + 
                  geom_path() + coord_map() + labs(x = "Longitude", y = "Latitude"))
              
              if (exportPDF)
                dev.off()              
            }
              
          })
