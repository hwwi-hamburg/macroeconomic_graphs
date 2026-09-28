ger_inflation_rate <- function(y_axis, source, row_indicator = 2,  y_limits = c(-2.5, 10)) {
  raw <- with_cache("genesis_61111-0002",
                    genesis_fetch("61111-0002"))
  dat <- parse_genesis(raw,
                       value_var   = "PREIS1",
                       unit_filter = "%",
                       series_name = "cpi",
                       geo         = "DEU",
                       dropmissing = FALSE,
                       zero_values = "-")
  dat <- select_monthly_value(dat, row_indicator = row_indicator)
  plot_timeseries(dat, y_axis = y_axis, source = source, y_limits = y_limits)
}

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "ger_inflation_rate", category = "Prices", label = "Germany Inflation Rate (monthly YoY)",
    render = function() {
        DE <- file.path(OUT_DIR, "prices graphs/German labeling")
        EN <- file.path(OUT_DIR, "prices graphs/English labeling")
        render_graph(ger_inflation_rate("Inflationsrate (Veränderung gg. Vj., in %)", "Quelle: Statistisches Bundesamt (Destatis) (2026)."),
            "GER inflation rate monthly_de", DE)
        render_graph(ger_inflation_rate("Inflation Rate (change vs. prev. year, in %)", "Source: Statistisches Bundesamt (Destatis) (2026).",
            decimal_mark = "."), "GER inflation rate monthly_en", EN)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/prices/ger_inflation_rate.R", .graph_specs)
