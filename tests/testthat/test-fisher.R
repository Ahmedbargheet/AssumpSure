test_that("Fisher's exact test returns numeric p-value", {
  df <- utils::read.csv(system.file("extdata", "infants.csv", package = "AssumpSure"))
  
  # pick two categorical/binary columns safely
  vars <- intersect(c("fortified", "nutrients", "diarrhea", "gender"), names(df))
  expect_true(length(vars) >= 2)
  
  d2 <- df[, vars[1:2]]
  d2 <- stats::na.omit(d2)
  
  # ensure both factors with ≤2 levels
  d2[[1]] <- factor(d2[[1]])
  d2[[2]] <- factor(d2[[2]])
  if (nlevels(d2[[1]]) < 2 || nlevels(d2[[2]]) < 2) {
    skip("Not enough levels for Fisher's exact test")
  }
  
  tbl <- table(d2[[1]], d2[[2]])
  
  # skip if empty or contains invalid values
  if (any(is.na(tbl)) || any(!is.finite(tbl)) || any(tbl < 0)) {
    skip("Invalid or incomplete table")
  }
  
  res <- stats::fisher.test(tbl)
  
  expect_true(is.list(res))
  expect_true(is.numeric(res$p.value))
  expect_true(res$p.value >= 0 && res$p.value <= 1)
})
