test_that("Levene's test via rstatix runs and returns valid p-value", {
  df <- get_sample_df()
  res <- suppressWarnings(rstatix::levene_test(value ~ group, data = df))
  expect_true(is.data.frame(res))
  expect_true("p" %in% names(res))
  expect_true(all(res$p >= 0 & res$p <= 1))
})
