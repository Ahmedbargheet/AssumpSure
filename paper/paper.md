---
title: "`AssumpSure`: a user-friendly R Shiny package for automated validation of statistical assumptions and appropriate test selection"
authors:
- affiliation: 1
  name: Ahmed Bargheet
  orcid: 0000-0002-0363-0249
  corresponding: true
date: "04 August 2025"
bibliography: paper.bib
citation_author: Bargheet
tags:
- R Shiny
- statistical assumptions
- test selection
- continuous data tests
- regression
- correlation
affiliations:
- name:  Host-Microbe Interactions Research Group, Department of Medical Biology, UiT The Arctic University of Norway, Tromsø, Norway
- index: 1
journal: JOSS
link-citations: yes
---

# Summary

`AssumpSure` is an open-source R Shiny package designed to simplify statistical analysis by automating assumption validation and guiding test selection for researchers, particularly those with limited statistical expertise. Built under the GPL-3 license, it provides a browser-based interface that integrates assumption diagnostics, test execution, and result reporting for a wide range of statistical methods, including t-tests, ANOVA, non-parametric alternatives, correlation analyses, and regression models (e.g., linear, mixed-effects, negative binomial). `AssumpSure` automatically checks assumptions (e.g., normality via Shapiro-Wilk, homogeneity via Levene’s test) and uses color-coded indicators (green for passed, red for violated) with interpretive summaries to guide users. When assumptions fail, it recommends suitable alternatives, such as Kruskal-Wallis for non-normal data in ANOVA. The package prevents invalid variable-type, offers data preprocessing tools (e.g., log, Box-Cox, centered log-ratio transformations), and generates downloadable diagnostic plots and publication-ready outputs. Hosted on GitHub with comprehensive documentation, `AssumpSure` ensures reproducible workflows, making it an accessible tool for applied researchers across disciplines.

# Statement of Need

Statistical analysis is critical across life sciences, social sciences, and biomedical research, yet test selection and assumption validation are often misapplied, especially by researchers with limited statistical experience [@hoekstra2012assumptions]. Tools like *Jamovi* [@csahin2019jamovi], *JASP* [@love2019jasp], and *EZR* [@kanda2015statistical] offer user-friendly interfaces but lack integrated workflows that enforce mandatory assumption diagnostics, appropriate test selection, and actionable recommendations, leaving users to manually interpret complex outputs. This increases errors and undermines reproducibility. For instance, a significant Shapiro-Wilk test result (*p* < 0.05) is often misinterpreted as confirming normality, when it indicates deviation [@ghasemi2012normality; @midway2025testing; @gosselin2024testing]. Additionally, non-R applications such as assumption-sheriff (Python) and StaTDS also aim to simplify statistical assumption checking and test selection. However, these alternatives lack fully integrated, interactive diagnostic workflows or do not provide enforced guidance on test appropriateness for each step.

`AssumpSure`, an open-source R Shiny package, addresses this by uniquely integrates mandatory automated assumption checks, displaying results in color-coded squares, and guiding users to suitable tests. Its cohesive interface blocks invalid selections, provides interpretable summaries, and generates downloadable diagnostic plots for transparent reporting. `AssumpSure` empowers researchers to conduct rigorous, reproducible analyses without coding or extensive statistical expertise.

# Software Description
`AssumpSure`’s modular R Shiny architecture organizes statistical analyses into continuous variable tests, categorical tests, correlations, and regression models. Users upload CSV data, and the interface automatically detects variable types, preventing invalid selections with clear error messages (e.g., suggesting one-way ANOVA if a t-test is chosen for a categorical variable with three levels). Each analysis obligates automated assumption checks (e.g., normality via Shapiro-Wilk, homogeneity via Levene’s test), visualized through plots like QQ plots, histograms, and scatterplots, with tooltips guiding interpretation. Results are displayed with color-coded indicators (green for passed, red for violated, yellow for borderline cases) and summaries that guide next steps (e.g., “Assumptions are not met for One-way ANOVA; consider Kruskal-Wallis”). 

For correlations, a tooltip explains the centered log-ratio (CLR) transformation’s importance in reducing spurious correlations in compositional data (e.g., microbiome profiles). Prevalence filtering is available for correlations to enhance reliability. For regression models, transformations like log or Box-Cox are offered to improve residual normality and reduce heteroscedasticity, with guidance on their role in ensuring model validity. The package supports independent/paired t-tests, Welch test, one-way ANOVA, Mann-Whitney U, Wilcoxon signed-rank, Kruskal-Wallis, chi-square, Fisher’s exact, linear, logistic, multinomial, Poisson, negative binomial, zero-inflated negative binomial, and mixed-effects models, plus Pearson, Spearman, Kendall, and biweight midcorrelation methods. 

Post-hoc comparisons (e.g., Tukey HSD, Dunn’s test) and multiple testing corrections (e.g., Benjamini-Hochberg) are included where applicable. Outputs, including p-values, confidence intervals, effect sizes, and publication-ready plots, are exportable in PNG, PDF, or CSV formats for transparent reporting. `AssumpSure` integrates R libraries like *rstatix* [@kassambara2019rstatix], *performance* [@ludecke2021performance], *lmerTest* [@kuznetsova2015package], *MASS* [@ripley2013package], and *bestNormalize* [@peterson2020package] for robust functionality, with additional packages like readr [@wickham2024package], dplyr [@yarberry2021dplyr] and ggplot2 [@wickham2011ggplot2] enhancing data handling and visualization.

![](paper/figure1.png)
Figure 1: The workflow from data upload to test selection, guiding users to switch to the appropriate statistical test.


# Illustrative Example

A researcher uploads a CSV dataset, imported using the readr package [@wickham2024package] with bacterial alpha diversity (Shannon index) across three countries. `AssumpSure` detects variable types, restricting invalid selections (e.g., excluding count variables for ANOVA). Selecting one-way ANOVA triggers normality (Shapiro-Wilk) and homogeneity (Levene’s) checks using the rstatix package [@kassambara2019rstatix], visualized via QQ plots and histograms with ggplot2 [@wickham2011ggplot2] with tooltips are implemented using the shiny package [@chang2015package] (which provides the icon() function and HTML integration for Bootstrap tooltips). A red indicator signals non-normality and heterogeneous variances, recommending Kruskal-Wallis. Switching to this test, the user obtains significant results (*p* < 0.05) and effect size using Kruskal-Wallis eta-squared, also based on rstatix [@kassambara2019rstatix]. The user can run Dunn's with p-value correction such as Benjamini-Hochberg based on rstatix R package [@kassambara2019rstatix], and downloading a publication-ready boxplot. This workflow, requiring no coding, ensures valid test selection and transparent reporting for researchers with minimal statistical expertise.

![](paper/figure2.png)
Figure 2: The assumption checking report.
![](paper/figure3.png)
Figure 3: Kruskal-Wallis test and effect sizes estimation using Kruskal-Wallis eta-squared.
![](paper/figure4.png)
Figure 4: Dunn test and Wilcoxon r unpaired test for effect size, and publication-ready boxplot.

# Limitations
`AssumpSure` accepts UTF-8, comma-delimited CSV files with a header row (parsed by readr package [@wickham2024package]. Unusual delimiters or encodings are not supported. There is no strict size limit, but large files may slow performance. `AssumpSure` visualizes assumption checks using diagnostic plots (e.g., from the *performance* package [@ludecke2021performance]) and provides general guidance via tooltips, but does not generate automated, context-specific recommendations. Users should interpret plots with the provided guidance.

# Licensing and Availability

`AssumpSure` is licensed under the GPL-3 license, with all source code stored at GitHub (<https://github.com/Ahmedbargheet/AssumpSure>). In the spirit of honest and open science, we encourage requests, tips for fixes, feature updates, as well as general questions and concerns via direct interaction with the developer.

# Acknowledgments

`AssumpSure` acknowledges the open-source R community for maintaining the packages that support the application’s statistical and graphical functionality.

# References
