
#  This function takes a qual and returns c(post_alpha, post_beta)
#  Increments by prior alpha and prior distribution beta, uniform by default
parseQual <- function(qual, prior_alpha=1, prior_beta=1) {
  if(is.na(qual) || !grepl("@", qual)) { return(c(prior_alpha, prior_beta)) }  ## for INT NA Columns
  res <- unlist(strsplit(unlist(strsplit(as.character(qual), "@"))[2], ","))
  if(is.na(res[1]) || is.na(res[2])) { return(c(prior_alpha, prior_beta)) }
  if(is.null(res[1]) || is.null(res[2])) { return(c(prior_alpha, prior_beta)) }
  if(res[1] == "NA" || res[2] == "NA") { return(c(prior_alpha, prior_beta)) }
  res <- as.numeric(res)
  if(is.nan(res[1]) || is.nan(res[2])) { return(c(prior_alpha, prior_beta)) }
  if(is.infinite(res[1]) || is.infinite(res[2])) { return(c(prior_alpha, prior_beta)) }
  res[1] <- res[1] + prior_alpha
  res[2] <- res[2] + prior_beta
  res
}

#' Obtain CIs from the sampled values
#'
#' @param betaDist A vector with the values sampled from the distribution
#' @param percentile A vector with the two percentiles that will be returned.
#' Defaults to 0.05 and 0.95, to give 90\% confidence intervals.
#' @examples
#' betasample <- rbeta(n=10000, 2, 2)
#' psiplot:::betaCI(betasample)
#' @return A named vector with the desired percentiles.
#'
betaCI <- function(betaDist, percentile = c(0.05, 0.95)) {
  stats::quantile(betaDist, p=percentile, na.rm = T)
}

#Sample from a beta distribution given the shape parameters
betaCISample <- function(alpha, beta, n = 5000) {
  if (is.na(alpha) || is.na(beta)) {
    sample <- NA
  } else {
    set.seed(79)
    sample <- stats::rbeta(n, alpha, beta)
  }
  return(sample)
}

#' Calculate confidence intervals for error bars
#'
#' Helper function to filter and return confidence intervals based on beta
#' distribution from Q scores. For internal use. Beta sampling functions
#' provided by Tim Sterne-Weiler.
#'
#' @param q a data frame of PSI and corresponding quality values
#' @return Confidence intevals of PSI values
#' @author Tim Sterne-Weiler, Kevin Ha
get_beta_ci <- function(q) {
  parameters <- parseQual(q)
  ci <- betaCISample(alpha=parameters[1],beta=parameters[2])
  ci <- betaCI(ci)
  ci <- ci * 100
  return(ci)
}

#' @title Calculate conficence intervals for error bars of subgrouped samples.
#'
#' @description Helper function to filter and return confidence intervals based
#' on a joint beta distribution obtained from Q scores. For internal use.
#'
#' @details Individual beta distributions are generated from each sample in the
#' subgroup. Those distributions are sampled and the results are used to fit a
#' new joint beta distribution. The joint beta is then sampled again to obtain
#' confidence intervals for the subgroup.
#'
#' @param q Data frame with quality scores of an event
get_beta_ci_subg <- function(q) {
  parameters <- sapply(q, function(x) parseQual(as.character(x)),USE.NAMES = F)
  CIsamples <- lapply(1:ncol(parameters),function(j) betaCISample(parameters[1,j],
                                                                  parameters[2,j]))
  CIpool <- do.call("c",CIsamples)

  smean <- mean(CIpool,na.rm = T)
  svar <- stats::var(CIpool,na.rm = T)
  const_mom <- smean*(1-smean)/(svar^2) - 1 #constant part of alpha and beta estimates
  a_mom <- smean*const_mom #alpha estimate with method of moments
  b_mom <- (1-smean)*const_mom #beta estimate with method of moments

  fittedparams <- tryCatch(
   MASS::fitdistr(CIpool,"beta",list(shape1=a_mom, shape2=b_mom)),
   error= function(e) list("estimate"=c(NA,NA)))


  newCIs <- stats::rbeta(5000,fittedparams$estimate[1],fittedparams$estimate[2])
  ci <- betaCI(newCIs) * 100
  return(ci)
}
