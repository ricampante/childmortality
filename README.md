# childmortality

Indirect estimation of infant (1q0) and under-five (5q0) mortality from summary birth histories
(children ever born and children dead by age of mother), as collected in the
Brazilian census.

Functions are flexible to estimate mortality at other ages (xq0). Child mortality rate (1q4) can be derived from 1q0 and 5q0. 

- **Brass method**, with the variant chosen by the model life table family:
  Princeton families (North, South, East, West) give **Brass-Trussell**; UN
  families (Latam, Chilean, SAsia, FarEast, General) give
  **Brass-Palloni-Heligman**, whose multipliers depend on the mean age at
  maternity.
- Time reference of each estimate and conversion to a common index
  (e.g. 1q0 or 5q0) through relational logit model life tables.
- `plot_mlt()`: observed 1q0 and 4q1 against the patterns of the model life
  tables, to help choose the family.
- All calculations accept survey weights and use `data.table`.

Small area estimation is planned.

## Installation

```r
install.packages("pak")
pak::pak("ricampante/childmortality")
# or: remotes::install_github("ricampante/childmortality")
```

While the repository is private, you need to be a collaborator and have a
GitHub personal access token set up in R, e.g. by running
`gitcreds::gitcreds_set()` once (or setting the `GITHUB_PAT` environment
variable).

## Example

The data below are simulated, for illustration only. Each row is a woman.

```r
library(childmortality)

set.seed(1)
n <- 2000
women <- data.frame(age = sample(15:49, n, replace = TRUE))
women$ceb <- rpois(n, pmax(0, (women$age - 15) / 6))
women$cd <- rbinom(n, women$ceb, 0.05 + (women$age - 15) / 600)
women$births <- rbinom(n, 1, 0.12)

est <- est_mort_q(women, y = 5, age = "age", ceb = "ceb", cd = "cd",
                  births = "births", family = "General",
                  ref_date = "20100801")
est
plot(est)

# Choosing the model family (illustrative values)
obs <- list("Survey A" = c(0.060, 0.025), "Survey B" = c(0.045, 0.015))
plot_mlt(obs, xlim = c(0, 0.18), ylim = c(0, 0.14))
```

See `?est_mort_q`, `?plot_mlt` and `?childmortality` for details.

## References

- Hill K (2013). Indirect estimation of child mortality. In Moultrie TA et al.
  (eds), *Tools for Demographic Estimation*. Paris: IUSSP.
- United Nations (1990). *Step-by-Step Guide to the Estimation of Child
  Mortality*. Population Studies No. 107. New York: United Nations.
- United Nations Population Division (2011). *Model Life Tables*.
