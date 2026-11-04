#' Women aged 15-49 in Minas Gerais, 2022 Census (public-access microdata)
#'
#' A strand of the public-access microdata of the 2022 Brazilian Demographic
#' Census (IBGE): the person records of the state of Minas Gerais, restricted to
#' women aged 15-49 and to the variables needed by the functions of this package.
#' Variables keep the original IBGE names and codes; see the vignette
#' (`vignette("MinasGerais", package = "childmortality")`) for the cleaning steps.
#'
#' **Limitations.** The public-access version gives age only in five-year
#' groups (`P0180`), not in single years. This is enough for the indirect method,
#' which uses exactly the groups 15-19, ..., 45-49: any age inside the group,
#' e.g. `age = 5 * P0180 - 3` (17, 22, ..., 47), puts each woman in the right
#' group. The file is a sample with its own weights (`P0110`); estimates
#' differ from those based on the full census sample.
#'
#' @format A data.frame with 651,761 rows (women) and 10 variables, `NA` where
#'   the original field is blank:
#' \describe{
#'   \item{P0180}{Age group: 4 = 15-19, 5 = 20-24, 6 = 25-29, 7 = 30-34,
#'     8 = 35-39, 9 = 40-44, 10 = 45-49.}
#'   \item{P0150}{Sex: 2 = female (all rows).}
#'   \item{P0110}{Sample weight (public-access version).}
#'   \item{P0320}{Sons born alive, number.}
#'   \item{P0330}{Daughters born alive, number.}
#'   \item{P0340}{Children born alive (children ever born), number.}
#'   \item{P0350}{Sons alive, number. `NA` when `P0340 = 0`.}
#'   \item{P0360}{Daughters alive, number. `NA` when `P0340 = 0`.}
#'   \item{P0370}{Children alive, number. `NA` when `P0340 = 0`. Children dead
#'     are `P0340 - P0370` (0 when `P0340 = 0`).}
#'   \item{P0400}{Child born alive in the 12 months before the census:
#'     1 = yes, 2 = no; `NA` when `P0340 = 0`.}
#' }
#' @source IBGE, Censo Demográfico 2022, microdados (acesso público).
#'   <https://www.ibge.gov.br/estatisticas/sociais/trabalho/22827-censo-demografico-2022.html?=&t=microdados>
#' @examples
#' data(MinasGerais)
#' mg <- MinasGerais
#' mg$age <- 5 * mg$P0180 - 3
#' mg$cd <- ifelse(mg$P0340 == 0, 0, mg$P0340 - mg$P0370)
#' dc_20_34(mg, "age", "P0340", "cd", weight = "P0110")
"MinasGerais"
