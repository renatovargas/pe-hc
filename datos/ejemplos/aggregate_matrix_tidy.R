library(tidyverse)

# Example data frame
df <- matrix(c(
  1, 2, 7, 9, 2, 3, 4,
  3, 4, 1, 2, 7, 9, 5,
  5, 6, 3, 4, 1, 2, 7,
  7, 8, 5, 6, 3, 4, 1,
  9, 10,  8, 5, 6, 3, 4,
  11, 12, 9, 10,  8, 5, 6,
  13, 14, 11, 12, 9, 10,  8), nrow=7, byrow = TRUE
)
colnames(df) <- as_factor(c("banana industry", "legumes industry", "livestock", "furniture production", "car parts industry", "telecommunications", "health services"))

rownames(df) <- colnames(df)
df

# Mapping of old names to new categories
activity_map <- data.frame(
  old_name = as_factor(c("banana industry", "legumes industry", "livestock", "furniture production", "car parts industry", "telecommunications", "health services")),
  new_name = as_factor(c("agriculture", "agriculture", "agriculture", "manufacturing", "manufacturing", "services", "services"))
)



