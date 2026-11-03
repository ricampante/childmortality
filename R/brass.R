# Brass method (Hill 2013, IUSSP Tables 1 and 2): Trussell variant for the Princeton
# families (d = 0) and Palloni-Heligman variant for the UN families (d != 0, uses M).
#
# Every public estimator builds the aggregated table once with .aggregate() and
# passes it to .brass_core(), which works on aggregated data (columns i, fp, ceb,
# and optionally cd and births). Parity ratios are P(1)/P(2) and P(2)/P(3), with
# P(i) the average parity of age group i.

.brass_core <- function(tab, family, ref_date = NULL, sex_std = "both", y = NULL,
                        need_k = TRUE) {
  out <- tab[, .(i, age_group, x)]
  P <- tab$ceb / tab$fp
  r1 <- P[1L] / P[2L]
  r2 <- P[2L] / P[3L]
  out[, avg_p := P]

  M <- NA_real_
  fam <- family  # `family` would resolve to the column inside data.table's i
  if (need_k && family %in% .UN_FAMILIES) {
    if (is.null(tab$births)) {
      stop("`births` is required for the UN model life table families (mean age at maternity).",
           call. = FALSE)
    }
    M <- as.numeric(.maam_tab(tab))
  }
  if (need_k) {
    k <- .coef_k[.coef_k$family == fam]
    out[, mult_k := k$a + k$b * r1 + k$c * r2 + (if (is.na(M)) 0 else k$d * M)]
  }

  if (need_k && !is.null(tab$cd)) {
    out[, dc := tab$cd / tab$ceb]
    out[, q_x := dc * mult_k]
  }

  tc <- .coef_t[.coef_t$family == fam]
  out[, t_ref := tc$e + tc$f * r1 + tc$g * r2]
  if (!is.null(ref_date)) {
    ref_year <- .date_to_decimal(ref_date)
    out[, ref_date := ref_year - t_ref]
  }

  if (!is.null(out$q_x)) {
    std <- .std_logits[.std_logits$family == fam & .std_logits$sex == sex_std]
    out[, alpha := (qlogis(q_x) - 2 * std$ys[match(x, std$x)]) / 2]
    if (!is.null(y)) {
      if (length(y) != 1L || !y %in% std$x) {
        stop("`y` must be one of the standard ages: ", paste(std$x, collapse = ", "),
             call. = FALSE)
      }
      ys_y <- std$ys[std$x == y]
      out[, q_y := plogis(2 * alpha + 2 * ys_y)]
    }
  }
  setattr(out, "maam", M)
  out[]
}

# Aggregate the variables needed by the requested family.
.brass_tab <- function(data, age, ceb, cd = NULL, births = NULL, family,
                       weight = NULL, sex = NULL) {
  vars <- list(ceb = ceb, cd = cd)
  if (family %in% .UN_FAMILIES) vars$births <- births
  .aggregate(data, age, vars, weight, sex)
}

#' Multipliers k(i)
#'
#' `k(i) = a(i) + b(i) P(1)/P(2) + c(i) P(2)/P(3) + d(i) M`, where `P(i)` is the
#' average parity of group `i` and `M` the mean age at maternity ([maam()]).
#' The family selects the variant: Princeton families (`d(i) = 0`) give the
#' Brass-Trussell multipliers; UN families give the Brass-Palloni-Heligman ones,
#' which depend on `M`, so `births` is required only for them.
#' @inheritParams ceb
#' @inheritParams maam
#' @param family Model life table family: `"North"`, `"South"`, `"East"`,
#'   `"West"` (Princeton) or `"Latam"`, `"Chilean"`, `"SAsia"`, `"FarEast"`,
#'   `"General"` (UN). Defaults to `"General"` with a warning.
#' @return A data.table with columns `i`, `age_group`, `x`, `mult_k`.
#' @inherit childmortality-package references
#' @export
mult_k <- function(data, age, ceb, family = NULL, births = NULL,
                   weight = NULL, sex = NULL) {
  family <- .match_family(family)
  tab <- .brass_tab(data, age, ceb, NULL, births, family, weight, sex)
  .brass_core(tab, family)[, .(i, age_group, x, mult_k)]
}

#' Probability of dying by exact age x
#'
#' `q(x) = dc(i) * k(i)`, Brass-Trussell for Princeton families and
#' Brass-Palloni-Heligman for UN families (see [mult_k()]).
#' @inheritParams mult_k
#' @param cd Name of the column with the number of children dead.
#' @return A data.table with columns `i`, `age_group`, `x`, `q_x`.
#' @export
mort_q <- function(data, age, ceb, cd, family = NULL, births = NULL,
                   weight = NULL, sex = NULL) {
  family <- .match_family(family)
  tab <- .brass_tab(data, age, ceb, cd, births, family, weight, sex)
  .brass_core(tab, family)[, .(i, age_group, x, q_x)]
}

#' Time reference of the estimates
#'
#' `t(i) = e(i) + f(i) P(1)/P(2) + g(i) P(2)/P(3)` years before the survey, and
#' the reference date `ref_date - t(i)` in decimal years.
#' @inheritParams mult_k
#' @param ref_date Date of the survey/census as `"YYYYMMDD"`.
#' @return A data.table with columns `i`, `age_group`, `x`, `t_ref`, `ref_date`.
#' @inherit childmortality-package references
#' @export
time_mort_q <- function(data, age, ceb, family = NULL, ref_date,
                        weight = NULL, sex = NULL) {
  family <- .match_family(family)
  # The time coefficients have no d(i) term, so births are never needed here.
  tab <- .aggregate(data, age, list(ceb = ceb), weight, sex)
  .brass_core(tab, family, ref_date = ref_date, need_k = FALSE)[, .(i, age_group, x, t_ref, ref_date)]
}
