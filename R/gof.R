##' Goodness of Fit 
##' 
##' An internal function for estimating correlation metrics for cross-validation procedures
##' 
##' @author Peter Mahoney
##' @param do the 'test' data set used in cross-validation procedures.
##' @param fits the predicted values derived from a training model with test data as inputs. 
##' @param obs the predicted values derived from a test model with test data as inputs.
##' @param flag a flag passed for whether a model converged (0 = TRUE, 1 = FALSE), usually as a result of insufficient test data.
##' 
##' @return Returns a list containing the fitted and observed values (obj[[i]]$values) and cross-validation metrics (obj[[i]]$cv).
##' @export


# Goodness-of-fit function
gof <- function(do, fits, obs, flag = NULL)        
{
  # Rank correlations by strata
  drank <- cbind(do, fits, obs)
  
  ## The function to compute the rank within a strata
  samplepred <- function(df) {
    ## Number of controls
    nrand <- sum(df[, 2] == 0)
    ## Rank of the case (among case + controls)
    obs <- rank(df$fits)[df[, 2] == 1]
    ## Rank of a random control (among controls only!)
    rand <- sample(rank(df$fits[df[, 2] == 0]), 1)
    return(data.frame(obs = obs, rand = rand, nrand = nrand))
  }
  
  ranks <- do.call(rbind, by(drank, drank[, 1], samplepred))
  
  ## Is there the same number of controls per strata?
  nrand <- unique(ranks$nrand)
  if (length(nrand) != 1) {
    nrand <- max(nrand)
    #warn[i] <- 1
  }
  
  ## Compute the Spearman correlation on the ranks for the cases
  Rank_Corr_1 <- cor(1:(nrand+1), table(factor(ranks$obs,
                                               levels = 1:(nrand+1))), method = "spearman")
  ## Same for the random controls
  Rank_Corr_0 <- cor(1:(nrand), table(factor(ranks$rand, levels = 1:(nrand))),
                     method = "spearman")
  
  # Pearson's correlations
  fits2 <- fits / sum(fits)
  obs2 <- obs / sum(obs)
  Pearson_R <- cor(fits2, obs2)
  Precision <- sum((fits2 - obs2)^2)
  Bias <- sum(fits2-obs2)
  
  o <- list()
  o$values <- cbind(expected = fits, observed = obs)
  o$cv <- cbind(Pearson_R, Rank_Corr_1, Rank_Corr_0, Precision, Bias, warnFlag = flag)
  return(o)
}
