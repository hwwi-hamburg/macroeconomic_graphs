# src/graphs/prices/ger_real_wage_growth.R
#
# Annual real-wage index published directly by Destatis. Table 62361-0020
# contains both the real- and nominal-wage indices plus their annual changes.
.ger_real_wage_level_helper <- function() {
  raw <- with_cache("genesis_62361-0020", genesis_fetch("62361-0020"))

  required <- c("value_variable_code", "value_variable_label", "value_unit")
  if (!all(required %in% names(raw)))
    stop("Unexpected columns returned by GENESIS table 62361-0020")

  candidates <- raw |>
    dplyr::filter(
      grepl("^Reallohnindex", value_variable_label),
      !grepl("%", value_unit, fixed = TRUE)
    )
  value_codes <- unique(candidates$value_variable_code)
  if (length(value_codes) != 1L)
    stop("Could not identify the real-wage index in GENESIS table 62361-0020")

  parse_genesis(
    raw,
    value_var = value_codes[[1]],
    series_name = "real_wage_index",
    unit = candidates$value_unit[[1]],
    unit_filter = candidates$value_unit[[1]],
    geo = "DEU"
  )
}

#' Real wage index level (rebased, base year = DATA_START_MONTH), Germany
ger_real_wage_index <- function(y_axis, caption, decimal_mark = ",", big_mark = ".") {
  dat <- .ger_real_wage_level_helper() |>
    trim_start_month(DATA_START_MONTH)
  plot_timeseries(dat, y_axis = y_axis, caption = caption,
                   decimal_mark = decimal_mark, big_mark = big_mark)
}

#' Real wage growth (YoY %), Germany
ger_real_wage_growth <- function(y_axis, caption, decimal_mark = ",", big_mark = ".") {
  dat <- .ger_real_wage_level_helper() |>
    yoy_growth(value_col = "value") |>
    trim_start_month(DATA_START_MONTH) |>
    dplyr::filter(!is.na(value))
  plot_bar_growth(dat, y_axis = y_axis, caption = caption,
                   decimal_mark = decimal_mark)
}

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "ger_real_wage_growth", category = "Prices", label = "GER real wage growth (YoY %)", render = function() {
    GER <- file.path(OUT_DIR, "Prices graphs/German labeling")
    EN <- file.path(OUT_DIR, "Prices graphs/English labeling")
    render_graph(ger_real_wage_growth("Veränderung ggü. Vorjahr in %", "Datenquelle: Statistisches Bundesamt (Destatis)"),
        "GER real wage growth_ger", GER)
    render_graph(ger_real_wage_growth("YoY change in %", "Data source: Federal statistical office (Destatis)",
        decimal_mark = ".", big_mark = ","), "GER real wage growth_en", EN)
}),
list(id = "ger_real_wage_index", category = "Prices", label = "GER real wage index (level)", render = function() {
    GER <- file.path(OUT_DIR, "Prices graphs/German labeling")
    EN <- file.path(OUT_DIR, "Prices graphs/English labeling")
    render_graph(ger_real_wage_index("Index", "Datenquelle: Statistisches Bundesamt (Destatis)"), "GER real wage index_ger",
        GER)
    render_graph(ger_real_wage_index("Index", "Data source: Federal statistical office (Destatis)", decimal_mark = ".",
        big_mark = ","), "GER real wage index_en", EN)
})
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/employment/ger_real_wage_growth.R", .graph_specs)
