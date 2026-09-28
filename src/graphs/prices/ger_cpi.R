ger_cpi <- function(y_axis, caption, y_limits = c(40, 130)) {
  raw <- with_cache("genesis_61111-0001",
                    genesis_fetch("61111-0001"))
  dat <- parse_genesis(raw,
                        value_var   = "PREIS1",
                        unit_filter = "2020=100",
                        series_name = "cpi",
                        geo         = "DEU")
  plot_timeseries(dat, y_axis = y_axis, caption = caption, y_limits = y_limits)
}

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "ger_cpi", category = "Prices", label = "Germany Consumer Price Index", render = function() {
    GER <- file.path(OUT_DIR, "prices graphs/German labeling")
    EN <- file.path(OUT_DIR, "prices graphs/English labeling")
    render_graph(ger_cpi("Verbraucherpreisindex (2020=100)", "Datenquelle: Statistisches Bundesamt (Destatis)"),
        "GER Consumer Price Index_ger", GER)
    render_graph(ger_cpi("Consumer Price Index (2020=100)", "Data source: Federal statistical office (Destatis)"),
        "GER Consumer Price Index_en", EN)
})
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/prices/ger_cpi.R", .graph_specs)
