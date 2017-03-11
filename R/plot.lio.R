##' Plot lio
##' 
##' A function for plotting observed vs. predicted values from a leave-individuals-out cross-validation procedure.
##' 
##' @author Peter Mahoney
##' @param lio An 'lio' class object.
##' @param numpoints Number of observed points to superimpose on density plots.
##' 
##' @return Plots the fit of the with-held individual (test data, observed fit) again the remaining sampled individuals (training data, predicted fit). a data frame with median cross-validation metrics for all individuals in a leave-individual-out object.
##' 

plot.lio <- function(lio, numpoints = Inf) {
  if (class(lio)[1] != 'lio')
    stop("Input argument must be of class 'lio'.")
  
  xmin <- min(unlist(lapply(lio, function (x) min(x$values[, 1]))))
  xmax <- max(unlist(lapply(lio, function (x) max(x$values[, 1]))))
  xlim <- c(xmin, xmax)
  
  ymin <- min(unlist(lapply(lio, function (x) min(x$values[, 2]))))
  ymax <- max(unlist(lapply(lio, function (x) max(x$values[, 2]))))
  ylim <- c(ymin, ymax)
  
  for (l in 1:length(lio)) {
    t <- lio[[l]]$values
    smoothScatter(t[, 1],t[, 2], main = paste(names(lio)[l], 'with-held'),  
                  xlab = "Standardized estimates (n-1)", 
                  ylab = "Standardized estimates (with-held animal)", 
                  nrpoints = numpoints,
                  xlim = xlim, ylim = ylim)
    abline(0, 1)                  
    par(ask = T)
  }
  par(ask = F)
}
