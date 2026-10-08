# Germany monthly trade: absolute year-on-year change (Mrd. EUR), table 51000-0002.

.ger_trade_yoy <- function(value_var, series_name, y_axis, source, decimal_mark,
                             show_trend = FALSE, x_breaks = "2 years") {
  raw <- with_cache("genesis_51000-0002", genesis_fetch("51000-0002"))
  dat <- parse_genesis(raw, value_var = value_var, series_name = series_name,
                        geo = "DEU", scale = 1 / 1e6) |>
    dplyr::arrange(date) |>
    dplyr::mutate(value = value - dplyr::lag(value, 12)) |>
    trim_start_month(DATA_START_MONTH) |>
    dplyr::filter(!is.na(value))

  if (show_trend) {
    ggplot2::ggplot(dat, ggplot2::aes(x = date, y = value)) +
      ggplot2::geom_line(linewidth = 1.6, color = hwwi_blue) +
      ggplot2::stat_smooth(method = "lm", formula = y ~ x, se = FALSE,
                            linetype = "dashed", linewidth = 1, color = hwwi_blue,
                            fullrange = FALSE) +
      ggplot2::scale_x_date(date_breaks = x_breaks, date_labels = "%Y") +
      ggplot2::scale_y_continuous(
        labels = function(x) format(x, decimal.mark = decimal_mark, scientific = FALSE)
      ) +
      ggplot2::labs(x = "", y = wrap_axis_label(y_axis), caption = source) +
      theme_hwwi()
  } else {
    plot_timeseries(dat, y_axis = y_axis, source = source,
                    decimal_mark = decimal_mark, x_breaks = x_breaks)
  }
}

ger_export_yoy_change <- function(y_axis, source, decimal_mark = ",")
  .ger_trade_yoy("WERTA", "export_yoy", y_axis, source, decimal_mark,
                 show_trend  = TRUE,
                 x_breaks    = "1 year")

ger_import_yoy_change <- function(y_axis, source, decimal_mark = ",")
  .ger_trade_yoy("WERTE", "import_yoy", y_axis, source, decimal_mark)

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "trade_ger_export_yoy_change", category = "Trade", label = "Germany Monthly Exports: Year-on-Year Change",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(ger_export_yoy_change("Veränderung gg. Vorjahresmonat (in Mrd. EUR)", "Datenquelle: Statistisches Bundesamt (Destatis)"),
            "Germany Monthly Exports YoY Change_de", DE)
        render_graph(ger_export_yoy_change("Change vs. same month prev. year (in Billion EUR)", "Data source: Federal statistical office (Destatis)",
            decimal_mark = "."), "Germany Monthly Exports YoY Change_en", EN)
    }),
list(id = "trade_ger_import_yoy_change", category = "Trade", label = "Germany Monthly Imports: Year-on-Year Change",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(ger_import_yoy_change("Veränderung gg. Vorjahresmonat (in Mrd. EUR)", "Datenquelle: Statistisches Bundesamt (Destatis)"),
            "Germany Monthly Imports YoY Change_de", DE)
        render_graph(ger_import_yoy_change("Change vs. same month prev. year (in Billion EUR)", "Data source: Federal statistical office (Destatis)",
            decimal_mark = "."), "Germany Monthly Imports YoY Change_en", EN)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/trade/ger_trade_yoy_change.R", .graph_specs)
