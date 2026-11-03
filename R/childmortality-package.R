#' childmortality: Indirect Estimation of Infant and Child Mortality
#'
#' Indirect estimation of infant and child mortality from summary birth
#' histories (children ever born and children dead by age of mother). The
#' model life table family selects the variant of the Brass method:
#' Princeton families (North, South, East, West) give Brass-Trussell, and UN
#' families (Latam, Chilean, SAsia, FarEast, General) give
#' Brass-Palloni-Heligman, whose multipliers depend on the mean age at
#' maternity. Estimates are converted to a common index through relational
#' logit model life tables (standards with e0 = 60).
#'
#' Main entry point: [est_mort_q()]. Building blocks: [ceb()], [fp()], [cd()],
#' [avg_p()], [dc()], [maam()], [mult_k()], [mort_q()], [time_mort_q()],
#' [mort_alpha()], [mort_convert_q()]. To choose the model family, [plot_mlt()]
#' plots observed 1q0 and 4q1 against the patterns of the model life tables.
#'
#' @references Hill K (2013). "Indirect estimation of child mortality." In
#'   Moultrie TA et al. (eds), *Tools for Demographic Estimation*. Paris: IUSSP.
#'   <https://demographicestimation.iussp.org/content/indirect-estimation-child-mortality>
#'
#'   United Nations (1990). *Step-by-Step Guide to the Estimation of Child
#'   Mortality*. Population Studies No. 107 (ST/ESA/SER.A/107). New York: United
#'   Nations, Department of International Economic and Social Affairs.
#'
#'   United Nations Population Division (2011). *Model Life Tables*.
#'   <https://www.un.org/development/desa/pd/data/model-life-tables>
#' @keywords internal
#' @import data.table
#' @importFrom graphics plot text lines points
#' @importFrom stats qlogis plogis
"_PACKAGE"
