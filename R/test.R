library(tidyverse)
library(DT)

example_df <- data.frame(
  x = c("$1", "-2%", "$3"),
  y = c("$10", "10%", "$20"),
  z = c("$10", "-10%", "$20"),
  w = c("-$10", "-10%", "$20")
)

pattern <- names(example_df) %>% str_c(collapse = "|")

determine_cell_color <- function(vector) {
  str_detect(vector, "-") %>% as.numeric()
}

example_df <- example_df %>% mutate(across(matches(pattern), determine_cell_color, .names = "cell_color_{.col}"))

DT <- datatable(example_df, options = list(
  columnDefs = list(list(targets = (ncol(example_df) / 2 + 1):ncol(example_df), visible = FALSE))
))

walk(str_subset(names(example_df), "^.$"), ~ {
  DT <<- DT %>% formatStyle(
    .x, str_c("cell_color_", .x),
    backgroundColor = styleEqual(c(1, 0), c("red", "white"))
  )
})

DT
