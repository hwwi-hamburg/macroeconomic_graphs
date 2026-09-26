.hh_ger_export_index_monthly <- function(caption,
                                          labels,
                                          y_axis = "Exporte in Tsd. EUR",
                                          decimal_mark = ",",
                                          big_mark = ".") {
  source("src/bootstrap.R")

  ger_raw <- with_cache(paste0("genesis_51000-0002_", DATA_START_YEAR),
                        genesis_fetch("51000-0002"))
  hh_raw <- with_cache(paste0("genesis_51000-0031_", DATA_START_YEAR),
                        genesis_fetch("51000-0031"))


  ger_dat <- parse_genesis(
    ger_raw,
    value_var = "WERTA",
    class_filters = list(value_unit = "Tsd. EUR"),
    series_name = "Deutschland",
    geo = "DEU",
    scale = 1
  )

  ger_dat <- ger_dat %>%
    seasonal_adjust() %>%
    mutate(index = value / mean(value[year(date) == 2020])*100) %>%
    select(date, index, series) %>%
    rename(
      date = 1,
      value = 2,
      series = 3
    )


  hh_dat <- parse_genesis(
    hh_raw,
    value_var = "WERTA",
    class_filters = list(`2_variable_attribute_code` = "02"),
    series_name = "Hamburg",
    geo = "HH",
    scale = 1
  )

  hh_dat <- hh_dat %>%
    seasonal_adjust() %>%
    mutate(index = value / mean(value[year(date) == 2020])*100) %>%
    select(date, index, series) %>%
    rename(
      date = 1,
      value = 2,
      series = 3
    )
  
  dat <- dplyr::bind_rows(ger_dat, hh_dat) %>%
    mutate(value = as.numeric(value)) %>%
    filter(date >= max(tapply(date, series, min)),
         date <= min(tapply(date, series, max)))
  
  plot_timeseries_multi(
    dat,
    y_axis = y_axis,
    caption = caption,
    labels = labels,
    decimal_mark = ".",
    big_mark = ",",
    colors = hwwi_palette,
    x_breaks = "1 year",
    y_limits = NULL,
    linewidth = 1.8,
    angle = 45
  )
}

  .graph_specs <- list(
    list(
      id = "hh_ger_export_index_monthly",
      category = "Trade",
      label = "Hamburg and Germany Exports monthly seasonal adjusted",
      render = function() {
        GER <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(.hh_ger_export_index_monthly(caption = "Datenquelle: Statistisches Bundesamt",
                                            labels = c("Deutschland", "Hamburg"),
                                            y_axis = "Exporte (2020=100)",
                                            decimal_mark = ",", big_mark = "."),
                                      "HH GER Exports monthly index seasonal adjusted", GER)  
        render_graph(.hh_ger_export_index_monthly(caption = "Data source: Federal statistical office (Destatis)",
                                            labels = c("Germany", "Hamburg"),
                                            y_axis = "Exports (2020=100)",
                                            decimal_mark = ".", big_mark = "."),
                                      "HH GER Exports monthly index seasonal adjusted", EN)   
      }
    )
  )

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/trade/hh_ger_export_monthly.R", .graph_specs)