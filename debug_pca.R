library(tidyverse)
library(glue)

pokemon_df <- read_csv("data result/pokemon_data_enriched.csv")
numeric_features <- c("hp", "attack", "defense", "sp_atk", "sp_def", "speed", 
                      "height_m", "weight_kgs", "bmi")

pca_df <- pokemon_df |>
  select(dex, name, category, generation, type_1, all_of(numeric_features)) |>
  drop_na()

pca_df_full <- pca_df

# IQR Outliers
detect_outliers <- function(x, multiplier = 3) {
  q1 <- quantile(x, 0.25, na.rm = TRUE)
  q3 <- quantile(x, 0.75, na.rm = TRUE)
  iqr <- q3 - q1
  lower <- q1 - multiplier * iqr
  upper <- q3 + multiplier * iqr
  return(x < lower | x > upper)
}

numeric_data_temp <- pca_df |> select(all_of(numeric_features))
print(head(numeric_data_temp))
outlier_flags <- numeric_data_temp |>
  mutate(across(everything(), ~detect_outliers(.), .names = "{.col}_outlier"))
print(head(outlier_flags))
pca_df$outlier_count <- rowSums(outlier_flags)
extreme_outliers <- pca_df |> filter(outlier_count >= 3)

cat(glue("Extreme outliers (IQR): {nrow(extreme_outliers)}\n"))

# Z-score Outliers
zscore_threshold <- 6
zscore_flags <- pca_df_full |>
  select(all_of(numeric_features)) |>
  mutate(across(everything(), ~abs(scale(.)), .names = "{.col}_z"))

zscore_outliers <- which(rowSums(zscore_flags > zscore_threshold) > 0)
cat(glue("Z-score outliers indices count: {length(zscore_outliers)}\n"))

outlier_dexes <- unique(c(extreme_outliers$dex, pca_df_full$dex[zscore_outliers]))
cat(glue("Total unique outlier dexes: {length(outlier_dexes)}\n"))

pca_df_clean <- pca_df_full |>
  filter(!dex %in% outlier_dexes)

cat(glue("Cleaned dataframe rows: {nrow(pca_df_clean)}\n"))

numeric_data <- pca_df_clean |> select(all_of(numeric_features))
cat(glue("Numeric data dims: {nrow(numeric_data)} x {ncol(numeric_data)}\n"))

scaled_data <- scale(numeric_data)
cat("Scaled data summary:\n")
print(summary(scaled_data))
