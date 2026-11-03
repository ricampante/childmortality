test_that("model life table curves are complete and ordered", {
  mlt <- childmortality:::.mlt_child
  expect_equal(nrow(mlt), 9 * 3 * 81)
  expect_true(all(mlt$q1 > 0 & mlt$q1 < 1 & mlt$q4 > 0 & mlt$q4 < 1))
  dec <- mlt[, .(ok = all(diff(q1) < 0) && all(diff(q4) < 0)), by = .(family, sex)]
  expect_true(all(dec$ok))
})

test_that("both-sex curves agree with the e0 = 60 standards", {
  mlt <- childmortality:::.mlt_child
  std <- childmortality:::.std_logits
  for (fam in unique(mlt$family)) {
    q1 <- mlt[family == fam & sex == "both" & e0 == 60, q1]
    ys1 <- std[family == fam & sex == "both" & x == 1, ys]
    expect_equal(0.5 * qlogis(q1), ys1, tolerance = 1e-4, label = fam)
  }
})

test_that("observed pairs are accepted as matrix, data.frame or list", {
  l <- list("A" = c(0.06, 0.025), "B" = c(0.045, 0.015))
  m <- rbind("A" = c(0.06, 0.025), "B" = c(0.045, 0.015))
  d <- as.data.frame(m)
  p <- childmortality:::.parse_q_pairs(l)
  expect_equal(p$label, c("A", "B"))
  expect_equal(childmortality:::.parse_q_pairs(m), p)
  expect_equal(childmortality:::.parse_q_pairs(d), p)
  expect_error(childmortality:::.parse_q_pairs(list(c(0.06, 1.2))), "between 0 and 1")
  expect_error(childmortality:::.parse_q_pairs(cbind(0.1, 0.2, 0.3)), "two columns")
  expect_error(childmortality:::.parse_q_pairs(list(c(0.06, 0.02, 0.01))), "pair")
})

test_that("plot_mlt draws and returns the requested curves", {
  f <- tempfile(fileext = ".pdf")
  pdf(f)
  on.exit({ dev.off(); unlink(f) })
  obs <- list("A" = c(0.06, 0.025), "B" = c(0.045, 0.015))
  curves <- plot_mlt(obs, families = c("North", "Latam"), sex_std = "female")
  expect_setequal(unique(curves$family), c("North", "Latam"))
  expect_equal(unique(curves$sex), "female")
  expect_equal(nrow(plot_mlt(obs)), 9 * 81)
  expect_error(plot_mlt(obs, families = "Nort"), "Unknown")
})
