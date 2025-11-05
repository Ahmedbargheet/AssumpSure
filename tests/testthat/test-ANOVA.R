test_that("One-way ANOVA via rstatix returns numeric p-value", {
  df <- get_sample_df()
  # limit to at most three groups for a standard one-way ANOVA check
  if (nlevels(df$group) > 3) {
    df <- droplevels(df[df$group %in% levels(df$group)[1:3], ])
  }
  res <- rstatix::anova_test(value ~ group, data = df, white.adjust = TRUE)
  expect_true(is.data.frame(res))
  expect_true("p" %in% names(res))
  expect_true(all(res$p >= 0 & res$p <= 1))
})
