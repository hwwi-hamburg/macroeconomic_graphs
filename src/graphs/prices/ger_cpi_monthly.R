ger_cpi <- function(y_axis, source, y_limits = c(40, 130)) {
  raw <- with_cache("genesis_61111-0002",
                    genesis_fetch("61111-0002"))
  dat <- parse_genesis(raw,
                       value_var   = "PREIS1",
                       unit_filter = "2020=100",
                       series_name = "cpi",
                       geo         = "DEU",
                       dropmissing=FALSE)
  plot_timeseries(dat, y_axis = y_axis, source = source, y_limits = y_limits)
}

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
  list(id = "ger_cpi_monthly", category = "Prices", label = "Germany Consumer Price Index Monthly", render = function() {
    GER <- file.path(OUT_DIR, "prices graphs/German labeling")
    EN <- file.path(OUT_DIR, "prices graphs/English labeling")
    render_graph(ger_cpi("Verbraucherpreisindex (2020=100)", "Quelle: Statistisches Bundesamt (Destatis) (2026)."),
                 "GER Consumer Price Index Monthly_ger", GER)
    render_graph(ger_cpi("Consumer Price Index (2020=100)", "Source: Statistisches Bundesamt (Destatis) (2026)."),
                 "GER Consumer Price Index Monthly_en", EN)
  })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/prices/ger_cpi_monthly.R", .graph_specs)