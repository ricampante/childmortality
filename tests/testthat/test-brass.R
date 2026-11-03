test_that("Malawi 2008 example (Princeton North) is reproduced", {
  est <- est_mort_q(malawi, y = 5, age = "age", ceb = "ceb", cd = "cd",
                    family = "North", ref_date = "20080618", weight = "w")
  expect_equal(est$q_x, c(0.1063, 0.1105, 0.1222, 0.1528, 0.1885, 0.2205, 0.2441),
               tolerance = 1e-3)
  expect_equal(est$t_ref, c(1.05, 2.43, 4.44, 6.81, 9.44, 12.23, 15.12), tolerance = 5e-3)
  expect_equal(est$ref_date, c(2007.42, 2006.03, 2004.03, 2001.66, 1999.02, 1996.24, 1993.35),
               tolerance = 1e-5)
  expect_equal(est$alpha, c(0.2653, 0.1842, 0.1806, 0.2334, 0.2791, 0.3350, 0.3487),
               tolerance = 2e-3)
  expect_equal(est$q_y, c(0.1612, 0.1405, 0.1396, 0.1528, 0.1650, 0.1809, 0.1850),
               tolerance = 2e-3)

  q1 <- mort_convert_q(malawi, 1, "age", "ceb", "cd", family = "North", weight = "w")
  expect_equal(q1$q_y, c(0.1063, 0.0918, 0.0912, 0.1004, 0.1089, 0.1203, 0.1232),
               tolerance = 2e-3)
})

test_that("sub-functions agree with est_mort_q", {
  args <- list(malawi, age = "age", ceb = "ceb", weight = "w", family = "General")
  est <- est_mort_q(malawi, y = 5, age = "age", ceb = "ceb", cd = "cd", births = "births",
                    family = "General", ref_date = "20080618", weight = "w")
  expect_equal(do.call(mult_k, c(args, births = "births"))$mult_k, est$mult_k)
  expect_equal(do.call(mort_q, c(args, cd = "cd", births = "births"))$q_x, est$q_x)
  expect_equal(do.call(time_mort_q, c(args, ref_date = "20080618"))$ref_date, est$ref_date)
  expect_equal(do.call(mort_alpha, c(args, cd = "cd", births = "births"))$alpha, est$alpha)
  expect_equal(attr(est, "maam"), 28.62, tolerance = 1e-3)
})

test_that("family defaults to General with a warning", {
  expect_warning(k <- mult_k(malawi, "age", "ceb", births = "births", weight = "w"), "General")
  expect_equal(k, mult_k(malawi, "age", "ceb", family = "General", births = "births", weight = "w"))
  expect_error(mult_k(malawi, "age", "ceb", family = "Nort", weight = "w"))
})

test_that("Princeton families do not need births; UN families do", {
  expect_silent(mult_k(malawi, "age", "ceb", family = "West", weight = "w"))
  expect_error(mult_k(malawi, "age", "ceb", family = "Latam", weight = "w"), "births")
})

test_that("column selection and sex of the standard", {
  args <- list(malawi, y = 1, age = "age", ceb = "ceb", cd = "cd", family = "North",
               ref_date = "20080618", weight = "w")
  est <- do.call(est_mort_q, args)
  expect_s3_class(est, "est_mort_q")
  expect_equal(do.call(est_mort_q, c(args, column = "q_y")), est$q_y)
  expect_length(do.call(est_mort_q, c(args, column = "q_y")), 7)
  expect_false(isTRUE(all.equal(do.call(est_mort_q, c(args, sex_std = "male"))$q_y, est$q_y)))
  expect_error(do.call(est_mort_q, c(args, column = "foo")))
  expect_error(do.call(est_mort_q, modifyList(args, list(y = 7))))
})

test_that("plot method runs", {
  est <- est_mort_q(malawi, y = 5, age = "age", ceb = "ceb", cd = "cd",
                    family = "North", ref_date = "20080618", weight = "w")
  f <- tempfile(fileext = ".pdf")
  pdf(f)
  on.exit({ dev.off(); unlink(f) })
  expect_invisible(plot(est))
})

test_that("Brass-Palloni-Heligman multipliers include the mean age at maternity", {
  k <- mult_k(malawi, "age", "ceb", family = "General", births = "births", weight = "w")$mult_k
  P <- avg_p(malawi, "age", "ceb", weight = "w")$avg_p
  M <- as.numeric(maam(malawi, "age", "births", weight = "w"))
  co <- childmortality:::.coef_k[family == "General"]
  expect_equal(k, co$a + co$b * P[1] / P[2] + co$c * P[2] / P[3] + co$d * M)
})

test_that("M changes the multiplier for UN families only", {
  older <- malawi
  older$births <- malawi$births * c(0.5, 0.5, 1, 1, 1.5, 2, 2)
  M0 <- as.numeric(maam(malawi, "age", "births", weight = "w"))
  M1 <- as.numeric(maam(older, "age", "births", weight = "w"))
  expect_gt(M1, M0)
  for (fam in c("Latam", "Chilean", "SAsia", "FarEast", "General")) {
    k0 <- mult_k(malawi, "age", "ceb", family = fam, births = "births", weight = "w")$mult_k
    k1 <- mult_k(older, "age", "ceb", family = fam, births = "births", weight = "w")$mult_k
    expect_false(isTRUE(all.equal(k0, k1)), label = fam)
  }
  for (fam in c("North", "South", "East", "West")) {
    k0 <- mult_k(malawi, "age", "ceb", family = fam, births = "births", weight = "w")$mult_k
    k1 <- mult_k(older, "age", "ceb", family = fam, births = "births", weight = "w")$mult_k
    expect_equal(k0, k1, label = fam)
  }
})

test_that("the family determines the method attribute", {
  args <- list(malawi, y = 5, age = "age", ceb = "ceb", cd = "cd", births = "births",
               ref_date = "20080618", weight = "w")
  expect_equal(attr(do.call(est_mort_q, c(args, family = "North")), "method"), "Brass-Trussell")
  expect_equal(attr(do.call(est_mort_q, c(args, family = "General")), "method"),
               "Brass-Palloni-Heligman")
})
