# Quarterly ILO unemployment rate (%), seasonally adjusted (X13 JDemetra+).
# Computed as (Erwerbspersonen - Erwerbstätige) / Erwerbspersonen * 100.
# Tables: 13321-0006 (Erwerbspersonen), 13321-0002 (Erwerbstätige), Wohnortkonzept, X13JDSB.
ger_unemployment_seasonal <- function(y_axis, source, decimal_mark = ",", big_mark = ".") {
  raw_ep <- with_cache("genesis_13321-0006",
                        genesis_fetch("13321-0006"))
  raw_et <- with_cache("genesis_13321-0002",
                        genesis_fetch("13321-0002"))
  erwerbspersonen <- parse_genesis(raw_ep,
                                    value_var     = "ERW001",
                                    class_filters = list("4_variable_attribute_code" = "X13JDSB",
                                                         "2_variable_attribute_code" = "DG"),
                                    series_name   = "ep",
                                    geo           = "DEU")
  erwerbstaetige <- parse_genesis(raw_et,
                                   value_var     = "ERW002",
                                   class_filters = list("4_variable_attribute_code" = "X13JDSB",
                                                        "3_variable_attribute_code" = "KONZEPTW",
                                                        "2_variable_attribute_code" = "DG"),
                                   series_name   = "et",
                                   geo           = "DEU")
  dat <- dplyr::inner_join(
    dplyr::select(erwerbspersonen, date, ep = value),
    dplyr::select(erwerbstaetige,  date, et = value),
    by = "date"
  ) |>
    dplyr::transmute(date,
                     value  = (ep - et) / ep * 100,
                     series = "unemployment_rate_seasonal",
                     unit   = "%",
                     geo    = "DEU") |>
    dplyr::filter(date >= as.Date(paste0(DATA_START_MONTH, "-01")))
  plot_timeseries(dat, y_axis = y_axis, source = source,
                  decimal_mark = decimal_mark, big_mark = big_mark,
                  x_breaks = "2 years")
}

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "ger_unemployment_seasonal", category = "Employment", label = "Germany Unemployment Rate, Quarterly Seasonally Adjusted",
    render = function() {
        GER <- file.path(OUT_DIR, "employment graphs/German labeling")
        EN <- file.path(OUT_DIR, "employment graphs/English labeling")
        render_graph(ger_unemployment_seasonal("Erwerbslosenquote in %, saisonbereinigt", "Datenquelle: Statistisches Bundesamt (Destatis)",
            decimal_mark = ","), "GER unemployed persons quarterly seasonally adjusted_ger", GER)
        render_graph(ger_unemployment_seasonal("Unemployment rate in %, seasonally adjusted", "Data source: Federal statistical office (Destatis)",
            decimal_mark = "."), "GER unemployed persons quarterly seasonally adjusted_en", EN)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/employment/ger_unemployment_seasonal.R", .graph_specs)
