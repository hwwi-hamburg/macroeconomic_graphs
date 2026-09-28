ger_unemployment_rate <- function(y_axis, source, decimal_mark = ",") {
  raw <- with_cache("genesis_13211-0002",
                    genesis_fetch("13211-0002"))
  dat <- parse_genesis(raw,
                        value_var     = "ERW112",
                        class_filters = list("2_variable_attribute_code" = NA),
                        series_name   = "unemployment_rate",
                        geo           = "DEU") |>
    dplyr::arrange(date)
  plot_timeseries(dat, y_axis = y_axis, source = source,
                  decimal_mark = decimal_mark, x_breaks = "2 years")
}

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "ger_unemployment_rate", category = "Employment", label = "Germany Unemployment Rate", render = function() {
    GER <- file.path(OUT_DIR, "employment graphs/German labeling")
    EN <- file.path(OUT_DIR, "employment graphs/English labeling")
    render_graph(ger_unemployment_rate("Arbeitslosenquote (in %)", "Datenquelle: Statistisches Bundesamt (Destatis)"),
        "GER unemployment rate_ger", GER)
    render_graph(ger_unemployment_rate("Unemployment Rate (in %)", "Data source: Federal statistical office (Destatis)",
        decimal_mark = "."), "GER unemployment rate_en", EN)
})
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/employment/ger_unemployment_rate.R", .graph_specs)
