# Builds data/MinasGerais.rda from the 2022 Census public-access microdata
# (IBGE, Pessoas_31_publico.csv, Minas Gerais). Usage:
#   Rscript data-raw/MinasGerais.R [path/to/Pessoas_31_publico.csv]
# Keeps the variables listed in variaveis_censo2022.csv and only women aged 15-49.
library(data.table)

args <- commandArgs(trailingOnly = TRUE)
path <- if (length(args)) args[1] else "Pessoas_31_publico.csv"

vars <- c("P0180", "P0150", "P0110", "P0320", "P0330", "P0340",
          "P0350", "P0360", "P0370", "P0400")
d <- fread(path, sep = ";", select = vars, colClasses = "character")
d <- d[P0150 == "2" & P0180 %in% sprintf("%02d", 4:10)]
for (v in vars) {
  x <- trimws(d[[v]])
  x[x == ""] <- NA
  set(d, j = v, value = if (v == "P0110") as.numeric(x) else as.integer(x))
}
setcolorder(d, vars)
MinasGerais <- as.data.frame(d)
dir.create("data", showWarnings = FALSE)
save(MinasGerais, file = "data/MinasGerais.rda", compress = "xz")
cat("rows:", nrow(MinasGerais), " size (MB):", file.size("data/MinasGerais.rda") / 1e6, "\n")
