# Relational logit model life tables (Brass), standards with e0 = 60.
#
# GE_standards_0.xlsx stores Brass logits Ys(x) = 0.5 * log(q_s(x) / (1 - q_s(x))),
# so qlogis(q_s(x)) = 2 * Ys(x) in the formulas below.

#' Level parameter alpha of the relational logit system
#'
#' `alpha(i) = (qlogis(q(x)) - qlogis(q_s(x))) / 2`, where `q_s(x)` is the
#' standard (e0 = 60) of the chosen family and sex.
#' @inheritParams mort_q
#' @param sex_std Sex of the standard life table: `"both"` (default), `"male"`
#'   or `"female"`.
#' @return A data.table with columns `i`, `age_group`, `x`, `alpha`.
#' @export
mort_alpha <- function(data, age, ceb, cd, family = NULL, births = NULL,
                       sex_std = "both", weight = NULL, sex = NULL) {
  family <- .match_family(family)
  sex_std <- .match_sex_std(sex_std)
  tab <- .brass_tab(data, age, ceb, cd, births, family, weight, sex)
  .brass_core(tab, family, sex_std = sex_std)[, .(i, age_group, x, alpha)]
}

#' Convert the estimates to a common index q(y)
#'
#' `q(y) = plogis(2 * alpha(i) + qlogis(q_s(y)))` for every age group, i.e. each
#' pair (age group, x) is turned into an estimate of the probability of dying
#' by exact age `y`.
#' @inheritParams mort_alpha
#' @param y Exact age of the common index (e.g. 1 for infant mortality, 5 for
#'   under-five mortality). Must be an age of the standard table.
#' @return A data.table with columns `i`, `age_group`, `x`, `q_y`.
#' @export
mort_convert_q <- function(data, y, age, ceb, cd, family = NULL, births = NULL,
                           sex_std = "both", weight = NULL, sex = NULL) {
  family <- .match_family(family)
  sex_std <- .match_sex_std(sex_std)
  tab <- .brass_tab(data, age, ceb, cd, births, family, weight, sex)
  .brass_core(tab, family, sex_std = sex_std, y = y)[, .(i, age_group, x, q_y)]
}
