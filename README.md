# AssumpSure

![License: GPL-3](https://img.shields.io/badge/license-GPL--3-blue.svg) ![Repo Status](https://img.shields.io/badge/status-active-brightgreen.svg)

## 🎯 Purpose
<img align="right" src="inst/app/www/logo.png" width="200" style="margin-top:40px;">
**AssumpSure** is a user-friendly R Shiny application that helps researchers validate statistical assumptions and choose the correct tests before running analyses.

Misused statistical tests due to overlooked assumptions can undermine scientific findings. **AssumpSure** ensures your analyses are:

- **Valid**: based on the correct model for your data type
- **Transparent**: includes assumption diagnostics and guidance
- **Reproducible**: outputs ready to share with peers or reviewers

---

## 👥 Who is it for?

- Users with limited statistical background no programming experience who want a code-free analysis workflow.
- Students, early-career scientists, and clinicians
- Teams seeking reproducible and publication-ready statistical summaries
- Anyone unsure whether test assumptions are met

---

## 📦 Features

- Automatic checking of test assumptions (normality, homogeneity, etc.)
- Evaluate your choice and guide you if a different test is more appropriate.
- Supports a wide range of statistical methods
- Visual diagnostics and easy-to-understand summaries
- One-click export of results and plots

---

## 🧪 Supported Statistical Methods

- T-tests (independent & paired)
- One-way ANOVA
- Mann–Whitney U test
- Wilcoxon signed-rank test
- Kruskal–Wallis test
- Chi-square and Fisher’s exact tests
- Correlation analyses (Pearson, Spearman, Kendall, and Biweight midcorrelation)
- Linear and linear mixed-effects models
- Logistic and multinomial regression
- Negative binomial regression

---

## 📁 Installation

```r
# Install devtools if not already installed
install.packages("devtools")
library(devtools)

# Install AssumpSure package
install_github("https://github.com/Ahmedbargheet/AssumpSure")
```
## 📁 NOTE
To enable PDF report export, you must install PhantomJS. Run this ONCE in your R session:
```r
library(webshot)
install_phantomjs()
```

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

## 📂 Data Format Guidelines

- Use **long format**: one row per subject/timepoint (see sample CSV included with the app)
- For longitudinal studies, name your time variable exactly ***timepoint***
