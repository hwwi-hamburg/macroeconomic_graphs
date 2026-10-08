# src/graphs/gdp/ger_nominal_gdp_state_growth.R
#
# State-level nominal GDP growth, mirroring the existing ger_nominal_gdp_state
# level chart (GENESIS 82111-0010, bar_horizontal) but as YoY % growth bars
# by state instead of a single-year level. Uses yoy_growth() per state.

.ger_gdp_state_growth_helper <- function() {
  raw <- with_cache("genesis_82111-0010", genesis_fetch("82111-0010"))

  rows <- raw[
    !is.na(raw$value_variable_code) & raw$value_variable_code == "BIP006" &
      !is.na(raw$value) & !raw$value %in% c("-", "/", ".", "", "..."),
    , drop = FALSE
  ]
  if (!nrow(rows)) stop("No state GDP rows returned by GENESIS table 82111-0010")

  dat <- tibble::tibble(
    date = as.Date(paste0(rows$time, "-01-01")),
    value = as.numeric(gsub(",", ".", rows$value)),
    series = "state_gdp_nominal",
    unit = "Mill. EUR",
    geo = rows[["1_variable_attribute_label"]]
  )

  # yoy_growth() operates on a single series; state-level data needs the
  # growth calc applied within each state group before flattening back out.
  dat |>
    dplyr::group_by(geo) |>
    dplyr::group_modify(~ yoy_growth(.x, value_col = "value")) |>
    dplyr::ungroup() |>
    dplyr::mutate(unit = "%") |>
    dplyr::filter(!is.na(value), date == max(date)) |>
    dplyr::arrange(value)
}

#' Nominal GDP growth by German state (latest year, YoY %)
#'
#' Companion chart to ger_nominal_gdp_state() / ger_nominal_gdp_state_per_capita():
#' those show levels for the latest year; this shows each state's YoY nominal
#' growth rate for the same year, as horizontal ranking bars.
ger_nominal_gdp_state_growth <- function(y_axis, source, decimal_mark = ",", big_mark = ".") {
  dat <- .ger_gdp_state_growth_helper()
  plot_bar_ranking(dat, source = source, x_axis = y_axis,
                    decimal_mark = decimal_mark, big_mark = big_mark)
}

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "ger_nominal_gdp_state_growth", category = "GDP", label = "Germany nominal GDP growth by state (YoY %, ranking)",
    notes = "At current prices; change on previous year in %, own calculation. Regional accounts of the Länder (VGRdL), GENESIS 82111-0010.",
    render = function() {
        DE <- file.path(OUT_DIR, "GDP graphs/German labeling")
        EN <- file.path(OUT_DIR, "GDP graphs/English labeling")
        render_graph(ger_nominal_gdp_state_growth("Veränderung ggü. Vorjahr in %", "Datenquelle: Statistisches Bundesamt (Destatis)"),
            "GER nominal GDP growth by state_de", DE)
        render_graph(ger_nominal_gdp_state_growth("YoY change in %", "Data source: Federal statistical office (Destatis)",
                    decimal_mark = ".", big_mark = ","), "GER nominal GDP growth by state_en", EN)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/gdp/ger_nominal_gdp_state_growth.R", .graph_specs)
