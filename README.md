# Exploratory Data Analysis: Opioid- and Stimulant-related Harms in Canada (2016–2025)

![R](https://img.shields.io/badge/Language-R-276DC3?style=flat&logo=r)
![Data Source](https://img.shields.io/badge/Source-Public%20Health%20Agency%20of%20Canada-red)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)
![License](https://img.shields.io/badge/License-Open%20Government-blue)

## 📋 Project Overview

This project presents a comprehensive **Exploratory Data Analysis (EDA)** of the 
*Opioid- and Stimulant-related Harms in Canada* dataset, published quarterly by the 
**Public Health Agency of Canada (PHAC)**. The analysis examines national trends, 
geographic patterns, demographic breakdowns, and the growing role of fentanyl in 
Canada's ongoing drug toxicity crisis.

---

## 🎯 Research Questions

- How have opioid and stimulant deaths trended nationally from 2016 to 2024, and what role did COVID-19 play?
- Which provinces carry the highest burden of opioid-related deaths?
- Which demographic groups — by age and sex — are most affected?
- How has the role of fentanyl in opioid deaths changed over time?
- Are all four harm types (deaths, hospitalizations, ED visits, EMS responses) trending together?

---

## 📊 Dataset

| Attribute | Details |
|-----------|---------|
| **Source** | Public Health Agency of Canada (PHAC) |
| **URL** | https://health-infobase.canada.ca/substance-related-harms/opioids-stimulants/ |
| **Rows** | 24,464 |
| **Columns** | 11 (original) + 3 derived = 14 after cleaning |
| **Coverage** | January 2016 – September 2025 |
| **Update Frequency** | Quarterly |
| **License** | Open Government Licence – Canada |

### Key Fields
- `Substance` — Opioids or Stimulants
- `Source` — Deaths, Hospitalizations, ED Visits, EMS Responses
- `Region` — Canada, provinces, territories (19 regions)
- `Year_Quarter` — Annual or quarterly time period
- `Unit` — Number, Crude rate per 100,000, or Percent
- `Value` — Numeric value or "Suppr." for suppressed small counts

---

## 🧹 Data Cleaning

Four cleaning steps were applied — **no rows were deleted**:

1. **Blank → NA conversion** — 6,596 empty strings in `Aggregator`/`Disaggregator` converted to proper `NA` for correct R filtering
2. **Numeric conversion** — `Value` column converted from string to numeric; "Suppr." entries become `NA`
3. **Suppressed value flagging** — 2,357 rows (9.6%) flagged with a `Suppressed` Boolean column for transparency
4. **Year extraction** — Clean 4-digit `Year_clean` column extracted using regex, handling entries like "2025 (Jan to Sep)"

---

## 📈 Key Findings

| Finding | Detail |
|---------|--------|
| **Peak deaths** | 8,020 opioid deaths in 2023 — nearly 3× the 2016 level |
| **COVID-19 surge** | Deaths jumped 72% in 2020 alone |
| **Highest province** | British Columbia — 2,344 deaths and 41.3 per 100,000 in 2024 |
| **Fentanyl** | Involved in 52% of deaths in 2016, rising to 86% in 2021 |
| **Sex disparity** | Males account for ~72% of deaths — consistent across all 9 years |
| **Most affected age** | Adults aged 30–39 — 28% of all deaths in 2024 |
| **Skewed distribution** | Mean (454) far exceeds median (75) — BC and ON are extreme outliers |

---

## 📉 Visualizations

| Figure | Type | Description |
|--------|------|-------------|
| Fig 1 | Bar chart | Data quality overview pre-cleaning |
| Fig 2 | Bar + line | National opioid deaths trend 2016–2024 |
| Fig 3 | Horizontal bar | Deaths by province/territory 2024 |
| Fig 4 | Line chart | Opioids vs. Stimulants comparison |
| Fig 5 | Stacked bar | Deaths by age group (%) |
| Fig 6 | Stacked bar | Deaths by sex (%) |
| Fig 7 | Bar + line | Fentanyl involvement trend |
| Fig 8 | Area panel | All four harm types |
| Fig 9 | Heatmap | Crude death rates by province and year |
| Fig 10 | **Histogram** | Distribution of provincial death counts |
| Fig 11 | **Boxplot** | Death rate variability by province |
| Fig 12 | **Scatterplot** | Deaths vs. hospitalizations relationship |

---

## 🗂️ Repository Structure

```
opioid-harms-canada-eda/
│
├── README.md                          # This file
├── opioid_eda_final.R                 # Complete R code
├── SubstanceHarmsData.csv             # Raw dataset from PHAC
├── Riddhi-Final_Project1.pdf          # Full EDA report
│
├── fig1_data_quality.png
├── fig2_national_deaths_trend.png
├── fig3_deaths_by_province_2024.png
├── fig4_opioid_vs_stimulant.png
├── fig5_deaths_by_age.png
├── fig6_deaths_by_sex.png
├── fig7_fentanyl_trend.png
├── fig8_four_harm_types.png
├── fig9_heatmap_province_year.png
├── fig10_histogram_deaths.png
├── fig11_boxplot_provinces.png
└── fig12_scatterplot.png
```

---

## 🛠️ How to Run

### Prerequisites
```r
install.packages(c("tidyverse", "ggplot2", "scales", "RColorBrewer"))
```

### Steps
1. Clone this repository
```bash
git clone https://github.com/YOUR_USERNAME/opioid-harms-canada-eda.git
```

2. Place `SubstanceHarmsData.csv` in the same folder as `opioid_eda_final.R`

3. Open `opioid_eda_final.R` in RStudio

4. Set working directory:
   **Session → Set Working Directory → To Source File Location**

5. Run all code:
   **Ctrl + Shift + Enter**

All 12 figures will be saved as PNG files in your working directory.

---

## 🔍 Further Research Questions

- Can quarterly data reveal seasonal overdose patterns by province?
- What explains BC's persistently higher crude rates even after population adjustment?
- Can this dataset be linked to socioeconomic indicators at the Census Subdivision level?
- Will the 2024 decline in deaths continue as 2025 full-year data becomes available?
- Does the deaths–hospitalizations correlation hold at the provincial level?

---

## 📚 References

Public Health Agency of Canada. (2026, March). *Opioid- and Stimulant-related Harms in Canada* [Dataset]. Public Health Infobase. https://health-infobase.canada.ca/substance-related-harms/opioids-stimulants/

---

*This project was completed as part of a course assignment. Data is sourced from the Government of Canada under the Open Government Licence.*
