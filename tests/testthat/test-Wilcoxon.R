test_that("Wilcoxon signed-rank test via rstatix returns numeric p-value", {
  df <- get_sample_df()
  # ensure exactly two groups for a valid paired Wilcoxon test; if more, keep first two
  if (nlevels(df$group) > 2) {
    df <- droplevels(df[df$group %in% levels(df$group)[1:2], ])
  }
  # enforce equal group sizes for pairing
  gs <- table(df$group)
  n  <- min(gs)
  df <- do.call(rbind, lapply(levels(df$group), function(g) head(df[df$group == g, , drop = FALSE], n)))
  
  res <- rstatix::wilcox_test(df, value ~ group, paired = TRUE, detailed = TRUE)
  expect_true(is.data.frame(res))
  expect_true("p" %in% names(res))
  expect_true(all(res$p >= 0 & res$p <= 1))
})
