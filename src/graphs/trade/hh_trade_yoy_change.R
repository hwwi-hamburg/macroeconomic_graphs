# Hamburg monthly trade YoY change (%), total vs. excl. aircraft.
# YoY = current month vs. same month prior year (lag 12). Source: 51000-0031/0035.

.hh_trade_yoy <- function(direction, y_axis, source, labels, decimal_mark, big_mark, y_limits) {
  series_pair <- c(direction, paste0(direction, "NoAir"))
  dat <- with_cache(paste0("genesis_hh_trade_monthly_", HH_AIRCRAFT_ARCHIVE_START_MONTH),
                    fetch_hh_trade_monthly(HH_AIRCRAFT_ARCHIVE_START_MONTH)) |>
    dplyr::filter(series %in% series_pair) |>
    dplyr::arrange(series, date) |>
    dplyr::group_by(series) |>
    dplyr::mutate(value = (value / dplyr::lag(value, 12) - 1) * 100) |>
    dplyr::ungroup() |>
    dplyr::filter(!is.na(value), date >= as.Date(paste0(DATA_START_MONTH, "-01")))
  plot_timeseries_multi(dat, y_axis = y_axis, source = source, labels = labels,
                         decimal_mark = decimal_mark, big_mark = big_mark, x_breaks = "2 years",
                         y_limits = y_limits)
}

hh_export_yoy_change <- function(y_axis, source, labels,
                                  decimal_mark = ",", big_mark = ".", y_limits = NULL)
  .hh_trade_yoy("Export", y_axis, source, labels, decimal_mark, big_mark, y_limits)

hh_import_yoy_change <- function(y_axis, source, labels,
                                  decimal_mark = ",", big_mark = ".", y_limits = NULL)
  .hh_trade_yoy("Import", y_axis, source, labels, decimal_mark, big_mark, y_limits)

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "trade_hh_export_yoy_change", category = "Trade", label = "Hamburg Monthly Exports: Year-on-Year Change",
    notes = "Change on the same month of the previous year in %, own calculation; total and excluding aircraft (EGW 883); Hamburg's trade is strongly affected by aircraft deliveries. GENESIS 51000-0031, 51000-0035.",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(hh_export_yoy_change("Veränderung gg. Vorjahr (in %)", "Datenquelle: Statistisches Bundesamt (Destatis)",
            labels = c("Gesamtexporte", "Exporte ohne Luft- und Raumfahrzeuge")), "Hamburg Monthly Exports YoY Change_de",
            DE)
        render_graph(hh_export_yoy_change("Change vs. prev. year (in %)", "Data source: Federal statistical office (Destatis)",
            labels = c("Total Exports", "Exports excl. Aircraft"), decimal_mark = ".", big_mark = ","), "Hamburg Monthly Exports YoY Change_en",
            EN)
    }),
list(id = "trade_hh_import_yoy_change", category = "Trade", label = "Hamburg Monthly Imports: Year-on-Year Change",
    notes = "Change on the same month of the previous year in %, own calculation; total and excluding aircraft (EGW 883); Hamburg's trade is strongly affected by aircraft deliveries. GENESIS 51000-0031, 51000-0035.",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(hh_import_yoy_change("Veränderung gg. Vorjahr (in %)", "Datenquelle: Statistisches Bundesamt (Destatis)",
            labels = c("Gesamteinfuhren", "Einfuhren ohne Luft- und Raumfahrzeuge")), "Hamburg Monthly Imports YoY Change_de",
            DE)
        render_graph(hh_import_yoy_change("Change vs. prev. year (in %)", "Data source: Federal statistical office (Destatis)",
            labels = c("Total Imports", "Imports excl. Aircraft"), decimal_mark = ".", big_mark = ","), "Hamburg Monthly Imports YoY Change_en",
            EN)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/trade/hh_trade_yoy_change.R", .graph_specs)
