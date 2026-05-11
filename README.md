
# Texas veterans (INFO 640)

ACS PUMS–based exploratory analysis and a small **Figma** site.

| Path | Purpose |
|------|--------|
| `texasvets_eda.R` | Pull IPUMS microdata, build Texas `srvyr` survey object, EDA tables, and export chart JSON |
| `scripts/export_poster_viz_data.R` | Write `scripts/data/table*.json` for the embeddable charts |
| `scripts/*.html` | Plotly charts + county map (embed or open locally) |
| `scripts/county_veterans_2023.csv` | County totals for the map (static; not from PUMS without PUMA→county allocation) |

Set `IPUMS_API_KEY` before running `texasvets_eda.R`. See `scripts/README-viz.md` for chart export and hosting.
=======
# 640_texas_veterans
# Veterans in Texas (2024)  
## A Reproducible Statistical Analysis of Demographic and Workforce Patterns

---

## Project Overview

This repository contains a fully reproducible statistical analysis of the Texas veteran population using 2024 data.

The project is designed as a **School of Information Final Project**, demonstrating:

- Research design and methodology development  
- Statistical analysis in R  
- API-based data acquisition  
- Automated data cleaning and transformation  
- Reproducible workflows  
- Data visualization  
- Interpretation of findings in a policy context  

The analytical framework is informed by the structure and methodology used in:

**Texas Workforce Investment Council — *Veterans in Texas: A Demographic Study (December 2025 Update).***

This project adapts that framework to 2024 data and implements the full workflow in R.

---

## Research Question

**Primary Question:**

How do demographic characteristics, disability status, and labor force outcomes differ between veterans and nonveterans in Texas in 2024?

**Sub-questions:**

- What is the demographic composition of Texas veterans?
- How does labor force participation compare to nonveterans?
- How do unemployment rates differ by veteran status?
- How does disability prevalence vary across service eras?
- What industries and occupations employ Texas veterans?
- How do wages vary by education level?

---

## Data Sources

All data are obtained programmatically using IPUMS API.

### American Community Survey (ACS)
- Public Use Microdata Sample (PUMS)
- Five-year estimates where appropriate
- Variables include:
  - Veteran status
  - Age
  - Sex
  - Race/ethnicity
  - Educational attainment
  - Disability status
  - Employment status
  - Geographic identifiers

### Bureau of Labor Statistics (BLS)
- Current Population Survey (CPS)
- Veteran unemployment statistics
- Labor force data

---

## Methodology

This project follows a structured statistical workflow:

### 1. Conceptual Framework

Veterans are defined using standard federal definitions consistent with ACS methodology.

Key analytic categories include:

- Period of service
- Civilian labor force participation
- Disability status
- Educational attainment
- Industry and occupation classifications

---

### 2. Data Processing Pipeline

The workflow follows an **Extract → Transform → Analyze → Visualize** structure.

#### Extract
- Pull ACS data via IPUMS API

#### Transform
- Recode categorical variables
- Harmonize service-period classifications
- Create derived age groups
- Aggregate geographic units
- Clean missing values
- Construct analysis-ready datasets

#### Analyze
- Descriptive statistics
- Cross-tabulations
- Median calculations
- Group-level comparisons

#### Visualize
- Trend plots
- Distribution charts
- Comparative bar charts
- Workforce breakdowns

All steps use relative file paths to ensure portability and reproducibility.

---

## Repository Structure
640_texas-veterans/
├── references/
│ ├── Veterans-2025-Accessible-Report.pdf
│ ├── county_veterans_2023.csv
│
├── scripts/
│ ├── INFO 640 - Final Project Modeling Assignment.R
│ ├── README-viz.md
│ ├── export_poster_viz_data.R
│ ├── texasveterans_eda.R
│ ├── table15.html
│ ├── table18.html
│ ├── table17.html
│ ├── table16.html
│ ├── table14.html
│ ├── table12.html
│ ├── table10.html
│ ├── table09.html
│ ├── map_county_veterans_2023.html
│
│
├── README.md
├── LICENSE


---

>>>>>>> c7e2ecc0d97ba13609ea32357896ae267cace406
