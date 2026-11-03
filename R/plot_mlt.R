#' Plot observed 1q0 and 4q1 against model life table patterns
#'
#' Draws, for each model life table family, the curve traced by the pair
#' (1q0, 4q1) across mortality levels, and overlays observed pairs (for example
#' direct estimates from full birth histories). It reproduces Figure 1 of
#' Hill (2013) and helps choose the family used by [est_mort_q()].
#'
#' The family whose curve passes closest to the observed points is the best
#' candidate. As noted by Hill (2013), the UN General, South Asian and Far
#' Eastern patterns are nearly indistinguishable under age 5.
#'
#' Curves come from the UN Population Division (2011) model life tables, levels
#' e0 = 20, ..., 100. For `sex_std = "both"`, male and female tables of the same
#' level are combined with a sex ratio at birth of 1.05.
#'
#' @param q Observed pairs of 1q0 and 4q1: a two-column matrix or data.frame
#'   (1q0 first, row names used as labels), or a list of pairs `c(1q0, 4q1)`
#'   (list names used as labels).
#' @param families Families to draw; `NULL` (default) draws all nine. See
#'   [mult_k()] for the names.
#' @param sex_std Sex of the model life tables: `"both"` (default), `"male"` or
#'   `"female"`.
#' @param legend Whether to add a legend with the families.
#' @param ... Further arguments passed to [graphics::plot()], e.g. `xlim`,
#'   `ylim`, `main`.
#' @return The curves drawn, invisibly: a data.table with columns `family`,
#'   `sex`, `e0`, `q1` (1q0) and `q4` (4q1).
#' @references Hill K (2013). "Indirect estimation of child mortality." In
#'   Moultrie TA et al. (eds), *Tools for Demographic Estimation*. Paris: IUSSP.
#'   <https://demographicestimation.iussp.org/content/indirect-estimation-child-mortality>
#'
#'   United Nations Population Division (2011). *Model Life Tables*.
#'   <https://www.un.org/development/desa/pd/data/model-life-tables>
#' @examples
#' # Illustrative values, not real survey data.
#' obs <- list("Survey A" = c(0.060, 0.025), "Survey B" = c(0.045, 0.015))
#' plot_mlt(obs)
#' plot_mlt(obs, families = c("North", "West", "Latam"))
#'
#' # Same data as a matrix
#' m <- rbind("Survey A" = c(0.060, 0.025), "Survey B" = c(0.045, 0.015))
#' curves <- plot_mlt(m, sex_std = "female")
#' head(curves)
#' @export
plot_mlt <- function(q, families = NULL, sex_std = "both", legend = TRUE, ...) {
  obs <- .parse_q_pairs(q)
  sex_std <- .match_sex_std(sex_std)
  if (is.null(families)) families <- .FAMILIES
  bad <- setdiff(families, .FAMILIES)
  if (length(bad)) {
    stop("Unknown `families`: ", paste(bad, collapse = ", "),
         ". Use: ", paste(.FAMILIES, collapse = ", "), call. = FALSE)
  }

  curves <- .mlt_child[.mlt_child$family %in% families & .mlt_child$sex == sex_std]
  pad <- function(v) c(0, max(v) * 1.4)
  args <- utils::modifyList(list(
    x = obs$q1, y = obs$q4, type = "n",
    xlim = pad(obs$q1), ylim = pad(obs$q4),
    xlab = "1q0", ylab = "4q1",
    main = "Observed 1q0 and 4q1 against model life tables"
  ), list(...))
  do.call(plot, args)

  cols <- grDevices::palette.colors(length(.FAMILIES), "Tableau 10")
  names(cols) <- .FAMILIES
  ltys <- ifelse(.FAMILIES %in% .UN_FAMILIES, 2, 1)
  names(ltys) <- .FAMILIES
  for (fam in families) {
    cf <- curves[curves$family == fam]
    lines(cf$q1, cf$q4, col = cols[[fam]], lty = ltys[[fam]], lwd = 2)
  }
  points(obs$q1, obs$q4, pch = 19)
  text(obs$q1, obs$q4, labels = obs$label, pos = 3, cex = 0.8)
  if (legend) {
    graphics::legend("topleft", legend = families, col = cols[families],
                     lty = ltys[families], lwd = 2, bty = "n", cex = 0.8)
  }
  invisible(curves)
}

# Matrix, data.frame or list of pairs -> data.table(label, q1, q4).
.parse_q_pairs <- function(q) {
  if (is.list(q) && !is.data.frame(q)) {
    if (!all(lengths(q) == 2L)) {
      stop("Each element of `q` must be a pair c(1q0, 4q1).", call. = FALSE)
    }
    labels <- names(q)
    q <- do.call(rbind, lapply(q, as.numeric))
  } else {
    if (NCOL(q) != 2L) stop("`q` must have two columns: 1q0 and 4q1.", call. = FALSE)
    labels <- rownames(q)
    q <- as.matrix(q)
  }
  out <- data.table(label = if (is.null(labels)) as.character(seq_len(nrow(q))) else labels,
                    q1 = as.numeric(q[, 1L]), q4 = as.numeric(q[, 2L]))
  if (anyNA(out[, .(q1, q4)]) || any(out$q1 <= 0 | out$q1 >= 1 | out$q4 <= 0 | out$q4 >= 1)) {
    stop("Values of 1q0 and 4q1 must lie strictly between 0 and 1.", call. = FALSE)
  }
  out
}
