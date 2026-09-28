trade_world_exports <- function(y_axis, source, decimal_mark = ".", big_mark = ",") {
  dat <- with_cache("wdi_NE.EXP.GNFS.KD_1W",
                    fetch_wdi("NE.EXP.GNFS.KD", country = "1W")) |>
    dplyr::mutate(value = value / 1e9) |>
    dplyr::arrange(date)
  plot_timeseries(dat, y_axis = y_axis, source = source,
                  decimal_mark = decimal_mark, big_mark = big_mark)
}

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "trade_world_exports", category = "Trade", label = "World Exports of Goods and Services (WDI)",
    render = function() {
        GER <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(trade_world_exports("Weltexporte (in Mrd. 2015 US$)", "Datenquelle: Nationale Statistik der Weltbank und OECD",
            decimal_mark = ",", big_mark = "."), "W Exports of Goods and Services real_ger", GER)
        render_graph(trade_world_exports("World Exports (in Billion 2015 US$)", "Data Source: World Bank National Accounts Data, and OECD National Accounts Data Files",
            big_mark = ","), "W Exports of Goods and Services real_en", EN)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/trade/world_exports.R", .graph_specs)
