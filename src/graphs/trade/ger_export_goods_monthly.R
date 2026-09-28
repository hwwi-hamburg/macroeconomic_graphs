ger_export_goods_monthly <- function(y_axis, source, decimal_mark = ",", big_mark = ".") {
  raw <- with_cache("genesis_51000-0002",
                    genesis_fetch("51000-0002"))
  dat <- parse_genesis(raw, value_var = "WERTA",
                        series_name = "ger_export_goods",
                        geo         = "DEU",
                        scale       = 1 / 1e6) |>
    dplyr::filter(date >= as.Date(paste0(DATA_START_MONTH, "-01"))) |>
    dplyr::arrange(date)
  plot_timeseries(dat, y_axis = y_axis, source = source,
                  decimal_mark = decimal_mark, big_mark = big_mark,
                  x_breaks = "2 years")
}

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "ger_export_goods_monthly", category = "Trade", label = "Germany Monthly Goods Exports - Level (Mrd EUR)",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(ger_export_goods_monthly("Güterausfuhren (in Mrd. EUR)", "Datenquelle: Statistisches Bundesamt (Destatis)",
            decimal_mark = ",", big_mark = "."), "GER Export goods monthly level_de", DE)
        render_graph(ger_export_goods_monthly("Goods Exports (in Billion EUR)", "Data source: Federal statistical office (Destatis)",
            decimal_mark = ".", big_mark = ","), "GER Export goods monthly level_en", EN)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/trade/ger_export_goods_monthly.R", .graph_specs)
