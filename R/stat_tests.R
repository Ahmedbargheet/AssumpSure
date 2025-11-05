## Independent t-test
run_independent_test <- function(df) {
  tryCatch({
    rstatix::t_test(df, value ~ group, paired = FALSE, detailed = TRUE) %>% 
      dplyr::mutate(method = "Independent t-test")
  }, error = function(e) data.frame(p = NA))
}

## Dependent t-test
run_dependent_test <- function(df) {
  tryCatch({
    rstatix::t_test(df, value ~ group, paired = TRUE, detailed = TRUE) %>% 
      dplyr::mutate(method = "Paired t-test")
  }, error = function(e) data.frame(p = NA))
}

## Mann-Whitney U test
run_mannwhitney_test <- function(df) {
  ngroups <- nlevels(df$group)
  if (ngroups != 2) return(data.frame(p = NA))
  
  tryCatch({
    rstatix::wilcox_test(df, value ~ group, paired = FALSE, detailed = TRUE) %>%
      dplyr::mutate(method = "Mann–Whitney")
  }, error = function(e) data.frame(p = NA))
}


## Wilcoxon signed-rank test
run_wilcoxon_signed_test <- function(df) {
  ngroups <- nlevels(df$group)
  if (ngroups != 2) return(data.frame(p = NA))
  
  group_sizes <- table(df$group)
  if (length(unique(group_sizes)) != 1) return(data.frame(p = NA))
  
  tryCatch({
    rstatix::wilcox_test(df, value ~ group, paired = TRUE, detailed = TRUE) %>% 
      dplyr::mutate(method = "Mann-Whitney")
  }, error = function(e) data.frame(p = NA))
}


## One-way ANOVA
run_anova_test <- function(df) {
  tryCatch({
    rstatix::anova_test(df, value ~ group, white.adjust = T)
  }, error = function(e) data.frame(p = NA))
}

## Kruskal–Wallis Test
run_kruskal_test <- function(df) {
  tryCatch({
    rstatix::kruskal_test(df, value ~ group)
  }, error = function(e) data.frame(p = NA))
}


## Chi-square
stat_square_chisq <- function(df) {
  res <- run_chisq_test(df)
  pval <- res$p[1]
  if (is.na(pval)) return(NULL)
  div(
    style = paste0(
      "background-color: ", if (pval < 0.05) "green" else "#B20D00",
      "; color: white; padding: 10px; border-radius: 5px; margin-top: 10px;"
    ),
    strong(if (pval < 0.05) "Statistically Significant Difference" else "No Statistically Significant Difference")
  )
}


# Fisher exact
stat_square_fisher <- function(df) {
  res <- run_fisher_test(df)
  pval <- res$p[1]
  if (is.na(pval)) return(NULL)
  div(
    style = paste0(
      "background-color: ", if (pval < 0.05) "green" else "#B20D00",
      "; color: white; padding: 10px; border-radius: 5px; margin-top: 10px;"
    ),
    strong(if (pval < 0.05) "Statistically Significant Difference" else "No Statistically Significant Difference")
  )
}


# Correlation
is_singular_matrix <- function(S, tol = .Machine$double.eps^0.5) {
  if (!is.matrix(S)) return(TRUE)
  if (any(!is.finite(S))) return(TRUE)
  r <- qr(S)$rank
  p <- ncol(S)
  (r < p) || any(is.na(S)) || (min(abs(eigen(S, symmetric = TRUE, only.values = TRUE)$values)) < tol)
}


safe_shapiro_pval <- function(x) {
  !is.null(x) && !is.null(x$p.value) && is.numeric(x$p.value) && !is.na(x$p.value)
}

make_scatter_plot <- function(v1, v2, var1_name, var2_name) {
  ggplot2::ggplot(data.frame(x = v1, y = v2), aes(x, y)) +
    geom_point(size = 2, color = "#4B96CB") +
    geom_smooth(method = "lm", se = FALSE, color = "#F57B13", linetype = 5, linewidth = 1) +
    theme_bw() +
    labs(title = "Scatterplot with Regression Line",
         x = var1_name, y = var2_name) + 
    theme(axis.text.x = element_text(size = 12, colour = "black")) + 
    theme(axis.title.x = element_text(size = 14, colour = "black", face = "bold")) + 
    theme(axis.text.y = element_text(size = 12, colour = "black")) + 
    theme(axis.title.y = element_text(size = 14, colour = "black", face = "bold")) + 
    theme(plot.title = element_text(size = 17))
}
