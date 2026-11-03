#' Plot the common index estimates over time
#'
#' Dotted line of `q(y)` against the reference date, one point per age group
#' of mother, labelled with the age group.
#' @param x An object returned by [est_mort_q()].
#' @param ... Further arguments passed to [graphics::plot()].
#' @return `x`, invisibly.
#' @export
plot.est_mort_q <- function(x, ...) {
  y <- attr(x, "y")
  ok <- is.finite(x$ref_date) & is.finite(x$q_y)
  rx <- x$ref_date[ok]
  ry <- x$q_y[ok]
  ord <- order(rx)
  pad <- diff(range(ry)) * 0.1 + 1e-3
  args <- utils::modifyList(list(
    x = rx[ord], y = ry[ord], type = "b", lty = 3, pch = 19,
    xlab = "Reference date", ylab = sprintf("q(%s)", y),
    ylim = c(min(ry) - pad, max(ry) + pad),
    main = sprintf("Estimated q(%s), %s (%s)", y, attr(x, "method"), attr(x, "family"))
  ), list(...))
  do.call(plot, args)
  text(rx, ry, labels = x$age_group[ok], pos = 3, cex = 0.8)
  invisible(x)
}
