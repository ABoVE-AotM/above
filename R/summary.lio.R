##' Summary output from a leave-individual-out object 
##' 
##' A summary function for leave-individual-out cross validation output
##'  
##' @author Peter Mahoney
##' @param lio An 'lio' class object.
##' @return Returns a data frame with median cross-validation metrics for all individuals in a leave-individual-out object.
##' 

summary.lio <- function(lio) {
  if (class(lio) != 'lio')
    stop("Input argument must be of class 'lio'.")
  
  o <- lapply(lio, function(x) x$cv)
  ou <- c()
  for (l in 1:length(o)) {
    ou <- rbind(ou, o[[l]])
  }
  row.names(ou) <- names(o)
  return(as.data.frame(ou))
}
