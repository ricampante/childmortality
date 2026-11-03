test_that("aggregates are weighted and restricted to ages 15-49", {
  d <- sim_women()
  keep <- d$age >= 15 & d$age <= 49
  expect_equal(sum(fp(d, "age")$fp), sum(keep))
  expect_equal(sum(ceb(d, "age", "ceb")$ceb), sum(d$ceb[keep]))
  expect_equal(sum(cd(d, "age", "cd")$cd), sum(d$cd[keep]))

  d$w2 <- 2
  expect_equal(fp(d, "age", weight = "w2")$fp, 2 * fp(d, "age")$fp)
  expect_equal(avg_p(d, "age", "ceb", weight = "w2"), avg_p(d, "age", "ceb"))
  expect_equal(dc(d, "age", "ceb", "cd", weight = "w2"), dc(d, "age", "ceb", "cd"))
})

test_that("output has the seven age groups", {
  tab <- avg_p(sim_women(), "age", "ceb")
  expect_s3_class(tab, "data.table")
  expect_equal(tab$age_group, c("15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49"))
  expect_equal(tab$x, c(1, 2, 3, 5, 10, 15, 20))
})

test_that("sex filter keeps only the female code", {
  d <- sim_women()
  f <- d[d$sex == 2, ]
  expect_equal(fp(d, "age", sex = list(var = "sex", female = 2)), fp(f, "age"))
  expect_equal(fp(d, "age", sex = c("sex", "2")), fp(f, "age"))
})

test_that("women without an answer on children still count in fp", {
  d <- sim_women()
  d$ceb[1:50] <- NA
  expect_equal(sum(fp(d, "age")$fp), sum(d$age >= 15 & d$age <= 49))
})

test_that("mean age at maternity matches the Malawi example", {
  # The IUSSP page prints 5f40 = 0.0721 (hence 28.74); the data give 13956 / 221274
  # = 0.0631, so the correct mean age is 28.62.
  asfr <- malawi$births
  expected <- sum(asfr * c(17, 22, 27, 32, 37, 42, 47)) / sum(asfr)
  m <- maam(malawi, "age", "births", weight = "w")
  expect_equal(as.numeric(m), expected)
  expect_equal(as.numeric(m), 28.62, tolerance = 1e-3)
  expect_equal(attr(m, "asfr")$asfr, asfr)
})

test_that("decimal year conversion", {
  expect_equal(childmortality:::.date_to_decimal("20080618"), 2008 + 169 / 366)
  expect_equal(childmortality:::.date_to_decimal(20100801), 2010 + 212 / 365)
  expect_error(childmortality:::.date_to_decimal("2010-08-01"))
})

test_that("dc_20_34 pools ages 20-34", {
  # Malawi: (CEB - CS) / CEB summed over 20-24, 25-29, 30-34
  ceb_t <- c(1038556, 1613374, 1697566)
  cs_t <- c(919584, 1398776, 1426516)
  r <- dc_20_34(malawi, "age", "ceb", "cd", weight = "w")
  expect_equal(as.numeric(r), sum(ceb_t - cs_t) / sum(ceb_t))
  expect_equal(attr(r, "ceb"), sum(ceb_t))

  d <- sim_women()
  d$w2 <- runif(nrow(d))
  s <- list(var = "sex", female = 2)
  a <- ceb(d, "age", "ceb", weight = "w2", sex = s)$ceb[2:4]
  b <- cd(d, "age", "cd", weight = "w2", sex = s)$cd[2:4]
  expect_equal(as.numeric(dc_20_34(d, "age", "ceb", "cd", weight = "w2", sex = s)),
               sum(b) / sum(a))

  # women outside 20-34 do not matter
  d2 <- d
  out <- d2$age < 20 | d2$age > 34
  d2$cd[out] <- d2$ceb[out]
  expect_equal(dc_20_34(d2, "age", "ceb", "cd"), dc_20_34(d, "age", "ceb", "cd"))
})
