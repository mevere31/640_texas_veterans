# Export JSON for GitHub Pages / Figma embed charts (poster_viz/*.html)
#
# Prerequisite: run texasvets_eda.R through creation of `tx_survey`
# (ACS PUMS Texas, age 18+, PERWT-weighted srvyr design).
#
# Usage:
#   source("texasvets_eda.R")   # or run through building tx_survey
#   source("poster_viz/export_poster_viz_data.R")

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(rlang)
  library(survey)
  library(srvyr)
})

if (!exists("tx_survey", inherits = FALSE)) {
  stop("Object `tx_survey` not found. Run texasvets_eda.R first through the survey design step.")
}

if (!exists("data_texas", inherits = FALSE)) {
  stop("Object `data_texas` not found. Run texasvets_eda.R through the Texas filter step.")
}

if (!requireNamespace("jsonlite", quietly = TRUE)) {
  stop("Install jsonlite: install.packages('jsonlite')")
}

out_dir <- file.path("poster_viz", "data")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

meta_base <- list(
  source = "ACS PUMS (IPUMS), Texas, age 18+",
  year   = 2024L,
  weight = "PERWT"
)

# --- Table 9: median age by period of service (veterans only) ---
# Period hierarchy: "most recent" era using VET* flags in your extract (codes: 2 = yes — confirm in DDI).
vet_for_period <- data_texas %>%
  dplyr::filter(VETSTAT == 2, AGE >= 18) %>%
  dplyr::mutate(
    period = dplyr::case_when(
      VET90X01 == 2 ~ "Gulf War era II",
      VET01LTR == 2 ~ "Gulf War era I",
      VETVIETN == 2 ~ "Vietnam era",
      VET75X90 == 2 ~ "May 1975–Jul 1990",
      VET55X64 == 2 ~ "Feb 1955–Jul 1964",
      VETOTHER == 2 ~ "Other period",
      TRUE          ~ "Other / not classified"
    )
  )

des_vet <- suppressWarnings(survey::svydesign(ids = ~1, weights = ~PERWT, data = vet_for_period))

qb <- survey::svyby(~AGE, ~period, des_vet, survey::svyquantile, quantiles = 0.5, ci = FALSE, keep.var = TRUE)
qb_df <- as.data.frame(qb)

# svyby/svyquantile column naming varies by survey version — grab first AGE-related numeric column
age_cols <- grep("AGE", names(qb_df), value = TRUE)
if (length(age_cols) == 0) {
  stop("Could not parse median age column from svyby output; names were: ", paste(names(qb_df), collapse = ", "))
}
ac <- qb_df[[age_cols[[1]]]]
median_age <- if (is.matrix(ac)) as.numeric(ac[, 1, drop = TRUE]) else as.numeric(ac)

t9_med <- data.frame(period = as.character(qb_df$period), median_age = median_age, stringsAsFactors = FALSE)

counts_period <- tx_survey %>%
  dplyr::filter(VETSTAT == 2) %>%
  dplyr::mutate(
    period = dplyr::case_when(
      VET90X01 == 2 ~ "Gulf War era II",
      VET01LTR == 2 ~ "Gulf War era I",
      VETVIETN == 2 ~ "Vietnam era",
      VET75X90 == 2 ~ "May 1975–Jul 1990",
      VET55X64 == 2 ~ "Feb 1955–Jul 1964",
      VETOTHER == 2 ~ "Other period",
      TRUE          ~ "Other / not classified"
    )
  ) %>%
  dplyr::group_by(period) %>%
  dplyr::summarize(total = survey_total(), .groups = "drop")

t9 <- t9_med %>%
  dplyr::left_join(counts_period, by = "period") %>%
  dplyr::arrange(dplyr::desc(total))

jsonlite::write_json(
  list(meta = c(meta_base, list(table = "Median age by period of service (veterans)")), rows = t9),
  file.path(out_dir, "table09.json"),
  auto_unbox = TRUE,
  pretty = TRUE,
  na = "null"
)

# --- Table 10: disability types, veteran vs non-veteran (%) ---
# ACS difficulty: 2 = "Yes" for this extract (matches texasvets_eda.R logic).
disability_pct_and_n <- function(var) {
  v <- enexpr(var)
  p <- tx_survey %>%
    dplyr::mutate(is_vet = dplyr::if_else(VETSTAT == 2, "Veteran", "Non-veteran")) %>%
    dplyr::group_by(is_vet) %>%
    dplyr::summarize(pct = survey_mean((!!v) == 2, na.rm = TRUE) * 100, .groups = "drop") %>%
    tidyr::pivot_wider(names_from = is_vet, values_from = pct, names_prefix = "pct_")

  n <- tx_survey %>%
    dplyr::mutate(is_vet = dplyr::if_else(VETSTAT == 2, "Veteran", "Non-veteran")) %>%
    dplyr::filter((!!v) == 2) %>%
    dplyr::group_by(is_vet) %>%
    dplyr::summarize(n = survey_total(), .groups = "drop") %>%
    tidyr::pivot_wider(names_from = is_vet, values_from = n, names_prefix = "n_")

  dplyr::bind_cols(p, n)
}

t10 <- dplyr::bind_rows(
  dplyr::bind_cols(data.frame(disability = "Ambulatory difficulty", stringsAsFactors = FALSE), disability_pct_and_n(DIFFPHYS)),
  dplyr::bind_cols(data.frame(disability = "Hearing difficulty", stringsAsFactors = FALSE), disability_pct_and_n(DIFFHEAR)),
  dplyr::bind_cols(data.frame(disability = "Cognitive difficulty", stringsAsFactors = FALSE), disability_pct_and_n(DIFFREM)),
  dplyr::bind_cols(data.frame(disability = "Independent living difficulty", stringsAsFactors = FALSE), disability_pct_and_n(DIFFMOB)),
  dplyr::bind_cols(data.frame(disability = "Self-care difficulty", stringsAsFactors = FALSE), disability_pct_and_n(DIFFSENS)),
  dplyr::bind_cols(data.frame(disability = "Vision difficulty", stringsAsFactors = FALSE), disability_pct_and_n(DIFFEYE))
) %>%
  dplyr::transmute(
    disability,
    vet_pct    = pct_Veteran,
    nonvet_pct = .data[["pct_Non-veteran"]],
    vet_n      = n_Veteran,
    nonvet_n   = .data[["n_Non-veteran"]]
  )

jsonlite::write_json(
  list(meta = c(meta_base, list(table = "Disability types (18+), veteran vs non-veteran")), rows = t10),
  file.path(out_dir, "table10.json"),
  auto_unbox = TRUE,
  pretty = TRUE,
  na = "null"
)

# --- Table 12: service-connected disability rating (veterans) ---
t12 <- tx_survey %>%
  dplyr::filter(VETSTAT == 2) %>%
  dplyr::mutate(rating_cat = as_factor(VETDISAB)) %>%
  dplyr::group_by(rating_cat) %>%
  dplyr::summarize(count = survey_total(), .groups = "drop") %>%
  dplyr::mutate(
    rating = as.character(rating_cat),
    pct    = 100 * count / sum(count)
  ) %>%
  dplyr::transmute(rating, n = count, pct)

jsonlite::write_json(
  list(meta = c(meta_base, list(table = "Service-connected disability ratings (veterans)")), rows = t12),
  file.path(out_dir, "table12.json"),
  auto_unbox = TRUE,
  pretty = TRUE,
  na = "null"
)

# --- Table 14-style: labor force by age, employed vs unemployed, vet vs non-vet ---
age_levels <- c(
  "18 to 34 years",
  "35 to 54 years",
  "55 to 64 years",
  "65 to 74 years",
  "75 years and over"
)

lf <- tx_survey %>%
  dplyr::filter(EMPSTAT %in% c(1, 2)) %>%
  dplyr::mutate(
    is_vet  = dplyr::if_else(VETSTAT == 2, "Veteran", "Non-veteran"),
    age_cat = factor(
      dplyr::case_when(
        AGE %in% 18:34 ~ "18 to 34 years",
        AGE %in% 35:54 ~ "35 to 54 years",
        AGE %in% 55:64 ~ "55 to 64 years",
        AGE %in% 65:74 ~ "65 to 74 years",
        AGE >= 75      ~ "75 years and over"
      ),
      levels = age_levels
    ),
    emp = dplyr::if_else(EMPSTAT == 1, "employed", "unemployed")
  )

cell <- lf %>%
  dplyr::group_by(age_cat, is_vet, emp) %>%
  dplyr::summarize(n = survey_total(), .groups = "drop")

denom <- cell %>%
  dplyr::group_by(is_vet, emp) %>%
  dplyr::summarize(denom = sum(n), .groups = "drop")

cell2 <- cell %>%
  dplyr::left_join(denom, by = c("is_vet", "emp")) %>%
  dplyr::mutate(
    pct_within = ifelse(denom > 0, 100 * n / denom, NA_real_),
    slot = dplyr::case_when(
      is_vet == "Veteran" & emp == "employed" ~ "employed_vet",
      is_vet == "Veteran" & emp == "unemployed" ~ "unemployed_vet",
      is_vet == "Non-veteran" & emp == "employed" ~ "employed_nonvet",
      TRUE ~ "unemployed_nonvet"
    )
  )

w_n <- cell2 %>%
  dplyr::select(age_cat, slot, n) %>%
  tidyr::pivot_wider(id_cols = age_cat, names_from = slot, values_from = n, values_fill = 0)

w_pct <- cell2 %>%
  dplyr::select(age_cat, slot, pct_within) %>%
  tidyr::pivot_wider(
    id_cols = age_cat,
    names_from = slot,
    values_from = pct_within,
    names_prefix = "pct_",
    values_fill = 0
  )

t14 <- dplyr::left_join(w_n, w_pct, by = "age_cat") %>%
  dplyr::mutate(
    age = dplyr::case_when(
      as.character(age_cat) == "18 to 34 years" ~ "18–34",
      as.character(age_cat) == "35 to 54 years" ~ "35–54",
      as.character(age_cat) == "55 to 64 years" ~ "55–64",
      as.character(age_cat) == "65 to 74 years" ~ "65–74",
      TRUE ~ "75+"
    )
  ) %>%
  dplyr::transmute(
    age,
    employed_vet_n        = employed_vet,
    employed_vet_pct      = pct_employed_vet,
    unemployed_vet_n      = unemployed_vet,
    unemployed_vet_pct    = pct_unemployed_vet,
    employed_nonvet_n     = employed_nonvet,
    employed_nonvet_pct   = pct_employed_nonvet,
    unemployed_nonvet_n   = unemployed_nonvet,
    unemployed_nonvet_pct = pct_unemployed_nonvet
  )

# Total employed (all people) by age — for hover note in chart
tot_emp <- tx_survey %>%
  dplyr::filter(EMPSTAT == 1) %>%
  dplyr::mutate(
    age_cat = factor(
      dplyr::case_when(
        AGE %in% 18:34 ~ "18 to 34 years",
        AGE %in% 35:54 ~ "35 to 54 years",
        AGE %in% 55:64 ~ "55 to 64 years",
        AGE %in% 65:74 ~ "65 to 74 years",
        AGE >= 75      ~ "75 years and over"
      ),
      levels = age_levels
    )
  ) %>%
  dplyr::group_by(age_cat) %>%
  dplyr::summarize(total_employed_all = survey_total(), .groups = "drop") %>%
  dplyr::mutate(
    age = dplyr::case_when(
      as.character(age_cat) == "18 to 34 years" ~ "18–34",
      as.character(age_cat) == "35 to 54 years" ~ "35–54",
      as.character(age_cat) == "55 to 64 years" ~ "55–64",
      as.character(age_cat) == "65 to 74 years" ~ "65–74",
      TRUE ~ "75+"
    )
  ) %>%
  dplyr::select(age, total_employed_all)

t14 <- t14 %>% left_join(tot_emp, by = "age")

jsonlite::write_json(
  list(meta = c(meta_base, list(table = "Labor force by age (employed vs unemployed)")), rows = t14),
  file.path(out_dir, "table14.json"),
  auto_unbox = TRUE,
  pretty = TRUE,
  na = "null"
)

# --- Table 15: class of worker (veteran labor force participants) ---
t15 <- tx_survey %>%
  dplyr::filter(VETSTAT == 2, EMPSTAT %in% c(1, 2)) %>%
  dplyr::mutate(worker_class = as_factor(CLASSWKR)) %>%
  dplyr::group_by(worker_class) %>%
  dplyr::summarize(n = survey_total(), .groups = "drop") %>%
  dplyr::mutate(
    label = as.character(worker_class),
    pct   = 100 * n / sum(n)
  ) %>%
  dplyr::select(label, n, pct)

jsonlite::write_json(
  list(meta = c(meta_base, list(table = "Class of worker (veteran labor force)")), rows = t15),
  file.path(out_dir, "table15.json"),
  auto_unbox = TRUE,
  pretty = TRUE,
  na = "null"
)

# --- Table 16: top 20 industries (employed veterans) ---
vet_lf <- tx_survey %>%
  dplyr::filter(VETSTAT == 2, EMPSTAT %in% c(1, 2)) %>%
  dplyr::summarize(lf = survey_total()) %>%
  dplyr::pull(lf)

t16 <- tx_survey %>%
  dplyr::filter(VETSTAT == 2, EMPSTAT == 1) %>%
  dplyr::group_by(industry = as_factor(IND)) %>%
  dplyr::summarize(n = survey_total(), .groups = "drop") %>%
  dplyr::arrange(dplyr::desc(n)) %>%
  dplyr::slice_head(n = 20) %>%
  dplyr::mutate(
    industry = as.character(industry),
    pct = dplyr::if_else(vet_lf > 0, 100 * n / vet_lf, NA_real_)
  )

jsonlite::write_json(
  list(meta = c(meta_base, list(table = "Top 20 industries (employed veterans), pct of veteran LF")), rows = t16),
  file.path(out_dir, "table16.json"),
  auto_unbox = TRUE,
  pretty = TRUE,
  na = "null"
)

# --- Table 17: top 20 occupations (employed veterans) ---
vet_emp <- tx_survey %>%
  dplyr::filter(VETSTAT == 2, EMPSTAT == 1) %>%
  dplyr::summarize(n = survey_total()) %>%
  dplyr::pull(n)

t17 <- tx_survey %>%
  dplyr::filter(VETSTAT == 2, EMPSTAT == 1) %>%
  dplyr::group_by(occupation = as_factor(OCC)) %>%
  dplyr::summarize(n = survey_total(), .groups = "drop") %>%
  dplyr::arrange(dplyr::desc(n)) %>%
  dplyr::slice_head(n = 20) %>%
  dplyr::mutate(
    occupation = as.character(occupation),
    pct = dplyr::if_else(vet_emp > 0, 100 * n / vet_emp, NA_real_)
  )

jsonlite::write_json(
  list(meta = c(meta_base, list(table = "Top 20 occupations (employed veterans)")), rows = t17),
  file.path(out_dir, "table17.json"),
  auto_unbox = TRUE,
  pretty = TRUE,
  na = "null"
)

# --- Table 18: average wage by education (collapsed to TWIC-style buckets) ---
# EDUC numeric codes vary; map using standard PUMS buckets (verify in DDI if labels look off).
edu_tw18 <- function(educ) {
  e <- as.integer(educ)
  dplyr::case_when(
    e %in% c(0L, 1L) ~ NA_character_,
    e %in% 2L:10L ~ "Less than ninth grade",
    e %in% 11L:15L ~ "Grade 9–12, no diploma",
    e %in% c(16L, 17L) ~ "High school graduate (includes equivalency)",
    e %in% 18L:20L ~ "Some college, no degree",
    e %in% c(21L, 22L) ~ "Associate's degree",
    e == 23L ~ "Bachelor's degree",
    e %in% c(24L, 25L, 26L) ~ "Master's degree or higher",
    TRUE ~ NA_character_
  )
}

t18 <- tx_survey %>%
  dplyr::filter(VETSTAT == 2, EMPSTAT == 1, INCWAGE > 0) %>%
  dplyr::mutate(edu_bucket = edu_tw18(EDUC)) %>%
  dplyr::filter(!is.na(edu_bucket)) %>%
  dplyr::group_by(edu_bucket) %>%
  dplyr::summarize(
    salary = survey_mean(INCWAGE, na.rm = TRUE),
    n      = survey_total(),
    .groups = "drop"
  ) %>%
  dplyr::mutate(pct = 100 * n / sum(n)) %>%
  dplyr::mutate(
    edu_bucket = factor(
      edu_bucket,
      levels = c(
        "Less than ninth grade",
        "Grade 9–12, no diploma",
        "High school graduate (includes equivalency)",
        "Some college, no degree",
        "Associate's degree",
        "Bachelor's degree",
        "Master's degree or higher"
      )
    )
  ) %>%
  dplyr::arrange(edu_bucket) %>%
  dplyr::transmute(edu = as.character(edu_bucket), salary, pct)

jsonlite::write_json(
  list(meta = c(meta_base, list(table = "Average wage by education (employed veterans)")), rows = t18),
  file.path(out_dir, "table18.json"),
  auto_unbox = TRUE,
  pretty = TRUE,
  na = "null"
)

message("Wrote JSON files to ", normalizePath(out_dir, winslash = "/", mustWork = FALSE))
