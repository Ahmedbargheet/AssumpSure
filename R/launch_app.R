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
  app_dir <- system.file("app", package = "AssumpSure")
  if (app_dir == "") stop("Could not find app directory. Try re-installing the package.", call. = FALSE)
  shiny::runApp(app_dir, display.mode = "normal")
}
