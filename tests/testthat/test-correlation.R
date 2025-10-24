test_that("Spearman correlation returns valid r and p", {
  testthat::skip_if_not_installed("correlation")
  df <- utils::read.csv(system.file("extdata", "infants.csv", package = "AssumpSure"))
  stopifnot(all(c("weight","height") %in% names(df)))  # stable numeric cols
  
  res <- correlation::correlation(df[c("weight","height")],
                                  method = "spearman",
                                  include_factors = FALSE,
                                  redundant = FALSE)
  
  cols <- names(res)
  rcol <- intersect(c("r", "rho", "estimate"), cols)[1]
  pcol <- intersect(c("p_value", "p_value_raw", "p_value_raw_spearman", "p_raw", "p"), cols)[1]
  
  expect_true(!is.na(rcol) && !is.na(pcol))
  expect_true(is.numeric(res[[rcol]]))
  expect_true(all(is.finite(res[[rcol]])))
  expect_true(all(res[[pcol]] >= 0 & res[[pcol]] <= 1, na.rm = TRUE))
})
