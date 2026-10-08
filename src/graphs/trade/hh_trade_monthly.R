# Hamburg monthly trade bar charts: total vs. excl. aircraft.
# Source: fetch_hh_trade_monthly() (tables 51000-0031/0035).

.hh_trade_bar <- function(direction, y_axis, source, labels,
                            decimal_mark, big_mark, y_limits,
                            start_date = NULL, x_breaks = "2 years") {
  series_pair <- c(direction, paste0(direction, "NoAir"))
  dat <- with_cache(paste0("genesis_hh_trade_monthly_", HH_AIRCRAFT_ARCHIVE_START_MONTH),
                    fetch_hh_trade_monthly(HH_AIRCRAFT_ARCHIVE_START_MONTH)) |>
    dplyr::filter(series %in% series_pair) |>
    dplyr::mutate(series = factor(series, levels = series_pair))
  if (!is.null(start_date))
    dat <- dplyr::filter(dat, date >= start_date)
  plot_bar_date(dat, y_axis = y_axis, source = source, labels = labels,
                decimal_mark = decimal_mark, big_mark = big_mark,
                x_breaks = x_breaks, y_limits = y_limits)
}

hh_export_monthly <- function(y_axis, source, labels,
                               decimal_mark = ",", big_mark = ".", y_limits = NULL)
  .hh_trade_bar("Export", y_axis, source, labels, decimal_mark, big_mark, y_limits)

hh_import_monthly <- function(y_axis, source, labels,
                               decimal_mark = ",", big_mark = ".", y_limits = NULL)
  .hh_trade_bar("Import", y_axis, source, labels, decimal_mark, big_mark, y_limits)

hh_export_pandemic <- function(y_axis, source, labels,
                                decimal_mark = ",", big_mark = ".", y_limits = NULL)
  .hh_trade_bar("Export", y_axis, source, labels, decimal_mark, big_mark, y_limits,
                start_date = as.Date("2019-01-01"), x_breaks = "1 year")

hh_import_pandemic <- function(y_axis, source, labels,
                                decimal_mark = ",", big_mark = ".", y_limits = NULL)
  .hh_trade_bar("Import", y_axis, source, labels, decimal_mark, big_mark, y_limits,
                start_date = as.Date("2019-01-01"), x_breaks = "1 year")

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "trade_hh_export_pandemic", category = "Trade", label = "Hamburg Monthly Exports since COVID-19 Pandemic",
    notes = "Nominal values from January 2019, total and excluding aircraft (EGW 883); Hamburg's trade is strongly affected by aircraft deliveries. GENESIS 51000-0031, 51000-0035.",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(hh_export_pandemic("Exporte (in Mrd. EUR)", "Datenquelle: Statistisches Bundesamt (Destatis)",
            labels = c("Gesamtexporte", "Exporte ohne Luft- und Raumfahrzeuge"), decimal_mark = ",",
            big_mark = "."), "Hamburg Total Exports since Pandemic_de", DE)
        render_graph(hh_export_pandemic("Exports (in Billion EUR)", "Data source: Federal statistical office (Destatis)",
            labels = c("Total Exports", "Exports excl. Aircraft"), decimal_mark = ".", big_mark = ","),
            "Hamburg Total Exports since Pandemic_en", EN)
    }),
list(id = "trade_hh_import_pandemic", category = "Trade", label = "Hamburg Monthly Imports since COVID-19 Pandemic",
    notes = "Nominal values from January 2019, total and excluding aircraft (EGW 883); Hamburg's trade is strongly affected by aircraft deliveries. GENESIS 51000-0031, 51000-0035.",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(hh_import_pandemic("Einfuhren (in Mrd. EUR)", "Datenquelle: Statistisches Bundesamt (Destatis)",
            labels = c("Gesamteinfuhren", "Einfuhren ohne Luft- und Raumfahrzeuge"), decimal_mark = ",",
            big_mark = "."), "Hamburg Total Imports since Pandemic_de", DE)
        render_graph(hh_import_pandemic("Imports (in Billion EUR)", "Data source: Federal statistical office (Destatis)",
            labels = c("Total Imports", "Imports excl. Aircraft"), decimal_mark = ".", big_mark = ","),
            "Hamburg Total Imports since Pandemic_en", EN)
    }),
list(id = "hh_export_monthly", category = "Trade", label = "Hamburg Monthly Exports (total/excl. aircraft)",
    notes = "Nominal values, total and excluding aircraft (EGW 883); Hamburg's trade is strongly affected by aircraft deliveries. GENESIS 51000-0031, 51000-0035.",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(hh_export_monthly("Exporte (in Mrd. EUR)", "Datenquelle: Statistisches Bundesamt (Destatis)",
            labels = c("Gesamtexporte", "Exporte ohne Luft- und Raumfahrzeuge"), decimal_mark = ","),
            "HH Export - value_de", DE)
        render_graph(hh_export_monthly("Exports (in Billion EUR)", "Data source: Federal statistical office (Destatis)",
            labels = c("Total Exports", "Exports excl. Aircraft"), decimal_mark = ".", big_mark = ","), "HH Export - value_en",
            EN)
    }),
list(id = "hh_import_monthly", category = "Trade", label = "Hamburg Monthly Imports (total/excl. aircraft)",
    notes = "Nominal values, total and excluding aircraft (EGW 883); Hamburg's trade is strongly affected by aircraft deliveries. GENESIS 51000-0031, 51000-0035.",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(hh_import_monthly("Importe (in Mrd. EUR)", "Datenquelle: Statistisches Bundesamt (Destatis)",
            labels = c("Gesamteinfuhren", "Einfuhren ohne Luft- und Raumfahrzeuge"), decimal_mark = ","),
            "HH Import - value_de", DE)
        render_graph(hh_import_monthly("Imports (in Billion EUR)", "Data source: Federal statistical office (Destatis)",
            labels = c("Total Imports", "Imports excl. Aircraft"), decimal_mark = ".", big_mark = ","), "HH Import - value_en",
            EN)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/trade/hh_trade_monthly.R", .graph_specs)
