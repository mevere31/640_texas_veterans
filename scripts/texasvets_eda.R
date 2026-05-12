# EDA for Texas Veterans (ACS PUMS via IPUMS, 2024 extract)

#initializing libraries
  library(ipumsr)
  library(dplyr)
  library(ggplot2)
  library(scales)
  library(srvyr)
  library(tibble)
  library(tidyr)

## set API key from IPUMS
my_key <- "your API key here"
set_ipums_api_key(my_key)

## see list of data
sample_list <- get_sample_info("usa")

## define an extract
extract <- define_extract_micro(
  collection = "usa",
  description = "ACS PUMS Data, 2024",
  samples = c("us2024a"),
  variables = c(
    "STATEFIP", "VETSTAT", "AGE", "SEX", "RACE", "HISPAN", "EDUC",
    "VETOTHER", "VET55X64", "VET90X01", "VET01LTR", "VET75X90", "VETVIETN",
    "VETDISAB", "EMPSTAT", "CLASSWKR", "IND", "OCC", "INCWAGE",
    "DIFFREM", "DIFFPHYS", "DIFFEYE", "DIFFHEAR",
    "DIFFSENS", "DIFFMOB", "PUMA", "PERWT", "CPI99"
  ),
  data_quality_flags = TRUE
)

## submit the API and download results
extract <- submit_extract(extract)
filepath <- download_extract(extract)

## read data
ddi <- read_ipums_ddi(filepath)
data <- read_ipums_micro(ddi)
ls(data)
table(data$VETSTAT)

variables <- c(
  "STATEFIP", "VETSTAT", "AGE", "SEX", "RACE", "HISPAN", "EDUC",
  "VETOTHER", "VET55X64", "VET90X01", "VET01LTR", "VET75X90", "VETVIETN",
  "VETDISAB", "EMPSTAT", "CLASSWKR", "IND", "OCC", "INCWAGE",
  "DIFFREM", "DIFFPHYS", "DIFFEYE", "DIFFHEAR",
  "DIFFSENS", "DIFFMOB", "PUMA", "PERWT", "CPI99"
)

data_texas <- data %>%
  select(all_of(variables)) %>%
  filter(STATEFIP == 48)

tx_survey <- data_texas %>%
  filter(AGE >= 18) %>%
  as_survey_design(weights = PERWT)

# Table 00: Texas veterans by age table
table_00 <- tx_survey %>%
  mutate(
    is_veteran = if_else(VETSTAT == 2, "Veteran", "Non-Veteran"),
    age_cat = case_when(
      AGE %in% 18:34 ~ "18 to 34 years",
      AGE %in% 35:54 ~ "35 to 54 years",
      AGE %in% 55:64 ~ "55 to 64 years",
      AGE %in% 65:74 ~ "65 to 74 years",
      AGE >= 75 ~ "75 years and over"
    )
  ) %>%
  group_by(is_veteran, age_cat) %>%
  summarize(
    count = survey_total(),
    percentage = survey_mean() * 100
  )

print(table_00)

# Table 1: Service-connected disability ratings (veterans)
table_1 <- tx_survey %>%
  filter(VETSTAT == 2) %>%
  mutate(rating_cat = as_factor(VETDISAB)) %>%
  group_by(rating_cat) %>%
  summarize(count = survey_total(), .groups = "drop") %>%
  mutate(percent = 100 * count / sum(count))
print(table_1)

# Table 2: Percent reporting disability (compare veteran vs non-veteran)
table_2 <- tx_survey %>%
  mutate(is_vet = if_else(VETSTAT == 2, "Veteran", "Non-veteran")) %>%
  group_by(is_vet) %>%
  summarize(
    Ambulatory = survey_mean(DIFFPHYS == 2, na.rm = TRUE) * 100,
    Hearing = survey_mean(DIFFHEAR == 2, na.rm = TRUE) * 100,
    Cognitive = survey_mean(DIFFREM == 2, na.rm = TRUE) * 100,
    Independent = survey_mean(DIFFMOB == 2, na.rm = TRUE) * 100,
    Self_Care = survey_mean(DIFFSENS == 2, na.rm = TRUE) * 100,
    Vision = survey_mean(DIFFEYE == 2, na.rm = TRUE) * 100
  )
print(table_2)

# Table 3: Labor force by age group
table_3 <- tx_survey %>%
  filter(EMPSTAT %in% c(1, 2)) %>%
  mutate(
    is_vet = if_else(VETSTAT == 2, "Veteran", "Non-veteran"),
    age_cat = case_when(
      AGE %in% 18:34 ~ "18 to 34 years",
      AGE %in% 35:54 ~ "35 to 54 years",
      AGE %in% 55:64 ~ "55 to 64 years",
      AGE %in% 65:74 ~ "65 to 74 years",
      AGE >= 75 ~ "75 years and over"
    )
  ) %>%
  group_by(is_vet, age_cat) %>%
  summarize(count = survey_total())

print(table_3)

# Table 4: Class of worker for veterans (labor force participants)
table_4 <- tx_survey %>%
  filter(VETSTAT == 2, EMPSTAT %in% c(1, 2)) %>%
  mutate(worker_class = as_factor(CLASSWKR)) %>%
  group_by(worker_class) %>%
  summarize(count = survey_total(), .groups = "drop") %>%
  mutate(percent = 100 * count / sum(count))

print(table_4)

# Table 5: Top 20 industries (employed veterans)
table_5 <- tx_survey %>%
  filter(VETSTAT == 2, EMPSTAT == 1) %>%
  group_by(IND_LABEL = as_factor(IND)) %>%
  summarize(count = survey_total(), .groups = "drop") %>%
  arrange(desc(count)) %>%
  slice_head(n = 20)

print(table_5)

# Table 6: Top 20 occupations (employed veterans)
table_6 <- tx_survey %>%
  filter(VETSTAT == 2, EMPSTAT == 1) %>%
  group_by(OCC_LABEL = as_factor(OCC)) %>%
  summarize(count = survey_total(), .groups = "drop") %>%
  arrange(desc(count)) %>%
  slice_head(n = 20)

print(table_6)

# Table 7: Average salary by education (employed veterans with wages)
table_7 <- tx_survey %>%
  filter(VETSTAT == 2, EMPSTAT == 1, INCWAGE > 0) %>%
  mutate(educ_level = as_factor(EDUC)) %>%
  group_by(educ_level) %>%
  summarize(avg_salary = survey_mean(INCWAGE))

print(table_7)

# Table 9: Median age by period of service (veterans) — handy for Flourish / bar charts
table_9 <- tx_survey %>%
  filter(VETSTAT == 2) %>%
  mutate(
    period = case_when(
      VET90X01 == 2 ~ "Gulf War era II",
      VET01LTR == 2 ~ "Gulf War era I",
      VETVIETN == 2 ~ "Vietnam era",
      VET75X90 == 2 ~ "May 1975–Jul 1990",
      VET55X64 == 2 ~ "Feb 1955–Jul 1964",
      VETOTHER == 2 ~ "Other period",
      TRUE ~ "Other / not classified"
    )
  ) %>%
  group_by(period) %>%
  summarize(
    median_age = survey_median(AGE, na.rm = TRUE),
    estimated_population = survey_total(),
    .groups = "drop"
  ) %>%
  arrange(desc(estimated_population))

print(table_9)

# ---- Export tables for Flourish / Excel ----
# Creates outputs/texas_vets_tables_for_charts.xlsx (one sheet per table) if package writexl is installed;
# otherwise writes one CSV per table into outputs/.
out_dir <- file.path(getwd(), "outputs")
dir.create(out_dir, showWarnings = FALSE)

table_2_long <- table_2 %>%
  pivot_longer(
    cols = -is_vet,
    names_to = "disability_type",
    values_to = "percent_reporting"
  )

simplify_df <- function(x) {
  d <- as.data.frame(x)
  d[] <- lapply(d, function(col) if (is.numeric(col)) as.numeric(col) else col)
  d
}

viz_sheets <- list(
  T00_age_by_vet_status = simplify_df(table_00),
  T01_SC_disability_rating = simplify_df(table_1),
  T02_disability_wide = simplify_df(table_2),
  T02_disability_long = simplify_df(table_2_long),
  T03_labor_force_age = simplify_df(table_3),
  T04_class_of_worker = simplify_df(table_4),
  T05_top20_industries = simplify_df(table_5),
  T06_top20_occupations = simplify_df(table_6),
  T07_wage_by_education = simplify_df(table_7),
  T09_median_age_period = simplify_df(table_9)
)

if (requireNamespace("writexl", quietly = TRUE)) {
  out_xlsx <- file.path(out_dir, "texas_vets_tables_for_charts.xlsx")
  writexl::write_xlsx(viz_sheets, out_xlsx)
  message("Wrote workbook for charts: ", normalizePath(out_xlsx, winslash = "/"))
} else {
  message("Install writexl for a single Excel file: install.packages(\"writexl\")")
  for (nm in names(viz_sheets)) {
    fn <- file.path(out_dir, paste0(nm, ".csv"))
    write.csv(viz_sheets[[nm]], fn, row.names = FALSE)
  }
  message("Wrote CSV files to: ", normalizePath(out_dir, winslash = "/"))
}
