.hh_ger_cpi_monthly <- function(caption,
                                label_ger = "Deutschland",
                                label_hh = "Hamburg",
                                y_axis = "Verbraucherpreisindex (2020=100)",
                                decimal_mark = ",",
                                big_mark = "."
                                ){
  source("src/bootstrap.R")
  
  ger_raw <- with_cache(paste0("genesis_61111-0002_", DATA_START_YEAR),
                        genesis_fetch("61111-0002")) 
  
  hh_raw <- with_cache(paste0("genesis_61111-0011_", DATA_START_YEAR),
                       genesis_fetch("61111-0011"))
  
  ger_dat <- parse_genesis(
    ger_raw,
    value_var = "PREIS1",
    class_filters = list("value_variable_label" = "Verbraucherpreisindex"),
    series_name = "Deutschland",
    geo = "DEU",
    scale = 1
  ) 
  
  hh_dat <- parse_genesis(
    hh_raw,
    value_var = "PREIS1",
    class_filters = list("2_variable_attribute_code" = "02"),
    series_name = "Hamburg",
    geo = "DEU",
    scale = 1,
    dropmissing = FALSE
  )
  
  dat <- dplyr::bind_rows(hh_dat, ger_dat) %>%
    filter(date >= as.Date("2015-01-01"))
  
  plot_timeseries_multi(
    dat = dat,
    y_axis = y_axis,
    caption = "Datenquelle: Statistisches Bundesamt",
    labels = NULL,
    decimal_mark = ",",
    big_mark = ".",
    colors = c(hwwi_dark_blue, hwwi_dark_rubin),
    x_breaks = "1 year",
    y_limits = NULL,
    linewidth = 1.8,
    angle = 45
  )
  
  
}


  .graph_specs <- list(
    list(
      id = "hh_ger_cpi_monthly",
      category = "Prices",
      label = "Hamburg and Germany Consumer Price Index monthly",
      render = function() {
        GER <- file.path(OUT_DIR, "prices graphs/German labeling")
        EN <- file.path(OUT_DIR, "prices graphs/English labeling")
        render_graph(.hh_ger_cpi_monthly(caption = "Datenquelle: Statistisches Bundesamt",
                                         label_ger = "Deutschland", label_hh = "Hamburg",
                                         y_axis = "Verbraucherpreisindex", decimal_mark = ",", big_mark = "."),
                     "HH GER Consumer Price Index monthly", GER)
        render_graph(.hh_ger_cpi_monthly(caption = "Data source: Federal statistical office (Destatis)",
                                         label_ger = "Germany", label_hh = "Hamburg",
                                         y_axis = "Consumer Price Index", decimal_mark = ".", big_mark = ","),
                     "HH GER Consumer Price Index", EN)
      }
    )
  )
  
if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/prices/hh_ger_cpi_monthly.R", .graph_specs)