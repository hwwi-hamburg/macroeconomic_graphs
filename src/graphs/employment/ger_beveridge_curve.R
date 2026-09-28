source("src/bootstrap.R")

# Use cached data from the employment graph module
# The with_cache() wrapper ensures we don't re-fetch if data is already cached
stellen_raw <- with_cache("genesis_13211-0001", genesis_fetch("13211-0001"))

arbeitslosigkeit <- parse_genesis(
  stellen_raw,
  value_var     = "ERW006",
  class_filters = list("1_variable_attribute_code" = NA_character_),
  series_name   = "Arbeitslosigkeit",
  geo           = "DEU",
  scale         = 1 / 1e6
)

# Plot the data
plot_timeseries(
  arbeitslosigkeit,
  y_axis = "Arbeitslose (in Mio.)",
  source = "Datenquelle: Statistisches Bundesamt (Destatis)",
  decimal_mark = ",",
  big_mark = ".",
  x_breaks = "2 years"
)

