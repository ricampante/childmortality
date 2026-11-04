# childmortality

Indirect estimation of infant (1q0) and under-five (5q0) mortality from summary birth histories
(children ever born and children dead by age of mother), as collected in the
Brazilian census.

The functions also estimate the probability of dying by other exact ages x,
q(x) = xq0 (e.g. 2q0, 3q0). Child mortality (4q1) can be derived from 1q0 and
5q0: 4q1 = (5q0 - 1q0) / (1 - 1q0).

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

Neupert et al. 2019's small area estimation correction factors  can be built with `dc_20_34()`,
which computes the proportion of children dead among women aged 20-34.

## Installation

```r
remotes::install_github("ricampante/childmortality")
# or: download it and
# install.packages("pak")
# pak::pak("ricampante/childmortality")
```

The repository is public, so no GitHub token is needed.

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

A worked example with real data, the 2022 Census of Minas Gerais (`data("MinasGerais")`),
is in the vignette: `vignette("MinasGerais", package = "childmortality")`. Installs from
GitHub do not build vignettes by default; to get it, use
`remotes::install_github("ricampante/childmortality", build_vignettes = TRUE)`.

## References

- Hill K (2013). Indirect estimation of child mortality. In Moultrie TA et al.
  (eds), *Tools for Demographic Estimation*. Paris: IUSSP.
- United Nations (1990). *Step-by-Step Guide to the Estimation of Child
  Mortality*. Population Studies No. 107. New York: United Nations.
- United Nations Population Division (2011). *Model Life Tables*.
- Neupert R, Fernandez Menjivar RE, Fernandez Castilla RE (2019). Estimação
  indireta da mortalidade infantil em pequenas áreas. *Revista Brasileira de
  Estudos de População*, 36, 1-37. doi:10.20947/s0102-3098a0100
