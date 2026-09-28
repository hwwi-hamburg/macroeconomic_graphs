# Quarterly German GDP from GENESIS 81000-0002. Shares cache across all functions.
# X13JDKSB = seasonally + calendar adjusted; WERTORG = original unadjusted.
# VGRPKM = chain index (2020=100); VGRPVK = chain-linked volumes (Mrd. EUR).

.ger_bip_quarterly <- function(value_var, sa_code, filter_code, series_name,
                                 y_axis, source, decimal_mark, big_mark = ",") {
  raw <- with_cache("genesis_81000-0002",
                    genesis_fetch("81000-0002"))
  dat <- parse_genesis(raw,
                        value_var     = value_var,
                        class_filters = list("2_variable_attribute_code" = "DG",
                                             "3_variable_attribute_code" = sa_code,
                                             "4_variable_attribute_code" = filter_code),
                        series_name   = series_name,
                        geo           = "DEU") |>
    trim_start_month(DATA_START_MONTH)
  plot_timeseries(dat, y_axis = y_axis, source = source,
                  decimal_mark = decimal_mark, big_mark = big_mark,
                  x_breaks = "2 years")
}

ger_bip_quarterly_development <- function(y_axis, source, decimal_mark = ",")
  .ger_bip_quarterly("VGR014", "X13JDKSB", "VGRPKM", "gdp_quarterly_level",
                       y_axis, source, decimal_mark)

ger_bip_quarterly_growth <- function(y_axis, source, decimal_mark = ",")
  .ger_bip_quarterly("BIP005", "X13JDKSB", "VGRPKM", "gdp_quarterly_growth",
                       y_axis, source, decimal_mark)

ger_bip_quarterly_volume <- function(y_axis, source, decimal_mark = ",", big_mark = ".")
  .ger_bip_quarterly("VGR014", "X13JDKSB", "VGRPVK", "gdp_quarterly_volume",
                       y_axis, source, decimal_mark, big_mark)

ger_bip_quarterly_volume_orig <- function(y_axis, source, decimal_mark = ",", big_mark = ".")
  .ger_bip_quarterly("VGR014", "WERTORG", "VGRPVK", "gdp_quarterly_volume_orig",
                       y_axis, source, decimal_mark, big_mark)

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "ger_bip_quarterly_development", category = "GDP", label = "Germany Quarterly GDP Level - Chain Index (Destatis)",
    render = function() {
        GER <- file.path(OUT_DIR, "GDP graphs/German labeling")
        EN <- file.path(OUT_DIR, "GDP graphs/English labeling")
        render_graph(ger_bip_quarterly_development("Kettenindex (2020=100), saisonbereinigt", "Datenquelle: Statistisches Bundesamt (Destatis)"),
            "GER BIP quarterly level - chain index_ger", GER)
        render_graph(ger_bip_quarterly_development("Chain Index (2020=100), seasonally adjusted", "Data source: Federal statistical office (Destatis)",
            decimal_mark = "."), "GER BIP quarterly level - chain index_en", EN)
    }),
list(id = "ger_bip_quarterly_growth", category = "GDP", label = "Germany Quarterly GDP Growth Rate (Destatis)",
    render = function() {
        GER <- file.path(OUT_DIR, "GDP graphs/German labeling")
        EN <- file.path(OUT_DIR, "GDP graphs/English labeling")
        render_graph(ger_bip_quarterly_growth("Veränderung gg. Vj. (in %), saisonbereinigt", "Datenquelle: Statistisches Bundesamt (Destatis)"),
            "GER BIP quarterly growth_ger", GER)
        render_graph(ger_bip_quarterly_growth("Change vs. prev. year (in %), seasonally adjusted", "Data source: Federal statistical office (Destatis)",
            decimal_mark = "."), "GER BIP quarterly growth_en", EN)
    }),
list(id = "ger_bip_quarterly_volume_orig", category = "GDP", label = "Germany Quarterly GDP - Chain-linked Volume (Mrd EUR, original)",
    render = function() {
        GER <- file.path(OUT_DIR, "GDP graphs/German labeling")
        EN <- file.path(OUT_DIR, "GDP graphs/English labeling")
        render_graph(ger_bip_quarterly_volume_orig("BIP (in Mrd. EUR, verkettete Volumen, Originalwerte)",
            "Datenquelle: Statistisches Bundesamt (Destatis)", decimal_mark = ",", big_mark = "."), "GER BIP quarterly - chain-linked volume data (bn EUR)_ger",
            GER)
        render_graph(ger_bip_quarterly_volume_orig("GDP (in Billion EUR, chain-linked volume, original)",
            "Data source: Federal statistical office (Destatis)", decimal_mark = ".", big_mark = ","),
            "GER BIP quarterly - chain-linked volume data (bn EUR)_en", EN)
    }),
list(id = "ger_bip_quarterly_volume", category = "GDP", label = "Germany Quarterly GDP - Chain-linked Volume (Mrd EUR, SA)",
    render = function() {
        GER <- file.path(OUT_DIR, "GDP graphs/German labeling")
        EN <- file.path(OUT_DIR, "GDP graphs/English labeling")
        render_graph(ger_bip_quarterly_volume("BIP (in Mrd. EUR, verkettete Volumen, saisonbereinigt)",
            "Quelle: Statistisches Bundesamt (Destatis) (2026). ", decimal_mark = ",", big_mark = "."), "GER BIP quarterly volume_ger",
            GER)
        render_graph(ger_bip_quarterly_volume("GDP (in Billion EUR, chain-linked volume, seasonally adjusted)",
            "Source: Federal statistical office (Destatis) (2026).", decimal_mark = ".", big_mark = ","),
            "GER BIP quarterly volume_en", EN)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/gdp/ger_bip_quarterly.R", .graph_specs)
