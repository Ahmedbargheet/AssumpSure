# Contributing to AssumpSure

Thank you for your interest in improving **AssumpSure**.

This package includes analytical functions and a Shiny application for assessing statistical assumptions.  
Although it is mainly maintained by a single author, feedback and community contributions are welcome.

## Fixing typos or small edits
You can correct typos or small documentation issues directly on GitHub using the web interface.  
Please edit the **source** `.R` files (roxygen comments) rather than the generated `.Rd` documentation files.

## Reporting bugs or suggesting features
If you encounter a bug, have a question, or would like to suggest an enhancement, please open a new issue on the [GitHub Issues page](../../issues).  
When reporting a problem, include a minimal reproducible example, your R version, and operating system details if relevant.

## Contributing code
If you wish to contribute code (for example, a bug fix or small feature):

1. **Fork** the repository and clone it locally.  
   You can do this easily in R with:  
   `usethis::create_from_github("Ahmedbargheet/AssumpSure", fork = TRUE)`

2. Install development dependencies with:  
   `devtools::install_dev_deps()`

3. Make your changes and ensure that the package passes all checks by running:  
   `devtools::check()`

4. Create a new branch and submit a pull request (PR) with a clear description of the changes.  
   The PR title should briefly describe the update, and the body may include `Fixes #issue-number` if it resolves a reported issue.

## Code style and testing
- Follow the [R style guide](https://style.tidyverse.org) for consistent formatting.  
- Use [roxygen2](https://cran.r-project.org/package=roxygen2) for documentation.  
- Automated tests are handled using [testthat](https://cran.r-project.org/package=testthat).  
  Please include or update relevant tests for any new functionality.

## Code of Conduct
Participation in this project is governed by the [Code of Conduct](../CODE_OF_CONDUCT.md).  
By contributing to this project, you agree to abide by its terms.
