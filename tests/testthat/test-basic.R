test_that("App launches without error", {
  testthat::skip("Disable Shiny launch during tests")
  expect_error(AssumpSure::launch_app(), NA)
})
