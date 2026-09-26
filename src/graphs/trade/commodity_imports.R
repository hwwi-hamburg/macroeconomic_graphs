# Monthly imports by the long-running EGW commodity groups used in the old project.
# Germany from table 51000-0006; Hamburg from 51000-0035.

.commodity_imports_base <- function(table, geo, class_filters_extra = list(),
                                     extra_fetch_args = list(), cache_prefix,
                                     commodity_codes, y_axis, caption, labels = NULL,
                                     decimal_mark = ",", big_mark = ".") {
  codes_key <- paste(commodity_codes, collapse = ",")
  raw <- with_cache(
    paste0(cache_prefix, codes_key, "_", DATA_START_YEAR),
    do.call(genesis_fetch, c(list(table, DATA_START_YEAR,
                                   classifyingvariable1 = "EGW3",
                                   classifyingkey1      = codes_key),
                              extra_fetch_args))
  )
  dat_list <- lapply(commodity_codes, function(code) {
    tryCatch(
      parse_genesis(raw, value_var = "WERTE",
                    class_filters = c(class_filters_extra,
                                      list("3_variable_attribute_code" = code)),
                    series_name   = code, geo = geo, scale = 1 / 1e6),
      error = function(e) NULL
    )
  })
  dat <- dplyr::bind_rows(dat_list[!sapply(dat_list, is.null)]) |>
    dplyr::filter(date >= as.Date(paste0(DATA_START_YEAR, "-01-01")))
  if (!is.null(labels)) {
    labels <- vapply(labels, function(label) paste(strwrap(label, width = 32), collapse = "\n"),
                     character(1), USE.NAMES = TRUE)
  }
  plot_timeseries_multi(dat, y_axis = y_axis, caption = caption, labels = labels,
                         colors = c(blue, dark_blue, dark_grey,
                                    dark_rubin, rubin, light_blue),
                         decimal_mark = decimal_mark, big_mark = big_mark,
                         x_breaks = "2 years") +
    ggplot2::guides(color = ggplot2::guide_legend(nrow = 2, byrow = TRUE))
}

commodity_imports_germany <- function(y_axis, caption, labels = NULL,
                                       commodity_codes = c("EGW669", "EGW518", "EGW522", "EGW646"),
                                       decimal_mark = ",", big_mark = ".")
  .commodity_imports_base("51000-0006", "DEU",
                           cache_prefix     = "genesis_51000-0006_",
                           commodity_codes  = commodity_codes,
                           y_axis = y_axis, caption = caption, labels = labels,
                           decimal_mark = decimal_mark, big_mark = big_mark)

commodity_imports_hamburg <- function(y_axis, caption, labels = NULL,
                                       commodity_codes = c("EGW669", "EGW518", "EGW522", "EGW646"),
                                       decimal_mark = ",", big_mark = ".")
  .commodity_imports_base("51000-0035", "HH",
                           class_filters_extra = list("2_variable_attribute_code" = "02"),
                           extra_fetch_args    = list(regionalvariable = "DLANDX",
                                                      regionalkey      = "02"),
                           cache_prefix        = "genesis_51000-0035_HH_",
                           commodity_codes     = commodity_codes,
                           y_axis = y_axis, caption = caption, labels = labels,
                           decimal_mark = decimal_mark, big_mark = big_mark)

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "trade_commodity_imports_hamburg", category = "Trade", label = "Hamburg Monthly Imports by Commodity Group",
    render = function() {
        GER <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(commodity_imports_hamburg("Einfuhren (in Mrd. EUR)", "Datenquelle: Statistisches Bundesamt (Destatis)",
            labels = c(EGW669 = "Mineralölerzeugnisse", EGW518 = "Erdöl u. Erdgas",
                EGW522 = "Kupfererze", EGW646 = "Kupfer u. Kupferlegierungen"), decimal_mark = ",", big_mark = "."), "Hamburg Commodity Imports monthly_ger",
            GER)
        render_graph(commodity_imports_hamburg("Imports (in Billion EUR)", "Data source: Federal statistical office (Destatis)",
            labels = c(EGW669 = "Mineral oil products", EGW518 = "Petroleum oil and petroleum gases",
                EGW522 = "Copper ores", EGW646 = "Copper and copper alloys, incl. waste, scrap"), decimal_mark = ".",
            big_mark = ","), "Hamburg Commodity Imports monthly_en", EN)
    }),
list(id = "trade_commodity_imports_germany", category = "Trade", label = "Germany Monthly Imports by Commodity Group",
    render = function() {
        GER <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(commodity_imports_germany("Einfuhren (in Mrd. EUR)", "Datenquelle: Statistisches Bundesamt (Destatis)",
            labels = c(EGW669 = "Mineralölerzeugnisse", EGW518 = "Erdöl u. Erdgas",
                EGW522 = "Kupfererze", EGW646 = "Kupfer u. Kupferlegierungen"), decimal_mark = ",", big_mark = "."), "Germany Commodity Imports monthly_ger",
            GER)
        render_graph(commodity_imports_germany("Imports (in Billion EUR)", "Data source: Federal statistical office (Destatis)",
            labels = c(EGW669 = "Mineral oil products", EGW518 = "Petroleum oil and petroleum gases",
                EGW522 = "Copper ores", EGW646 = "Copper and copper alloys, incl. waste, scrap"), decimal_mark = ".",
            big_mark = ","), "Germany Commodity Imports monthly_en", EN)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/trade/commodity_imports.R", .graph_specs)
