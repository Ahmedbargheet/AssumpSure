test_that("Shapiro-Wilk via rstatix runs and returns valid p-values", {
  df <- get_sample_df() %>%
    dplyr::group_by(group) %>%
    dplyr::filter(dplyr::n() >= 3) %>%
    dplyr::ungroup()
  skip_if(nrow(df) == 0 || length(unique(df$group)) == 0, "No groups with n ≥ 3")
  res <- df %>%
    dplyr::group_by(group) %>%
    rstatix::shapiro_test(value)
  expect_true(is.data.frame(res))
  expect_true(all(c("group", "statistic", "p") %in% names(res)))
  expect_true(all(res$p >= 0 & res$p <= 1))
})
