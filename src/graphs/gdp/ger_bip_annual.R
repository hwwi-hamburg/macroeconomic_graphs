# Annual German GDP from GENESIS 81000-0001. Shares cache across all three functions.
# VGRPKM = chain index (2020=100); VGRPVK = chain-linked volumes (Mrd. EUR);
# VGRJPM = nominal current prices (Mrd. EUR).

.ger_bip_annual <- function(value_var, filter_code, series_name, y_axis, source,
                              decimal_mark, big_mark = ",") {
  raw <- with_cache("genesis_81000-0001",
                    genesis_fetch("81000-0001"))
  dat <- parse_genesis(raw,
                        value_var     = value_var,
                        class_filters = list("2_variable_attribute_code" = filter_code),
                        series_name   = series_name,
                        geo           = "DEU")
  plot_timeseries(dat, y_axis = y_axis, source = source,
                  decimal_mark = decimal_mark, big_mark = big_mark)
}

ger_bip_annual_development <- function(y_axis, source, decimal_mark = ",")
  .ger_bip_annual("VGR014", "VGRPKM", "gdp_level_annual", y_axis, source, decimal_mark)

ger_bip_annual_growth <- function(y_axis, source, decimal_mark = ",")
  .ger_bip_annual("BIP005", "VGRPKM", "gdp_growth_annual", y_axis, source, decimal_mark)

ger_bip_annual_volume <- function(y_axis, source, decimal_mark = ",", big_mark = ".")
  .ger_bip_annual("VGR014", "VGRPVK", "gdp_annual_volume", y_axis, source, decimal_mark, big_mark)

ger_nominal_gdp <- function(y_axis, source, decimal_mark = ",", big_mark = ".")
  .ger_bip_annual("VGR014", "VGRJPM", "gdp_nominal_annual", y_axis, source, decimal_mark, big_mark)

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "ger_bip_annual_growth", category = "GDP", label = "Germany Annual GDP Growth (Destatis)",
    render = function() {
        DE <- file.path(OUT_DIR, "GDP graphs/German labeling")
        EN <- file.path(OUT_DIR, "GDP graphs/English labeling")
        render_graph(ger_bip_annual_growth("Kettenindex (2020=100) \n Veränderung in %", "Datenquelle: Statistisches Bundesamt (Destatis)"),
            "GER BIP annual growth - chain index_de", DE)
        render_graph(ger_bip_annual_growth("Chain index (2020=100) \n Change in %", "Data source: Federal statistical office (Destatis)",
            decimal_mark = "."), "GER BIP annual growth - chain index_en", EN)
    }),
list(id = "ger_bip_annual_development", category = "GDP", label = "Germany Annual GDP Level - Chain Index (Destatis)",
    render = function() {
        DE <- file.path(OUT_DIR, "GDP graphs/German labeling")
        EN <- file.path(OUT_DIR, "GDP graphs/English labeling")
        render_graph(ger_bip_annual_development("Kettenindex (2020=100)", "Datenquelle: Statistisches Bundesamt (Destatis)"),
            "GER BIP annual level - chain index_de", DE)
        render_graph(ger_bip_annual_development("Chain Index (2020=100)", "Data source: Federal statistical office (Destatis)",
            decimal_mark = "."), "GER BIP annual level - chain index_en", EN)
    }),
list(id = "ger_bip_annual_volume", category = "GDP", label = "Germany Annual GDP - Chain-linked Volume (Mrd EUR, Destatis)",
    render = function() {
        DE <- file.path(OUT_DIR, "GDP graphs/German labeling")
        EN <- file.path(OUT_DIR, "GDP graphs/English labeling")
        render_graph(ger_bip_annual_volume("Verkettete Volumenangaben (Mrd. EUR)", "Datenquelle: Statistisches Bundesamt (Destatis)",
            decimal_mark = ",", big_mark = "."), "GER BIP annual - chain-linked volume data (bn EUR)_de",
            DE)
        render_graph(ger_bip_annual_volume("Chain-linked volume data (bn EUR)", "Data source: Federal statistical office (Destatis)",
            decimal_mark = ".", big_mark = ","), "GER BIP annual - chain-linked volume data (bn EUR)_en",
            EN)
    }),
list(id = "ger_nominal_gdp", category = "GDP", label = "Germany Nominal GDP (Destatis)", render = function() {
    DE <- file.path(OUT_DIR, "GDP graphs/German labeling")
    EN <- file.path(OUT_DIR, "GDP graphs/English labeling")
    render_graph(ger_nominal_gdp("Nominales BIP (in Mrd. EUR)", "Datenquelle: Statistisches Bundesamt (Destatis)",
        decimal_mark = ",", big_mark = "."), "GER BIP nominal annual_de", DE)
    render_graph(ger_nominal_gdp("Nominal GDP (in Billion EUR)", "Data source: Federal statistical office (Destatis)",
        decimal_mark = ".", big_mark = ","), "GER BIP nominal annual_en", EN)
})
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/gdp/ger_bip_annual.R", .graph_specs)
