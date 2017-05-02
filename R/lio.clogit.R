##' Leave-individuals-out for SSF
##' 
##' A function for generating leave-individuals-out cross-validation output for a step-selection model.
##'  
##' @author Peter Mahoney
##' @param dat a movetrack object with pseudo-absences points (.e., available; Used = 0) and used points (Used = 1) stratified by step and annotated with representative covariates.
##' @param form a formula object with the clogit formula to be evaluated using LIO cross-validation.
##' @param thin an integer representing the amount of thinning required before performing the cross-validation (not recommended and potentially biases results).
##' @param cluster a character string for the name of the clustering variable (e.g., 'ID_year').
##' @param ID a character string for the name of the animal IDs. Used to partition individuals for the LIO procedure.
##' @param inPar Boolean for whether or not procedure should be performed in parallel (TRUE by default).
##' @param ncores if inPar = TRUE, ncores will define the number of cpu cores to use.
##' 
##' @return Returns a list of lists indexed by individual.  Nested within each individual's element is a second list containing the fitted and observed values (obj[[i]]$values) and cross-validation metrics (obj[[i]]$cv).
##' @seealso \link{processMovedata}
##' @export
##' 

# LEAVE-ONE-OUT VALIDATION 
lio.clogit <- function(dat, form, thin = NULL, cluster = 'ID_year', ID = 'AnimalID', 
                       inPar = TRUE, ncores = NULL) 
{
  # Reduced sample size
  # Used to increase speed of processing time
  if (is.null(thin)) {
    subda <- dat 
    } else {
    strats <- seq(min(dat$Stratum), max(dat$Stratum), by = thin)
    subda <- dat[dat$Stratum %in% strats, ]
    }
  
  if (cluster == ID) {
    sform <- as.character(form)
    sform2 <- strsplit(sform[3], '[+]')[[1]]
    sform <- formula(paste0(sform[2], sform[1], paste(sform2[-grep('cluster[(]', sform2)], collapse='+')))
  } else sform <- form
  
  # fitting the model with one missing animal
  uE <- unique(subda[, ID])
  out <- list()
  
  if (inPar) {
    if (is.null(ncores))
      cl <- makeCluster(detectCores() - 1)
    else
      cl <- makeCluster(ncores)
    
    clusterExport(cl, varlist = list('subda', 'ID', 'cluster', 'form', 'sform', 'gof'), envir=environment())
    clusterEvalQ(cl, library(survival))
    
    out <- parLapply(cl, uE, function (id) {
      datless <- subda[subda[,ID] != id,]
      datonly <- subda[subda[,ID] == id,]
      
      if (length(levels(as.factor(datonly[, cluster]))) <= 1) {
        sform <- as.character(form)
        sform2 <- strsplit(sform[3], '[+]')[[1]]
        sform <- formula(paste0(sform[2], sform[1], paste(sform2[-grep('cluster[(]', sform2)], collapse='+')))
      }
      
      ## Generate models
      # Flag if singularity/convergence warnings
      # model w/ all but single individual
      flag <- 0
      tryCatch(modTrain <- clogit(form, datless, method='approximate', model=T),
               warning = function(w) {
                 modTrain <- clogit(form, datless, method='approximate', model=T)
                 flag <<- 1})
      
      # model w/ only single individual
      tryCatch(modVal <- clogit(sform, datonly, method='approximate', model=T), 
               warning = function(w) {
                 modVal <<- clogit(sform, datonly, method='approximate', model=T)
                 flag <<- 1})
      
      # Predictions (linear predictor) for with-held individual
      testPredict <- predict(modVal, type="lp")
      valPredict <- predict(modTrain, newdata = datonly, type = 'lp', reference = 'sample')
      
      # Estimate goodness of fit
      return(gof(do = datonly[c('Stratum', 'Used')], fits = plogis(valPredict), 
                 obs = plogis(testPredict), flag = flag))
    })
    
    stopCluster(cl)
    
  } else {
    for (id in uE) {
      print(paste('Cluster:', id))
      datless <- subda[subda[,ID] != id,]
      datonly <- subda[subda[,ID] == id,]
      
      if (length(levels(as.factor(datonly[, cluster]))) <= 1) {
        sform <- as.character(form)
        sform2 <- strsplit(sform[3], '[+]')[[1]]
        sform <- formula(paste0(sform[2], sform[1], paste(sform2[-grep('cluster[(]', sform2)], collapse='+')))
      }
      
      ## Generate models
      # Flag if singularity/convergence warnings
      # model w/ all but single individual
      flag <- 0
      tryCatch(modTrain <- clogit(form, datless, method='approximate', model=T),
               warning = function(w) {
                 modTrain <- clogit(form, datless, method='approximate', model=T)
                 flag <<- 1})
      
      # model w/ only single individual
      tryCatch(modVal <- clogit(sform, datonly, method='approximate', model=T), 
               warning = function(w) {
                 modVal <<- clogit(sform, datonly, method='approximate', model=T)
                 flag <<- 1})
      
      # Predictions (linear predictor) for with-held individual
      testPredict <- predict(modVal, type="lp")
      valPredict <- predict(modTrain, newdata = datonly, type = 'lp', reference = 'sample')
      
      # Estimate goodness of fit
      rec <- gof(do = datonly[c('Stratum', 'Used')], fits = plogis(valPredict), 
                 obs = plogis(testPredict), flag = flag)
      out[[as.character(id)]] <- rec
    }
  }
  
  # define class
  class(out) <- c("lio", "list")
  
  return(out)
}
