#' Indirect estimates of infant and under-five mortality (Brass-Trussell / Brass-Palloni-Heligman)
#'
#' The family selects the variant: Princeton families (North, South, East, West)
#' give Brass-Trussell; UN families (Latam, Chilean, SAsia, FarEast, General) give
#' Brass-Palloni-Heligman, whose multipliers depend on the mean age at maternity
#' and therefore require `births`.
#'
#' Runs the full chain: average parity, proportion dead, multipliers, q(x),
#' time reference and reference date, and conversion to the common index q(y).
#' @inheritParams mort_convert_q
#' @inheritParams time_mort_q
#' @param column Optional name of a single output column to return as a vector.
#' @return A data.table of class `est_mort_q` with columns `age_group`, `i`,
#'   `avg_p`, `dc`, `mult_k`, `x`, `q_x`, `t_ref`, `ref_date`, `alpha`, `q_y`,
#'   and attributes `y`, `family`, `method`, `sex_std`, `maam`. If `column` is given,
#'   only that column, as a vector.
#' @inherit childmortality-package references
#' @examples
#' set.seed(1)
#' n <- 2000
#' women <- data.frame(age = sample(15:49, n, replace = TRUE))
#' women$ceb <- rpois(n, pmax(0, (women$age - 15) / 6))
#' women$cd <- rbinom(n, women$ceb, 0.05 + (women$age - 15) / 600)
#' women$births <- rbinom(n, 1, 0.12)
#' est <- est_mort_q(women, y = 5, age = "age", ceb = "ceb", cd = "cd",
#'                   births = "births", family = "General", ref_date = "20100801")
#' est
#' plot(est)
#' @export
est_mort_q <- function(data, y = 5, age, ceb, cd, births = NULL, family = NULL,
                       ref_date, sex_std = "both", weight = NULL, sex = NULL,
                       column = NULL) {
  family <- .match_family(family)
  sex_std <- .match_sex_std(sex_std)
  tab <- .brass_tab(data, age, ceb, cd, births, family, weight, sex)
  out <- .brass_core(tab, family, ref_date = ref_date, sex_std = sex_std, y = y)
  M <- attr(out, "maam")
  cols <- c("age_group", "i", "avg_p", "dc", "mult_k", "x", "q_x",
            "t_ref", "ref_date", "alpha", "q_y")
  out <- out[, ..cols]
  if (!is.null(column)) {
    if (length(column) != 1L || !column %in% cols) {
      stop("`column` must be one of: ", paste(cols, collapse = ", "), call. = FALSE)
    }
    return(out[[column]])
  }
  setattr(out, "y", y)
  setattr(out, "family", family)
  setattr(out, "method", .method_of(family))
  setattr(out, "sex_std", sex_std)
  setattr(out, "maam", M)
  setattr(out, "class", c("est_mort_q", class(out)))
  out
}
