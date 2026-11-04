test_that("MinasGerais has women aged 15-49 and the selected variables", {
  data(MinasGerais, package = "childmortality", envir = environment())
  expect_equal(nrow(MinasGerais), 651761L)
  expect_equal(names(MinasGerais), c("P0180", "P0150", "P0110", "P0320", "P0330",
                                     "P0340", "P0350", "P0360", "P0370", "P0400"))
  expect_true(all(MinasGerais$P0150 == 2L))
  expect_true(all(MinasGerais$P0180 %in% 4:10))
})

test_that("est_mort_q runs on MinasGerais", {
  data(MinasGerais, package = "childmortality", envir = environment())
  mg <- MinasGerais
  mg$age <- 5 * mg$P0180 - 3
  mg$cd <- ifelse(mg$P0340 == 0, 0, mg$P0340 - mg$P0370)
  est <- est_mort_q(mg, y = 5, age = "age", ceb = "P0340", cd = "cd",
                    family = "South", ref_date = "20220801", weight = "P0110")
  expect_true(all(est$q_y > 0 & est$q_y < 1))
})
