#' ggmap of a track
#' 
#' This is a wrapper around the \code{\link{ggmap}} function that plots a \code{movetrack} object (including with multiple individuals).
#' 

#' @param movetrack a \code{movetrack} class object, or any data-frame that contains (at least) three columns labeled "time", "x" and "y"
#' @param id a vector of individuals to map (default = NULL - plots all individuals)
#' @param individually whether to produce plots individually (TRUE) or as a population (FALSE; default).
#' @param projection one of the options from \link{\code{mapproject}}.  Default - "albers", which seems to be best for  (must be character string). 
#' @param print whether or not to print map.  Default TRUE
#' @param exportPDF a logical indicating whether or not to export plots as a PDF (default = FALSE).
#' @param ... additional parameters to pass to \code{\link{ggmap}}
#' @param zoom the zoom level - an integer from 3 (continent) to 21 (building) - or (by default) automatically selected as one level lower than the output of \code{\link{calc_zoom}}. 
#' @param luminance the default colors are richer than the pale ggplot palette which is often hard to see on maps.
#' 
#' @return if \code{print = FALSE}, will return the ggmap object, otherwise, returns nothing.  If \code{exportPDF = TRUE} outputs a single PDF of all individuals or a population to the working directory.
#' 
#' @example ./examples/example1.r
#' @export

map <- function (movetrack, ...) {
  UseMethod("map", movetrack)
}

#' @export
map.movetrack <- function (movetrack, id = NULL, individually = FALSE, 
                           projection = "albers", print = TRUE,
                           exportPDF = FALSE, filename = "maptracks", ..., zoom = NULL, luminance = 40) {
  
  mymap <- NULL
  lon.center <- mean(range(movetrack$lon))
  lat.center <- mean(range(movetrack$lat))
  
  proj.params <- c(lat.center, lon.center)
  if(projection == "mercator") proj.params <- c()
  
  if(is.null(zoom)){
    zoom <- with(movetrack, calc_zoom(range(lon, na.rm= TRUE), range(lat, na.rm=TRUE))) - 1
    cat(paste("automatically selecting zoom", zoom, "\n"))
  }
  
    if (individually) {
    if (is.null(id)) 
      ids <- unique(movetrack$id) else 
        ids <- id
      
      if (exportPDF)
        pdf(paste0('maptracks_', movetrack$movebank_study[1], '.pdf'), onefile = TRUE, width = 11, height = 8.5)
      
      for (i in 1:length(ids)) {
        di <- subset(movetrack, id == ids[i])
        
        lon.center <- mean(range(di$lon))
        lat.center <- mean(range(di$lat))
        basemap <- get_map(location = c(lon.center, lat.center), 
                           zoom = zoom, ...)
        
        print(ggmap(basemap) + geom_point(data = di, mapping = aes(x = lon, y = lat, col=id)) + 
                geom_path(data = di, mapping = aes(x = lon, y = lat, col=id)) + 
                coord_map(projection = projection, parameters = proj.params) + scale_colour_hue(l = luminance) + 
                labs(x = "Longitude", y = "Latitude"))
        
        if ((length(ids) > 1 & i != length(ids)) & !exportPDF)
          par(ask=T) else par(ask=F)
      }
      
      if (exportPDF) dev.off()
  } else {
    
    di <- movetrack
    
    basemap <- get_map(location = c(lon.center, lat.center), 
                       zoom = zoom, ...)
    
    mymap <- ggmap(basemap) + geom_point(data = di, mapping = aes(x = lon, y = lat, col=id)) + 
            geom_path(data = di, aes(x = lon, y = lat, col=id)) + scale_colour_hue(l = luminance) + 
            coord_map(projection = projection, parameters =  proj.params) + labs(x = "Longitude", y = "Latitude")
    if(print){  print(mymap); mymap = NULL}
    
    if (exportPDF){
      pdf(paste0(filename, '.pdf'), onefile = TRUE, width = 11, height = 8.5)
      print(mymap)
      dev.off()              
    }
  }
  
  return(mymap)
}
