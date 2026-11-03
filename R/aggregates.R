# Weighted summary birth history aggregates by age group of mother.
#
# Common arguments (documented once here):
#   data   data.frame/data.table, one row per woman.
#   age    name of the column with the woman's age (single years). Ages outside
#          15-49 are discarded.
#   weight name of the weight column; NULL means every woman has weight 1.
#   sex    optional list(var = <column>, female = <code>) (or c(<column>, <code>));
#          when given, only rows with that code are kept.
# All results indexed by age group are data.tables with columns i, age_group, x.

#' Children ever born by age group of mother
#'
#' @param data A data.frame or data.table with one row per woman.
#' @param age Name of the column with the age of the woman.
#' @param ceb Name of the column with the number of children ever born.
#' @param weight Name of the weight column. `NULL` (default) gives weight 1.
#' @param sex Optional `list(var = <column>, female = <code>)` to keep women only.
#' @return A data.table with columns `i`, `age_group`, `x`, `ceb`.
#' @export
ceb <- function(data, age, ceb, weight = NULL, sex = NULL) {
  .aggregate(data, age, list(ceb = ceb), weight, sex)[, .(i, age_group, x, ceb)]
}

#' Women by age group (female at parity)
#'
#' Counts every woman in the age group, whether or not she answered the
#' questions on children.
#' @inheritParams ceb
#' @return A data.table with columns `i`, `age_group`, `x`, `fp`.
#' @export
fp <- function(data, age, weight = NULL, sex = NULL) {
  .aggregate(data, age, list(), weight, sex)[, .(i, age_group, x, fp)]
}

#' Children dead by age group of mother
#'
#' @inheritParams ceb
#' @param cd Name of the column with the number of children dead.
#' @return A data.table with columns `i`, `age_group`, `x`, `cd`.
#' @export
cd <- function(data, age, cd, weight = NULL, sex = NULL) {
  .aggregate(data, age, list(cd = cd), weight, sex)[, .(i, age_group, x, cd)]
}

#' Average parity by age group of mother
#'
#' `avg_p(i) = ceb(i) / fp(i)`.
#' @inheritParams ceb
#' @return A data.table with columns `i`, `age_group`, `x`, `avg_p`.
#' @export
avg_p <- function(data, age, ceb, weight = NULL, sex = NULL) {
  tab <- .aggregate(data, age, list(ceb = ceb), weight, sex)
  tab[, .(i, age_group, x, avg_p = ceb / fp)]
}

#' Proportion of children dead by age group of mother
#'
#' `dc(i) = cd(i) / ceb(i)`.
#' @inheritParams ceb
#' @inheritParams cd
#' @return A data.table with columns `i`, `age_group`, `x`, `dc`.
#' @export
dc <- function(data, age, ceb, cd, weight = NULL, sex = NULL) {
  tab <- .aggregate(data, age, list(ceb = ceb, cd = cd), weight, sex)
  tab[, .(i, age_group, x, dc = cd / ceb)]
}

#' Proportion of children dead, women aged 20-34
#'
#' `sum(cd) / sum(ceb)` with age groups 20-24, 25-29 and 30-34 pooled (not the
#' mean of the three `dc(i)`). Neupert et al. (2019) use this statistic to build
#' the correction factor of their indirect estimates of infant and under-five mortality for small
#' areas, where the number of deaths of children is too small for the Brass method.
#' @inheritParams dc
#' @return A scalar, with attributes `"cd"` and `"ceb"` (weighted totals for ages 20-34).
#' @references Neupert R, Fernandez Menjivar RE, Fernandez Castilla RE (2019).
#'   "Estimação indireta da mortalidade infantil em pequenas áreas."
#'   *Revista Brasileira de Estudos de População*, 36, 1-37.
#'   \doi{10.20947/s0102-3098a0100}
#' @export
dc_20_34 <- function(data, age, ceb, cd, weight = NULL, sex = NULL) {
  tab <- .aggregate(data, age, list(ceb = ceb, cd = cd), weight, sex)[i %in% 2:4]
  structure(sum(tab$cd) / sum(tab$ceb), cd = sum(tab$cd), ceb = sum(tab$ceb))
}

#' Mean age at maternity
#'
#' Mean age of the age-specific fertility schedule:
#' `sum(f(i) * m(i)) / sum(f(i))`, where `f(i)` is births in the last 12 months
#' divided by women in group `i` and `m = 17, 22, ..., 47`.
#' @inheritParams ceb
#' @param births Name of the column with the number of live births in the 12
#'   months before the survey.
#' @return A scalar, with attribute `"asfr"` holding the fertility rates by age group.
#' @export
maam <- function(data, age, births, weight = NULL, sex = NULL) {
  .maam_tab(.aggregate(data, age, list(births = births), weight, sex))
}

.maam_tab <- function(tab) {
  asfr <- tab$births / tab$fp
  m <- sum(asfr * .MID_AGES, na.rm = TRUE) / sum(asfr, na.rm = TRUE)
  structure(m, asfr = tab[, .(i, age_group, asfr = births / fp)])
}
