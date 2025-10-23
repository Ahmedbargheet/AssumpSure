.onAttach <- function(libname, pkgname) {
  current <- utils::packageVersion("AssumpSure")
  latest <- "1.1.3" # hard-code my current CRAN release

  if (current < latest) {
    packageStartupMessage(
      sprintf(
        "A newer version of AssumpSure (%s) is available. You have %s.
Update with: install.packages('AssumpSure')",
        latest, current
      )
    )
  }
}
