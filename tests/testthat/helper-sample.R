get_sample_df <- function() {
  df <- utils::read.csv(system.file("extdata", "infants.csv", package = "AssumpSure"))
  # choose a categorical column for groups
  cat_cols <- names(df)[sapply(df, function(x) {
    is.factor(x) || is.character(x) ||
      (is.numeric(x) && length(unique(x)) <= 10 && all(x == floor(x), na.rm = TRUE))
  })]
  stopifnot(length(cat_cols) > 0)
  g <- cat_cols[1]

  # choose a continuous numeric for value
  num_cols <- names(df)[sapply(df, function(x) is.numeric(x) && length(unique(x)) >= 5)]
  stopifnot(length(num_cols) > 0)
  v <- num_cols[1]

  # prepare a minimal df with expected names
  out <- df |>
    dplyr::transmute(value = .data[[v]], group = .data[[g]]) |>
    dplyr::filter(!is.na(value), !is.na(group)) |>
    dplyr::mutate(group = as.factor(group))

  out
}
