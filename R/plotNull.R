#' @title Plot Random Forest Importance Null Distributions
#' @description Plot the Random Forest null distributions importance metrics, 
#' observed values, and p-values for
#' each predictor variable from the object produced by a 
#' call to \code{\link{rfPermute}}.
#' 
#' @param x An object produced by a call to \code{\link{rfPermute}}.
#' @param imp.type Either a numeric or character vector giving the 
#'   importance metric(s) to plot.
#' @param scale Plot importance measures scaled (divided by) standard errors?
#' @param ... Optional graphical arguments to be sent to \code{\link[graphics]{par}}.
#' 
#' @details The function will generate an individual plot for
#'   each variable and importance metric on the default graphics
#'   device.
#'   
#' @author Eric Archer \email{eric.archer@@noaa.gov}
#' 
#' @examples
#'   # A regression model using the ozone example
#'   data(airquality)
#'   ozone.rfP <- rfPermute(Ozone ~ ., data = airquality, ntree = 100, na.action = na.omit, nrep = 50)
#'   
#'   # Plot the null distributions and observed values.
#'   layout(matrix(1:6, nrow = 2))
#'   plotNull(ozone.rfP) 
#'   layout(matrix(1))
#' 
#' @importFrom graphics abline par plot
#' @importFrom stats density
#' @export
#' 
plotNull <- function(x, imp.type = 1, scale = TRUE, ...) {
  if(!inherits(x, "rfPermute")) stop("'x' is not of class 'rfPermute'")
  imp <- randomForest::importance(x, scale = scale)
  imp <- imp[, c(ncol(imp) - 1, ncol(imp))]
  
  if(is.character(imp.type)) {
   not.found <- imp.type[!(imp.type %in% colnames(imp))]
   if(length(not.found) > 0) {
     imp <- paste(not.found, collapse = ", ")
     stop(paste("imp.type: ", imp, " is not in 'x'", sep = ""))
   }
  } else if(is.numeric(imp.type)) {
    if(!all(imp.type <= ncol(imp))) stop("some 'imp.type' out of range")
    imp.type <- colnames(imp)[imp.type]
  } else stop("'imp.type' is not a character or numeric vector")
  
  sc <- if(scale) "scaled" else "unscaled"
  
  op <- par(..., no.readonly = TRUE)
  for(p in rownames(imp)) {
    for(i in imp.type) {
      n <- x$null.dist[[sc]][p, i, ]
      o <- imp[p, i]
      xlab <- if(is.character(i)) i else colnames(imp)[i]
      pval <- x$pval[p, i, sc]
      main <- c(paste("Variable:", p), 
                paste("P(null >= obs) =", sprintf("%0.3f", pval)))
      plot(density(n), xlim = range(c(n, o)), xlab = xlab, main = main)
      abline(v = o, lwd = 2)
    }
  }
  par(op)
}