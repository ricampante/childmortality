#install.packages("remotes")
remotes::install_github("ricampante/childmortality")
library(childmortality)

#--- Assess the model family to be used ----

# From data based on Brazil vital systems, we have the 0q1 and 1q4 pairs to compare with model families:
obs <- obs <- list("Br 2022" = c(0.01246, 0.0023), "Br 2023" = c(0.01273, 0.0022), "Br 2024" = c(0.01257, 0.0022))
plot_mlt(obs)
plot_mlt(obs, families = c("South", "Latam", "FarEast", "Chilean"))

