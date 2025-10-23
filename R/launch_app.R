#' Launch the AssumpSure Shiny App
#'
#' @return Runs the Shiny app.
#' @export
#'
#' @examples
#' if (interactive()) {
#'   launch_app()
#' }
launch_app <- function() {
  # --- version check (optional but user-friendly) ---
  current <- utils::packageVersion("AssumpSure")
  latest <- "1.1.3" # update this when you release a new version
  if (current < latest) {
    packageStartupMessage(
      sprintf(
        "A newer version of AssumpSure (%s) is available. You have %s.
Update with: install.packages('AssumpSure')",
        latest, current
      )
    )
  }

  # --- existing app launcher ---
  app_dir <- system.file("app", package = "AssumpSure")
  if (app_dir == "") stop("Could not find app directory. Try re-installing the package.", call. = FALSE)
  shiny::runApp(app_dir, display.mode = "normal")
}
