# Internal constants and helpers shared by all estimators.

.AGE_GROUPS <- c("15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49")
.X_AGES     <- c(1, 2, 3, 5, 10, 15, 20)       # age of children x associated with group i
.MID_AGES   <- c(17, 22, 27, 32, 37, 42, 47)   # median age in the 12 months before the survey
.FAMILIES   <- c("North", "South", "East", "West",
                 "Latam", "Chilean", "SAsia", "FarEast", "General")
.UN_FAMILIES <- c("Latam", "Chilean", "SAsia", "FarEast", "General")

utils::globalVariables(c(
  ".", "..cols", "i", "w", "age_group", "x", "family", "fp", "ys",
  "a", "b", "c", "d", "e", "f", "g", "births", "ceb", "cd",
  "avg_p", "mult_k", "dc", "q_x", "t_ref", "ref_date", "alpha", "q_y",
  "label", "q1", "q4"
))

# Resolve the model life table family; defaults to "General" with a warning.
.match_family <- function(family) {
  if (is.null(family)) {
    warning("No model life table family chosen: using the UN \"General\" family.",
            call. = FALSE)
    return("General")
  }
  if (length(family) != 1L || !family %in% .FAMILIES) {
    stop("`family` must be one of: ", paste(.FAMILIES, collapse = ", "), call. = FALSE)
  }
  family
}

# Princeton families (d = 0) give the Trussell variant; UN families (d != 0, the
# multiplier depends on the mean age at maternity) give the Palloni-Heligman variant.
.method_of <- function(family) {
  if (family %in% .UN_FAMILIES) "Brass-Palloni-Heligman" else "Brass-Trussell"
}

.match_sex_std <- function(sex_std) {
  if (length(sex_std) != 1L || !sex_std %in% c("both", "male", "female")) {
    stop("`sex_std` must be one of \"both\", \"male\", \"female\".", call. = FALSE)
  }
  sex_std
}

# `sex` may be list(var = "V0601", female = 2) or c("V0601", "2").
.parse_sex <- function(sex) {
  if (is.null(sex)) return(NULL)
  if (is.list(sex) && all(c("var", "female") %in% names(sex))) {
    return(list(var = as.character(sex$var), female = sex$female))
  }
  if (length(sex) != 2L) {
    stop("`sex` must be list(var = <column>, female = <code>) or c(<column>, <code>).",
         call. = FALSE)
  }
  list(var = as.character(sex[[1L]]), female = sex[[2L]])
}

# "YYYYMMDD" (character or numeric) -> decimal year, e.g. "20080618" -> 2008.462.
.date_to_decimal <- function(date) {
  d <- as.Date(as.character(date), format = "%Y%m%d")
  if (length(d) != 1L || is.na(d)) {
    stop("`ref_date` must be a single date in the format \"YYYYMMDD\".", call. = FALSE)
  }
  year <- as.integer(format(d, "%Y"))
  days <- if ((year %% 4L == 0L && year %% 100L != 0L) || year %% 400L == 0L) 366 else 365
  year + (as.integer(format(d, "%j")) - 1) / days
}

# Subset women aged 15-49 (and female, if `sex` is given) and keep only the needed
# columns, renamed to the names of `vars`. Adds the age group index `i` and weight `w`.
.prep <- function(data, age, vars = list(), weight = NULL, sex = NULL) {
  sex <- .parse_sex(sex)
  cols <- unique(c(age, unlist(vars, use.names = FALSE), weight, sex$var))
  miss <- setdiff(cols, names(data))
  if (length(miss)) {
    stop("Column(s) not found in `data`: ", paste(miss, collapse = ", "), call. = FALSE)
  }
  dt <- as.data.table(data)[, ..cols]
  if (!is.null(sex)) {
    # computed outside `[` so a column named like an argument cannot mask it
    .rows <- as.character(dt[[sex$var]]) == as.character(sex$female)
    dt <- dt[.rows]
  }
  out <- data.table(
    i = findInterval(dt[[age]], seq(15, 50, by = 5)),
    w = if (is.null(weight)) 1 else as.numeric(dt[[weight]])
  )
  if (anyNA(out$w)) stop("`weight` contains missing values.", call. = FALSE)
  for (v in names(vars)) set(out, j = v, value = as.numeric(dt[[vars[[v]]]]))
  out[i >= 1L & i <= 7L]
}

# Weighted totals by age group: fp = sum of weights (all women), and the weighted
# sum of every variable in `vars`. Always returns the 7 age groups.
.aggregate <- function(data, age, vars = list(), weight = NULL, sex = NULL) {
  vars <- Filter(Negate(is.null), vars)
  p <- .prep(data, age, vars, weight, sex)
  sdcols <- as.character(names(vars))
  agg <- p[, c(list(fp = sum(w)),
               lapply(.SD, function(v) sum(w * v, na.rm = TRUE))),
           by = i, .SDcols = sdcols]
  tab <- data.table(i = 1:7, age_group = .AGE_GROUPS, x = .X_AGES)
  tab <- agg[tab, on = "i"]
  for (v in c("fp", sdcols)) set(tab, i = which(is.na(tab[[v]])), j = v, value = 0)
  setcolorder(tab, c("i", "age_group", "x"))
  tab[]
}
