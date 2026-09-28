# Monthly registered unemployed (Arbeitslose, Germany total, in Mio.), seasonally adjusted.
# GENESIS 13211-0002 (monthly). ERW006 = Arbeitslose; X-13ARIMA-SEATS SA via {seasonal}.
# Shares the 13211-0002 cache with ger_unemployment_rate.
ger_registered_unemployed_monthly <- function(y_axis, caption,
                                               decimal_mark = ",", big_mark = ".") {
  raw <- with_cache("genesis_13211-0002",
                    genesis_fetch("13211-0002"))
  dat <- parse_genesis(raw,
                        value_var     = "ERW006",
                        class_filters = list("2_variable_attribute_code" = NA),
                        series_name   = "registered_unemployed",
                        geo           = "DEU",
                        scale         = 1 / 1e6) |>
    dplyr::arrange(date) |>
    dplyr::filter(date >= as.Date(paste0(DATA_START_MONTH, "-01")))
  ts_obj <- stats::ts(dat$value,
                       start     = c(as.integer(format(dat$date[1], "%Y")),
                                     as.integer(format(dat$date[1], "%m"))),
                       frequency = 12)
  dat$value <- as.numeric(seasonal::final(seasonal::seas(ts_obj)))
  plot_timeseries(dat, y_axis = y_axis, caption = caption,
                  decimal_mark = decimal_mark, big_mark = big_mark,
                  x_breaks = "2 years")
}

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "ger_registered_unemployed_monthly", category = "Employment", label = "Germany Registered Unemployed (monthly, total)",
    render = function() {
        GER <- file.path(OUT_DIR, "employment graphs/German labeling")
        EN <- file.path(OUT_DIR, "employment graphs/English labeling")
        render_graph(ger_registered_unemployed_monthly("Arbeitslose (in Mio.)", "Datenquelle: Statistisches Bundesamt (Destatis)",
            decimal_mark = ",", big_mark = "."), "GER registered unemployed monthly_ger", GER)
        render_graph(ger_registered_unemployed_monthly("Registered Unemployed (in million)", "Data source: Federal statistical office (Destatis)",
            decimal_mark = ".", big_mark = ","), "GER registered unemployed monthly_en", EN)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/employment/ger_registered_unemployed_monthly.R", .graph_specs)
