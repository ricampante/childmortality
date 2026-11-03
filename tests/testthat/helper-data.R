# Malawi 2008 Census (Hill 2013, IUSSP worked example, Tables 7 and 8), stored as
# one weighted "woman" per age group: weight = number of women and the other
# variables are per-woman means, so weighted sums reproduce the published totals.
malawi <- local({
  women  <- c(635927, 678071, 566350, 405602, 298004, 221274, 174875)
  ceb    <- c(180178, 1038556, 1613374, 1697566, 1553676, 1335242, 1128423)
  cs     <- c(161541, 919584, 1398776, 1426516, 1266514, 1043357, 851048)
  births <- c(70737, 169406, 130331, 79232, 43747, 13956, 5599)
  data.frame(age = c(17, 22, 27, 32, 37, 42, 47), w = women,
             ceb = ceb / women, cd = (ceb - cs) / women, births = births / women)
})

sim_women <- function(n = 3000, seed = 1) {
  set.seed(seed)
  d <- data.frame(age = sample(10:60, n, replace = TRUE),
                  sex = sample(1:2, n, replace = TRUE))
  d$ceb <- rpois(n, pmax(0, (d$age - 14) / 6))
  d$cd <- rbinom(n, d$ceb, 0.08)
  d$births <- rbinom(n, 1, 0.1)
  d
}
