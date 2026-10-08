# Annual bar charts for state-level and Germany trade values.
# Hamburg annual values are summed from the archived monthly aircraft series so
# the definition remains consistent with the historical charts.

.hh_trade_annual_aircraft <- function() {
  with_cache(paste0("genesis_hh_trade_monthly_", HH_AIRCRAFT_ARCHIVE_START_MONTH),
             fetch_hh_trade_monthly(HH_AIRCRAFT_ARCHIVE_START_MONTH)) |>
    dplyr::mutate(year = as.integer(format(date, "%Y"))) |>
    dplyr::group_by(series, year) |>
    dplyr::summarise(
      value = sum(value),
      months = dplyr::n_distinct(date),
      unit = dplyr::first(unit),
      geo = dplyr::first(geo),
      .groups = "drop"
    ) |>
    dplyr::filter(months == 12, !is.na(value)) |>
    dplyr::transmute(
      date = as.Date(sprintf("%d-01-01", year)),
      value, series, unit, geo
    )
}

trade_export_hamburg <- function(y_axis, source, labels,
                                  decimal_mark = ",", y_limits = c(0, 90)) {
  dat <- .hh_trade_annual_aircraft() |>
    dplyr::filter(series %in% c("Export", "ExportNoAir"))
  plot_bar(dat, y_axis = y_axis, source = source, labels = labels,
            decimal_mark = decimal_mark, y_limits = y_limits)
}

trade_import_hamburg <- function(y_axis, source, labels,
                                  decimal_mark = ",", y_limits = NULL) {
  dat <- .hh_trade_annual_aircraft() |>
    dplyr::filter(series %in% c("Import", "ImportNoAir"))
  plot_bar(dat, y_axis = y_axis, source = source, labels = labels,
            decimal_mark = decimal_mark, y_limits = y_limits)
}

trade_export_lowersaxony <- function(y_axis, source, decimal_mark = ",", y_limits = NULL) {
  dat <- with_cache("genesis_ls_trade_gp19", fetch_ls_trade()) |>
    dplyr::filter(series == "Export")
  plot_bar(dat, y_axis = y_axis, source = source,
            decimal_mark = decimal_mark, y_limits = y_limits)
}

trade_import_lowersaxony <- function(y_axis, source, decimal_mark = ",", y_limits = NULL) {
  dat <- with_cache("genesis_ls_trade_gp19", fetch_ls_trade()) |>
    dplyr::filter(series == "Import")
  plot_bar(dat, y_axis = y_axis, source = source,
            decimal_mark = decimal_mark, y_limits = y_limits)
}

trade_export_germany <- function(y_axis, source, decimal_mark = ",", y_limits = NULL) {
  raw <- with_cache("genesis_51000-0001",
                    genesis_fetch("51000-0001"))
  dat <- parse_genesis(raw, value_var = "WERTA",
                        series_name = "Export", unit = "Mrd. EUR", geo = "DEU",
                        scale = 1 / 1e6) |>
    dplyr::filter(date >= as.Date(paste0(DATA_START_MONTH, "-01")))
  plot_bar(dat, y_axis = y_axis, source = source,
            decimal_mark = decimal_mark, y_limits = y_limits,
            colors = c(alpha(hwwi_blue, 0.9)))
}

trade_import_germany <- function(y_axis, source, decimal_mark = ",", y_limits = NULL) {
  raw <- with_cache("genesis_51000-0001",
                    genesis_fetch("51000-0001"))
  dat <- parse_genesis(raw, value_var = "WERTE",
                        series_name = "Import", unit = "Mrd. EUR", geo = "DEU",
                        scale = 1 / 1e6) |>
    dplyr::filter(date >= as.Date(paste0(DATA_START_MONTH, "-01")))
  plot_bar(dat, y_axis = y_axis, source = source,
            decimal_mark = decimal_mark, y_limits = y_limits,
            colors = c(alpha(hwwi_rubin, 0.9)))
}

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "trade_export_hamburg", category = "Trade", label = "Hamburg Exports (total/excl. aircraft)",
    notes = "Annual nominal values summed from monthly data, total and excluding aircraft (EGW 883); Hamburg's trade is strongly affected by aircraft deliveries. GENESIS 51000-0031, 51000-0035.",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(trade_export_hamburg("Exporte (in Mrd. EUR)", "Datenquelle: Statistisches Bundesamt (Destatis)",
            labels = c("Gesamtexporte", "Exporte ohne Luft- und Raumfahrzeuge"), decimal_mark = ","),
            "Export Hamburg_de", DE)
        render_graph(trade_export_hamburg("Exports (in Billion EUR)", "Data source: Federal statistical office (Destatis)",
            labels = c("Total Exports", "Exports excl. Aircraft"), decimal_mark = "."), "Export Hamburg_en",
            EN)
    }),
list(id = "trade_import_hamburg", category = "Trade", label = "Hamburg Imports (total/excl. aircraft)",
    notes = "Annual nominal values summed from monthly data, total and excluding aircraft (EGW 883); Hamburg's trade is strongly affected by aircraft deliveries. GENESIS 51000-0031, 51000-0035.",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(trade_import_hamburg("Importe (in Mrd. EUR)", "Datenquelle: Statistisches Bundesamt (Destatis)",
            labels = c("Gesamtimporte", "Importe ohne Luft- und Raumfahrzeuge"), decimal_mark = ","),
            "Import Hamburg_de", DE)
        render_graph(trade_import_hamburg("Imports (in Billion EUR)", "Data source: Federal statistical office (Destatis)",
            labels = c("Total Imports", "Imports excl. Aircraft"), decimal_mark = "."), "Import Hamburg_en",
            EN)
    }),
list(id = "trade_export_germany", category = "Trade", label = "Germany Total Exports (annual)",
    notes = "Annual nominal values, foreign trade statistics. GENESIS 51000-0001.",
    render = function() {
    DE <- file.path(OUT_DIR, "trade graphs/German labeling")
    EN <- file.path(OUT_DIR, "trade graphs/English labeling")
    render_graph(trade_export_germany("Ausfuhren (in Mrd. EUR)", "Datenquelle: Statistisches Bundesamt (Destatis)",
        decimal_mark = ","), "Export Germany_de", DE)
    render_graph(trade_export_germany("Exports (in Billion EUR)", "Data source: Federal statistical office (Destatis)",
        decimal_mark = "."), "Export Germany_en", EN)
}),
list(id = "trade_import_germany", category = "Trade", label = "Germany Total Imports (annual)",
    notes = "Annual nominal values, foreign trade statistics. GENESIS 51000-0001.",
    render = function() {
    DE <- file.path(OUT_DIR, "trade graphs/German labeling")
    EN <- file.path(OUT_DIR, "trade graphs/English labeling")
    render_graph(trade_import_germany("Einfuhren (in Mrd. EUR)", "Datenquelle: Statistisches Bundesamt (Destatis)",
        decimal_mark = ","), "Import Germany_de", DE)
    render_graph(trade_import_germany("Imports (in Billion EUR)", "Data source: Federal statistical office (Destatis)",
        decimal_mark = "."), "Import Germany_en", EN)
}),
list(id = "trade_export_lowersaxony", category = "Trade", label = "Lower Saxony Exports (total)",
    notes = "Annual nominal values, foreign trade statistics. GENESIS 51000-0030.",
    render = function() {
    DE <- file.path(OUT_DIR, "trade graphs/German labeling")
    EN <- file.path(OUT_DIR, "trade graphs/English labeling")
    render_graph(trade_export_lowersaxony("Exporte (in Mrd. EUR)", "Datenquelle: Statistisches Bundesamt (Destatis)",
        decimal_mark = ","), "Export Lower Saxony_de", DE)
    render_graph(trade_export_lowersaxony("Exports (in Billion EUR)", "Data source: Federal statistical office (Destatis)",
        decimal_mark = "."), "Export Lower Saxony_en", EN)
}),
list(id = "trade_import_lowersaxony", category = "Trade", label = "Lower Saxony Imports (total)",
    notes = "Annual nominal values, foreign trade statistics. GENESIS 51000-0030.",
    render = function() {
    DE <- file.path(OUT_DIR, "trade graphs/German labeling")
    EN <- file.path(OUT_DIR, "trade graphs/English labeling")
    render_graph(trade_import_lowersaxony("Importe (in Mrd. EUR)", "Datenquelle: Statistisches Bundesamt (Destatis)",
        decimal_mark = ","), "Import Lower Saxony_de", DE)
    render_graph(trade_import_lowersaxony("Imports (in Billion EUR)", "Data source: Federal statistical office (Destatis)",
        decimal_mark = "."), "Import Lower Saxony_en", EN)
})
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/trade/trade_state_bars.R", .graph_specs)
