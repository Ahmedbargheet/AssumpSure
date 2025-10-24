test_that("Linear model returns valid coefficients and p-values", {
  df <- utils::read.csv(system.file("extdata", "infants.csv", package = "AssumpSure"))
  
  # pick numeric response and at least one predictor
  num_cols <- names(df)[sapply(df, is.numeric)]
  expect_true(length(num_cols) >= 2)
  resp <- num_cols[1]
  pred <- num_cols[2]
  
  formula <- stats::as.formula(paste(resp, "~", pred))
  fit <- stats::lm(formula, data = df)
  
  s <- summary(fit)
  expect_s3_class(fit, "lm")
  expect_true("coefficients" %in% names(s))
  expect_true(all(!is.na(s$coefficients[, "Pr(>|t|)"])))
  expect_true(all(s$coefficients[, "Pr(>|t|)"] >= 0 & s$coefficients[, "Pr(>|t|)"] <= 1))
})
