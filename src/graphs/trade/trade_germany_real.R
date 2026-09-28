# Germany real exports/imports from VGR national accounts (GENESIS 81000-0027).
# Shares the same cached table across all 6 functions.
# VGRPKM = chain index (2020=100); VGRPVK = chain-linked volumes in EUR.

.ger_vgr_trade_bar <- function(value_var, filter_code, series_name, y_axis, caption,
                                 decimal_mark) {
  raw <- with_cache("genesis_81000-0027",
                    genesis_fetch("81000-0027"))
  dat <- parse_genesis(raw, value_var = value_var,
                        class_filters = list("2_variable_attribute_code" = filter_code),
                        series_name = series_name, geo = "DEU") |>
    dplyr::filter(date >= as.Date(paste0(DATA_START_MONTH, "-01")))
  plot_bar(dat, y_axis = y_axis, caption = caption,
            decimal_mark = decimal_mark, colors = c(alpha(blue, 0.9))) +
    ggplot2::theme(legend.position = "none")
}

trade_export_germany_real <- function(y_axis, caption, decimal_mark = ",")
  .ger_vgr_trade_bar("EXP001", "VGRPKM", "ExportReal", y_axis, caption, decimal_mark)

trade_import_germany_real <- function(y_axis, caption, decimal_mark = ",")
  .ger_vgr_trade_bar("IMP001", "VGRPKM", "ImportReal", y_axis, caption, decimal_mark)

trade_export_germany_real_goods <- function(y_axis, caption, decimal_mark = ",")
  .ger_vgr_trade_bar("EXP002", "VGRPVK", "ExportGoods", y_axis, caption, decimal_mark)

trade_import_germany_real_goods <- function(y_axis, caption, decimal_mark = ",")
  .ger_vgr_trade_bar("IMP002", "VGRPVK", "ImportGoods", y_axis, caption, decimal_mark)

trade_export_germany_real_services <- function(y_axis, caption, decimal_mark = ",")
  .ger_vgr_trade_bar("EXP003", "VGRPVK", "ExportServices", y_axis, caption, decimal_mark)

trade_import_germany_real_services <- function(y_axis, caption, decimal_mark = ",")
  .ger_vgr_trade_bar("IMP003", "VGRPVK", "ImportServices", y_axis, caption, decimal_mark)

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "trade_export_germany_real", category = "Trade", label = "Germany Real Exports (VGR national accounts)",
    render = function() {
        GER <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(trade_export_germany_real("Reale Ausfuhren (Kettenindex 2020=100)", "Datenquelle: Statistisches Bundesamt (Destatis)"),
            "Export Germany real VGR_ger", GER)
        render_graph(trade_export_germany_real("Real Exports (Chain Index 2020=100)", "Data source: Federal statistical office (Destatis)",
            decimal_mark = "."), "Export Germany real VGR_en", EN)
    }),
list(id = "trade_import_germany_real", category = "Trade", label = "Germany Real Imports (VGR national accounts)",
    render = function() {
        GER <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(trade_import_germany_real("Reale Einfuhren (Kettenindex 2020=100)", "Datenquelle: Statistisches Bundesamt (Destatis)"),
            "Import Germany real VGR_ger", GER)
        render_graph(trade_import_germany_real("Real Imports (Chain Index 2020=100)", "Data source: Federal statistical office (Destatis)",
            decimal_mark = "."), "Import Germany real VGR_en", EN)
    }),
list(id = "trade_export_germany_real_goods", category = "Trade", label = "Germany Real Exports of Goods (VGR)",
    render = function() {
        GER <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(trade_export_germany_real_goods("Ausfuhren Güter (in Mrd. EUR, preisbereinigt)",
            "Datenquelle: Statistisches Bundesamt (Destatis)", decimal_mark = ","), "Export Goods Germany real VGR_ger",
            GER)
        render_graph(trade_export_germany_real_goods("Exports of Goods (in Billion EUR, price-adjusted)",
            "Data source: Federal statistical office (Destatis)", decimal_mark = "."), "Export Goods Germany real VGR_en",
            EN)
    }),
list(id = "trade_export_germany_real_services", category = "Trade", label = "Germany Real Exports of Services (VGR)",
    render = function() {
        GER <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(trade_export_germany_real_services("Ausfuhren Dienstleistungen (in Mrd. EUR, preisbereinigt)",
            "Datenquelle: Statistisches Bundesamt (Destatis)", decimal_mark = ","), "Export Services Germany real VGR_ger",
            GER)
        render_graph(trade_export_germany_real_services("Exports of Services (in Billion EUR, price-adjusted)",
            "Data source: Federal statistical office (Destatis)", decimal_mark = "."), "Export Services Germany real VGR_en",
            EN)
    }),
list(id = "trade_import_germany_real_goods", category = "Trade", label = "Germany Real Imports of Goods (VGR)",
    render = function() {
        GER <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(trade_import_germany_real_goods("Einfuhren Güter (in Mrd. EUR, preisbereinigt)",
            "Datenquelle: Statistisches Bundesamt (Destatis)", decimal_mark = ","), "Import Goods Germany real VGR_ger",
            GER)
        render_graph(trade_import_germany_real_goods("Imports of Goods (in Billion EUR, price-adjusted)",
            "Data source: Federal statistical office (Destatis)", decimal_mark = "."), "Import Goods Germany real VGR_en",
            EN)
    }),
list(id = "trade_import_germany_real_services", category = "Trade", label = "Germany Real Imports of Services (VGR)",
    render = function() {
        GER <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(trade_import_germany_real_services("Einfuhren Dienstleistungen (in Mrd. EUR, preisbereinigt)",
            "Datenquelle: Statistisches Bundesamt (Destatis)", decimal_mark = ","), "Import Services Germany real VGR_ger",
            GER)
        render_graph(trade_import_germany_real_services("Imports of Services (in Billion EUR, price-adjusted)",
            "Data source: Federal statistical office (Destatis)", decimal_mark = "."), "Import Services Germany real VGR_en",
            EN)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/trade/trade_germany_real.R", .graph_specs)
