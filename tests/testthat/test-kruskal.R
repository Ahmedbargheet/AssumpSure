test_that("Kruskal–Wallis test via rstatix returns numeric p-value", {
  df <- get_sample_df()
  # limit to at most three groups for a standard Kruskal–Wallis check
  if (nlevels(df$group) > 3) {
    df <- droplevels(df[df$group %in% levels(df$group)[1:3], ])
  }
  res <- rstatix::kruskal_test(value ~ group, data = df)
  expect_true(is.data.frame(res))
  expect_true("p" %in% names(res))
  expect_true(all(res$p >= 0 & res$p <= 1))
})
