#' ggmap of a track
#' 
#' This is a quick wrapper around the \code{\link{ggmap}} function that plots a movetrack object (including with multiple individuals) and
#' 

#' @param movetrack a \code{movetrack} class object, or any data-frame that contains (at least) three columns labeled "time", "x" and "y"
#' @param zoom the zoom level, an integer from 3 (continent) to 21 (building)
#' @param ... additional parameters to pass to \code{\link{ggmap}}
#' @export

map.track <- function(movetrack, zoom = 6, ...)
{
  lon.center <- mean(range(movetrack$lon))
  lat.center <- mean(range(movetrack$lat))
    
  basemap <- get_map(location = c(lon.center, lat.center), 
                        zoom = zoom, ...)
  ggmap(basemap) + geom_point(data = movetrack, mapping = aes(x = lon, y = lat, col=id)) + 
    geom_path() + coord_map() + labs(x = "Longitude", y = "Latitude")
}
