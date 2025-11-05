test_that("Paired t-test via rstatix returns numeric p-value", {
  df <- get_sample_df()
  # ensure exactly two groups for a valid paired t-test; if more, keep first two
  if (nlevels(df$group) > 2) {
    df <- droplevels(df[df$group %in% levels(df$group)[1:2], ])
  }
  # enforce equal group sizes to allow pairing
  gs <- table(df$group)
  n  <- min(gs)
  df <- do.call(rbind, lapply(levels(df$group), function(g) head(df[df$group == g, , drop = FALSE], n)))
  
  res <- rstatix::t_test(df, value ~ group, paired = TRUE, detailed = TRUE)
  expect_true(is.data.frame(res))
  expect_true(all(c("group1", "group2", "p") %in% names(res)))
  expect_true(all(res$p >= 0 & res$p <= 1))
})
