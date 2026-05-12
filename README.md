# Texas veterans (INFO 640 / 658)

# 640_texas_veterans  
## Veterans in Texas (2024) — Statistical Analysis and Visualization Project

---

## Project Overview

This repository contains a reproducible statistical analysis of the Texas veteran population, developed as part of **INFO 640 – Final Project**.

The project uses R to analyze demographic, geographic, and workforce characteristics of Texas veterans and compares trends over time. The analysis is informed by the structure and methodology used in:

**Texas Workforce Investment Council — *Veterans in Texas: A Demographic Study (December 2025 Update).***

This project adapts that framework using updated data and implements the analysis through reproducible scripts and generated visualizations.

---

## Research Focus

This project examines:

- Demographic characteristics of Texas veterans  
- Geographic distribution of veterans across counties  
- Changes in veteran population from 2014–2024  
- Workforce characteristics and employment patterns  
- Comparative civilian vs. veteran status trends  
- Visual mapping of veteran population change  

---

## Repository Structure

The repository is organized as follows:
640_texas_veterans/
│
├── references/
│ ├── Veterans-2025-Accessible.pdf
│ ├── county_veterans_2023.csv
│
│
├── scripts/
│ ├── INFO 640 - Final Project Modeling Assignment.R
│ ├── texasveterans_eda.R
│
├── README.md
└── LICENSE


### Key Components

- **R scripts**: Core data analysis, modeling, and visualization
- **CSV files**: County-level veteran data
- **PDF reference report**: Methodological guide
- **HTML tables**: Exported analytical summaries

---

## Data Sources

The project draws from:

### American Community Survey (ACS)
- Public Use Microdata (PUMS)
- Veteran status
- Age
- Sex
- Race/ethnicity
- Educational attainment
- Geographic identifiers

### Additional Data
- County-level veteran population files
- - Workforce and demographic summaries

---

## Methodology

The project follows a structured analytical workflow:

### 1. Data Cleaning and Preparation
- Reformatting county-level datasets
- Harmonizing veteran classification variables
- Preparing time-series comparisons
- Aggregating demographic variables

### 2. Exploratory Data Analysis (EDA)
- Summary statistics
- Demographic breakdowns
- County-level comparisons
- Trend analysis across years

### 3. Geographic Analysis
- Mapping changes in veteran population (2014–2024)
- County-level visualization
- Regional distribution analysis

### 4. Workforce Analysis
- Civilian vs. veteran comparisons
- Employment distribution
- Population proportion analysis

---

## Key Scripts

### `INFO 640 - Final Project Modeling Assignment.R`
Main analytical script containing modeling and statistical analysis.

### `texasveterans_eda.R`
Exploratory data analysis, summary statistics, and initial visualizations.

---

## Reproducibility

This project emphasizes reproducible research practices:

- Analysis conducted in R
- Script-based workflow
- Relative file paths
- Structured data inputs
- Generated outputs stored in repository
- Visualizations produced directly from code
- No manual spreadsheet editing of analytical datasets

To reproduce the analysis:

1. Clone the repository.
2. Open the `.R` scripts in RStudio.
3. Run scripts in logical order.

---

## Visual Outputs

The repository includes:

- County-level veteran maps
- Population trend visualizations
- Comparative civilian vs veteran charts
- Presentation-ready graphics

These outputs support both the analytical narrative and portfolio presentation requirements.

---


## Tools and Technologies

- R
- Tidyverse
- Data visualization packages (e.g., ggplot2)
- Geographic mapping libraries
- HTML for static site presentation
- Git for version control
- Flourish

---

## License

This project is released under the terms specified in the `LICENSE` file.

---

## Acknowledgments

This project was informed by the structure and analytical framework of:

Texas Workforce Investment Council — *Veterans in Texas: A Demographic Study (December 2025 Update)*

The report provided guidance on:
- Veteran classification
- Geographic aggregation
- Workforce analysis
- Disability and demographic categories
- Presentation structure

---

## Author

Mikala Everett  
INFO 640 Final Project  
School of Information
