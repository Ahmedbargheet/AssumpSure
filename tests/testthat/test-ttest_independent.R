test_that("Independent t-test via rstatix returns numeric p-value", {
  df <- get_sample_df()
  # ensure exactly two groups for a valid t test; if more, keep first two
  if (nlevels(df$group) > 2) df <- droplevels(df[df$group %in% levels(df$group)[1:2], ])
  res <- rstatix::t_test(df, value ~ group, detailed = TRUE)
  expect_true(is.data.frame(res))
  expect_true(all(c("group1", "group2", "p") %in% names(res)))
  expect_true(all(res$p >= 0 & res$p <= 1))
})
