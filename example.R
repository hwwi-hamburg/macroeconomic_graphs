.ger_bip_annual <- function(value_var, filter_code, series_name, y_axis, source,
                            decimal_mark, big_mark = ",") {
  raw <- with_cache(paste0("genesis_81000-0001_", DATA_START_MONTH),
                    genesis_fetch("81000-0001"))

  dat <- parse_genesis(
    raw,
    value_var     = value_var,
    class_filters = list("2_variable_attribute_code" = filter_code),
    series_name   = series_name,
    geo           = "DEU"
  ) |>
    dplyr::filter(date >= as.Date(paste0(DATA_START_MONTH, "-01")))

  plot_timeseries(dat, y_axis = y_axis, source = source,
                  decimal_mark = decimal_mark, big_mark = big_mark)
}

ger_bip_annual_growth <- function(y_axis, source, decimal_mark = ",")
  .ger_bip_annual("BIP005", "VGRPKM", "gdp_growth_annual", y_axis, source, decimal_mark)

.graph_specs <- list(
  list(
    id = "ger_bip_annual_growth",
    category = "GDP",
    label = "Germany Annual GDP Growth (Destatis)",
    render = function() {
      render_graph(
        ger_bip_annual_growth(
          "Kettenindex (2020=100)\nVeränderung in %",
          "Datenquelle: Statistisches Bundesamt (Destatis)"
        ),
        "GER BIP annual growth - chain index_ger",
        file.path(OUT_DIR, "GDP graphs/German labeling")
      )
    }
  )
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/gdp/ger_bip_annual.R", .graph_specs)