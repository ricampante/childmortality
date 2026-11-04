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
install.packages("pak")
pak::pak("ricampante/childmortality")
# or: remotes::install_github("ricampante/childmortality")
```

The repository is public, so no GitHub token is needed.

## Example

Women aged 15-49 in Minas Gerais, from the 2022 Census public-access microdata
(`?MinasGerais`). The variables keep the IBGE codes, so they are cleaned first.

```r
library(childmortality)

data("MinasGerais")
mg <- MinasGerais
mg$age <- 5 * mg$P0180 - 3                               # five-year group -> age
mg$cd <- ifelse(mg$P0340 == 0, 0, mg$P0340 - mg$P0370)   # children dead
mg$births <- as.integer(mg$P0400 %in% 1)                 # birth in the last 12 months

# UN General family (Brass-Palloni-Heligman): needs births for the mean age at maternity
est <- est_mort_q(mg, y = 5, age = "age", ceb = "P0340", cd = "cd",
                  births = "births", family = "General",
                  ref_date = "20220801", weight = "P0110")
est
plot(est)

# Choosing the model family: 1q0 and 4q1 from Brazilian vital statistics
obs <- list("Br 2022" = c(0.01246, 0.0023), "Br 2023" = c(0.01273, 0.0022),
            "Br 2024" = c(0.01257, 0.0022))
plot_mlt(obs)
```

See `?est_mort_q`, `?plot_mlt` and `?childmortality` for details.

The vignette compares the families and uses the South family, the most adequate
for Brazil in 2022: `vignette("MinasGerais", package = "childmortality")`. Installs from
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
