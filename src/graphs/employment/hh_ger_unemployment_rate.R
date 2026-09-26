.hh_ger_unemployment_annual <- function(caption,
                                        label_ger = "Deutschland",
                                        label_hh = "Hamburg",
                                        y_axis = "Arbeitslosenquote",
                                        decimal_mark = ",",
                                        big_mark = ".") {
  ger_raw <- with_cache(paste0("genesis_13211-0001_", DATA_START_YEAR),
                        genesis_fetch("13211-0001"))

  hh_raw <- with_cache(paste0("genesis_13211-0007_", DATA_START_YEAR),
                       genesis_fetch("13211-0007"))

  ger_dat <- parse_genesis(
    ger_raw,
    value_var = "ERW116",
    class_filters = list("1_variable_attribute_label" = "Insgesamt"),
    series_name = label_ger,
    geo = "DEU",
    scale = 1
  )

  hh_dat <- parse_genesis(
    hh_raw,
    value_var = "ERW116",
    class_filters = list("1_variable_attribute_code" = "02"),
    series_name = label_hh,
    scale = 1
  )

  dat <- dplyr::bind_rows(hh_dat, ger_dat)

  plot_timeseries_multi(
    dat = dat,
    y_axis = y_axis,
    caption = caption,
    labels = c(label_hh, label_ger),
    decimal_mark = decimal_mark,
    big_mark = big_mark,
    colors = c(hwwi_dark_blue, hwwi_dark_rubin),
    x_breaks = "1 year",
    y_limits = NULL,
    linewidth = 1.8,
    angle = 45
  )
}

.graph_specs <- list(
  list(
    id = "hh_ger_unemployment_annual",
    category = "Employment",
    label = "Hamburg and Germany unemployment rate",
    render = function() {
      GER <- file.path(OUT_DIR, "employment graphs/German labeling")
      EN <- file.path(OUT_DIR, "employment graphs/English labeling")

      render_graph(
        .hh_ger_unemployment_annual(
          caption = "Datenquelle: Statistisches Bundesamt",
          label_ger = "Deutschland",
          label_hh = "Hamburg",
          y_axis = "Arbeitslosenquote",
          decimal_mark = ",",
          big_mark = "."
        ),
        "HH GER unemployment rate",
        GER
      )
      render_graph(
        .hh_ger_unemployment_annual(
          caption = "Data source: Federal statistical office (Destatis)",
          label_ger = "Germany",
          label_hh = "Hamburg",
          y_axis = "Unemployment rate",
          decimal_mark = ".",
          big_mark = ","
        ),
        "HH GER unemployment rate",
        EN
      )
    }
  )
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/employment/hh_ger_unemployment_rate.R", .graph_specs)
