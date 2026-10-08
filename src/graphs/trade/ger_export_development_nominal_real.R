# Nominal vs real export/import development (annual bar, two series).
# Nominal from GENESIS 51000-0001; real from 81000-0027.

.ger_trade_nominal_real_bar <- function(nom_var, real_var, y_axis, source, labels, decimal_mark) {
  raw_nom <- with_cache("genesis_51000-0001",
                         genesis_fetch("51000-0001"))
  nom <- parse_genesis(raw_nom, value_var = nom_var,
                        series_name = "Nominal", unit = "Mrd. EUR", geo = "DEU",
                        scale = 1 / 1e6)

  raw_real <- with_cache("genesis_81000-0027",
                          genesis_fetch("81000-0027"))
  real <- parse_genesis(raw_real, value_var = real_var,
                         series_name = "Real", unit = "Mrd. EUR", geo = "DEU")

  dat <- dplyr::bind_rows(nom, real) |>
    dplyr::filter(date >= as.Date(paste0(DATA_START_MONTH, "-01")))
  plot_bar(dat, y_axis = y_axis, source = source, labels = labels,
            decimal_mark = decimal_mark)
}

ger_export_development_nominal_real <- function(y_axis, source, labels = NULL,
                                                   decimal_mark = ",")
  .ger_trade_nominal_real_bar("WERTA", "EXP001", y_axis, source, labels, decimal_mark)

ger_import_development_nominal_real <- function(y_axis, source, labels = NULL,
                                                   decimal_mark = ",")
  .ger_trade_nominal_real_bar("WERTE", "IMP001", y_axis, source, labels, decimal_mark)

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "trade_ger_export_nominal_real", category = "Trade", label = "Germany Export Development: Nominal vs Real",
    notes = "Nominal: foreign trade statistics (GENESIS 51000-0001); real: price-adjusted, national accounts (GENESIS 81000-0027). The two concepts are not directly comparable.",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(ger_export_development_nominal_real("Ausfuhren (in Mrd. EUR)", "Datenquelle: Statistisches Bundesamt (Destatis)",
            labels = c(Nominal = "Nominale Ausfuhren", Real = "Reale Ausfuhren (VGR)"), decimal_mark = ","),
            "GER Export Development - Nominal vs Real_de", DE)
        render_graph(ger_export_development_nominal_real("Exports (in Billion EUR)", "Data source: Federal statistical office (Destatis)",
            labels = c(Nominal = "Nominal exports", Real = "Real exports (VGR)"), decimal_mark = "."),
            "GER Export Development - Nominal vs Real_en", EN)
    }),
list(id = "trade_ger_import_nominal_real", category = "Trade", label = "Germany Import Development: Nominal vs Real",
    notes = "Nominal: foreign trade statistics (GENESIS 51000-0001); real: price-adjusted, national accounts (GENESIS 81000-0027). The two concepts are not directly comparable.",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(ger_import_development_nominal_real("Einfuhren (in Mrd. EUR)", "Datenquelle: Statistisches Bundesamt (Destatis)",
            labels = c(Nominal = "Nominale Einfuhren", Real = "Reale Einfuhren (VGR)"), decimal_mark = ","),
            "GER Import Development - Nominal vs Real_de", DE)
        render_graph(ger_import_development_nominal_real("Imports (in Billion EUR)", "Data source: Federal statistical office (Destatis)",
            labels = c(Nominal = "Nominal imports", Real = "Real imports (VGR)"), decimal_mark = "."),
            "GER Import Development - Nominal vs Real_en", EN)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/trade/ger_export_development_nominal_real.R", .graph_specs)
