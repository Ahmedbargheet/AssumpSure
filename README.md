# AssumpSure

[![](https://www.r-pkg.org/badges/version/AssumpSure?color=orange)](https://cran.r-project.org/package=AssumpSure) ![License: GPL-3](https://img.shields.io/badge/license-GPL--3-blue.svg) [![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![CRAN downloads](https://cranlogs.r-pkg.org/badges/grand-total/AssumpSure)](https://cran.r-project.org/package=AssumpSure)


## 🎯 Purpose
<img align="right" src="inst/app/www/logo.png" width="200" style="margin-top:40px;">

**AssumpSure** is a user-friendly **R Shiny application** that helps researchers validate statistical assumptions and select appropriate tests before analysis, ensuring valid, transparent, and reproducible results.

Misused statistical tests due to overlooked or misinterpreted assumptions can undermine scientific findings. 

With **AssumpSure**, you can:

- **Validate** statistical assumptions automatically.
- **Choose** the right test for your data with confidence.
- **Generate** publication-ready plots and summaries in one click, demonstrating transparent test selection to reviewers and readers.

---

## 👥 Who is it for?

**AssumpSure** is perfect for:

- Researchers with limited statistical expertise.
- Students, clinicians, and early-career scientists seeking a **code-free analysis workflow**.
- Teams needing reproducible, publication-ready statistical outputs.
- Anyone unsure if their data meets test assumptions.

---

## 📦 Key Features

- **Automatically check** test assumptions (normality, homogeneity, homoscedasticity, collinearity, etc.).
- **Evaluate** your test selection and recommend alternatives when appropriate.
- **Apply** Log, Yeo-Johnson, or Box-Cox transformations to non-normal data for LM and LMM, with before-and-after visualizations.
- **Support** a wide range of statistical methods.
- **Generate** boxplots, effect plots, and diagnostic plots for transparent reporting.
- **Export** plots and tables for reports or publications with **one click**.
- **Provide** an intuitive interface for users with no programming experience.

---

## 🧪 Supported Statistical Methods

- T-tests (independent & paired)
- Mann-Whitney U test
- Wilcoxon signed-rank test
- One-way ANOVA
- Kruskal-Wallis test
- Chi-square and Fisher’s exact tests
- Correlation analyses (Pearson, Spearman, Kendall, and Biweight midcorrelation)
- Linear and linear mixed-effects models
- Logistic, multinomial, Poisson and negative binomial regression

---

## 📁 Installation
**Important:** Please use R 4.2 or newer.
### CRAN

```r
install.packages("AssumpSure")
```
### GitHub
```r
# Install devtools if not already installed
install.packages("devtools")
library(devtools)

# Install AssumpSure package
devtools::install_github("Ahmedbargheet/AssumpSure")
```

---

## 🚀 Launch the App

Either with
```r
library(AssumpSure)
launch_app()
```
or 

```r
AssumpSure::launch_app()
```

---

## 💻 Use Online

You can use **AssumpSure** without installing it (performance is slower online):  
https://ahmed-bargheet.shinyapps.io/AssumpSure/

---

## 📂 Data Format Guidelines

- Use **long format**: one row per subject/timepoint (see sample CSV included with the app)
- For longitudinal studies, name your time variable exactly ***timepoint***

---

## 📖 Citation
If you use **AssumpSure** in your research, please cite it as below.

Bargheet, Ahmed. "AssumpSure: A User-Friendly R Shiny Package for Automated Validation of Statistical Assumptions and Appropriate Test Selection." Available at SSRN: https://ssrn.com/abstract=5352013 or http://dx.doi.org/10.2139/ssrn.5352013.

---

## 📚 Need Help?

For feedback or questions, feel free to contact me at ahmed.bargheet@yahoo.com
