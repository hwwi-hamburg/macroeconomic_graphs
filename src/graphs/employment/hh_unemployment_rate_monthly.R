.hh_unemployment_monthly <- function(source,
                                         label_ger = "Deutschland",
                                         label_hh = "Hamburg",
                                         y_axis = "Arbeitslosenquote",
                                         decimal_mark = ",",
                                         big_mark = "."
                                          ){
  source("src/bootstrap.R")
  
  hh_raw <- with_cache("genesis_13211-0008",
                        genesis_fetch("13211-0008"))
  
  hh_dat <- parse_genesis(
    hh_raw,
    value_var = "ERW116",
    class_filters = list("2_variable_attribute_code" = "02"),
    series_name = "Hamburg",
    geo = "DEU",
    scale = 1,
    dropmissing = FALSE
  )
  
  plot_timeseries(
    hh_dat,
    y_axis,
    source = "Datenquelle: Statistisches Bundesamt",
    decimal_mark = ".",
    big_mark = ",",
    color = hwwi_blue,
    x_breaks = "1 year",
    y_limits = NULL,
    y_breaks = ggplot2::waiver(),
    linewidth = 1.8,
    angle = 45
  )
}

  .graph_specs <- list(
    list(
      id = "hh_unemployment_monthly",
      category = "Employment",
      label = "Hamburg unemployment rate monthly",
      render = function() {
        DE <- file.path(OUT_DIR, "employment graphs/German labeling")
        EN <- file.path(OUT_DIR, "employment graphs/English labeling")
        render_graph(.hh_unemployment_monthly(source = "Datenquelle: Statistisches Bundesamt",
                                              label_ger = "Deutschland", y_axis = "Arbeitslosenquote",
                                              decimal_mark = ",", big_mark = "."),
                     "HH unemployment rate monthly", DE)
        render_graph(.hh_unemployment_monthly(source = "Data source: Federal statistical office (Destatis)",
                                              label_ger = "Germany", y_axis = "Unemployment rate", decimal_mark = ".",
                                              big_mark = ","),
                     "HH unemployment rate monthly", EN)
      }
    )
  )
  
if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
  auto_run_graph_file("src/graphs/employment/hh_unemployment_rate_monthly.R", .graph_specs)