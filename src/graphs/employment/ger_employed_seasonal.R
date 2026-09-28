# Quarterly employed persons, seasonally adjusted (X13 JDemetra+), Inlandskonzept.
# Table 13321-0002 (replaces retired 81000-0012). Raw values are in 1000 persons.
# If parse fails: unique(raw$value_variable_code); unique(raw[["4_variable_attribute_code"]])
ger_employed_seasonal <- function(y_axis, source, decimal_mark = ",", big_mark = ".") {
  raw <- with_cache("genesis_13321-0002",
                    genesis_fetch("13321-0002"))
  dat <- parse_genesis(raw,
                        value_var     = "ERW002",
                        class_filters = list("4_variable_attribute_code" = "X13JDSB",
                                             "3_variable_attribute_code" = "KONZEPTA",
                                             "2_variable_attribute_code" = "DG"),
                        series_name   = "employed_seasonal",
                        geo           = "DEU",
                        scale         = 1) |>
    dplyr::filter(date >= as.Date(paste0(DATA_START_MONTH, "-01")))
  plot_timeseries(dat, y_axis = y_axis, source = source,
                  decimal_mark = decimal_mark, big_mark = big_mark,
                  x_breaks = "2 years")
}

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "ger_employed_seasonal", category = "Employment", label = "Germany Employed Persons, Quarterly Seasonally Adjusted",
    render = function() {
        DE <- file.path(OUT_DIR, "employment graphs/German labeling")
        EN <- file.path(OUT_DIR, "employment graphs/English labeling")
        render_graph(ger_employed_seasonal("Anzahl Erwerbstätige (in Tsd.), saisonbereinigt", "Datenquelle: Statistisches Bundesamt (Destatis)",
            decimal_mark = ",", big_mark = "."), "GER employed persons quarterly seasonally adjusted_de",
            DE)
        render_graph(ger_employed_seasonal("Number of Employed Persons (in 1000), seasonally adjusted",
            "Data source: Federal statistical office (Destatis)", decimal_mark = ".", big_mark = ","),
            "GER employed persons quarterly seasonally adjusted_en", EN)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/employment/ger_employed_seasonal.R", .graph_specs)
