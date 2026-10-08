.hh_ger_bip_annual_nominal <- function(source,
                                      label_ger = "Deutschland",
                                      label_hh = "Hamburg",
                                      y_axis_left = "Bruttoinlandsprodukt (in Mio. €)",
                                      y_axis_right = "Bruttoinlandsprodukt (in Mio. €)",
                                      decimal_mark = ",",
                                      big_mark = ".") {

source("src/bootstrap.R")
  
  ger_raw <- with_cache("genesis_81000-0001",
                    genesis_fetch("81000-0001"))
  
  hh_raw <- with_cache("genesis_82111-0010",
                       genesis_fetch("82111-0010"))
  
  ger_dat <- parse_genesis(
    ger_raw,
    value_var = "VGR014",
    class_filters = list("2_variable_attribute_code" = "VGRJPM"),
    series_name = "Deutschland",
    geo = "DEU",
    scale = 1*1000
  )
  
  hh_dat <- parse_genesis(
    hh_raw,
    value_var = "BIP006",
    class_filters = list(`1_variable_attribute_code` = "02"),
    series_name = "Hamburg",
    geo = "DEU",
    scale = 1
  )
  dat <- dplyr::bind_rows(hh_dat, ger_dat)
  
  plot_dual_axis(
    dat = dat,
    source = "Quelle: Statistisches Bundesamt",
    y_axis_left = y_axis_left,
    y_axis_right = y_axis_right,
    series_left = "Hamburg",
    series_right = "Deutschland",
    decimal_mark = ",", big_mark = ".",
    colors = c(dark_rubin, dark_blue), x_breaks = "1 year",
    y_max_right = NULL, y_min_at_zero = TRUE, angle = 45
  )
  
  
}




.graph_specs <- list(
  list(
    id = "hh_ger_nominal_bip_annual",
    category = "GDP",
    label = "Hamburg and Germany nominal GDP",
    notes = "At current prices (not price-adjusted). GENESIS 81000-0001 (Germany), 82111-0010 (Hamburg).",
    render = function() {
      DE <- file.path(OUT_DIR, "GDP graphs/German labeling")
      EN <- file.path(OUT_DIR, "GDP graphs/English labeling")
      render_graph(.hh_ger_bip_annual_nominal(source = "Datenquelle: Statistisches Bundesamt (Destatis)",
                                           label_ger = "Bruttoinlandsprodukt Deutschland", label_hh = "Bruttoinlandsprodukt Hamburg", y_axis_left = "Bruttoinlandsprodukt (in Mio. €)",
                                           y_axis_right = "Bruttoinlandsprodukt (in Mio. €)", decimal_mark = ",", big_mark = "."), "GER HH gdp",
                   DE)
      render_graph(.hh_ger_bip_annual_nominal(source = "Data source: Federal statistical office (Destatis)",
                                           label_ger = "GDP Germany", label_hh = "GDP Hamburg", y_axis_left = "GDP (in million)",
                                           y_axis_right = "GDP Germany (in million)", decimal_mark = ".", big_mark = ","), "GER HH gdp",
                   EN)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/gdp/hh_ger_gdp_nominal.R", .graph_specs)









