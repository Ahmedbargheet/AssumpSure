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