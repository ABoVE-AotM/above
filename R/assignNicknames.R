##' Assign nicknames
##' 
##' Most of the ID's of individuals are extremely unwieldly multi-digit codes.  This function gives nicer (more memorable) numbered short codes ... like "Moose1", "Moose2", etc.
##' 
##' @param data typically - a "track" object., but really, any data frame with an "id" column.
##' @param string a basic string for a nickname, like "Moose" 
##' 
##' @return the data, with an additional column called "nickname" with the numbered short name.
##' @export

assignNicknames <- function(data, string = "Animal"){
  data <- mutate(data, nickname = factor(id))
  n.ind <- length(levels(data$nickname))
  levels(data$nickname) <- paste0(string, 1:n.ind)
  return(data)
}