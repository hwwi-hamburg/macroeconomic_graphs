# Dual-axis: employed persons (left, in 1000) and GDP (right, Mrd. EUR), quarterly SA.
# Employment: GENESIS 13321-0002, ERW002, X13JDSB (seasonal), KONZEPTA (Arbeitsort), DG.
# GDP: GENESIS 81000-0002, VGR014, X13JDKSB (SA+CA), VGRPVK (chain-linked volume).
ger_employed_gdp_quarterly <- function(source,
                                        label_employed = "Erwerbstätige",
                                        label_bip      = "BIP",
                                        y_axis_left    = "Erwerbstätige (in Tsd.)",
                                        y_axis_right   = "BIP nach Quartalen (Mrd. EUR)",
                                        decimal_mark   = ",", big_mark = ".") {
  raw_emp <- with_cache("genesis_13321-0002",
                         genesis_fetch("13321-0002"))
  employed <- parse_genesis(raw_emp,
                             value_var     = "ERW002",
                             class_filters = list("4_variable_attribute_code" = "X13JDSB",
                                                   "3_variable_attribute_code" = "KONZEPTA",
                                                   "2_variable_attribute_code" = "DG"),
                             series_name   = label_employed,
                             geo           = "DEU",
                             scale         = 1) |>
    dplyr::filter(date >= as.Date(paste0(DATA_START_MONTH, "-01")))

  raw_gdp <- with_cache("genesis_81000-0002",
                         genesis_fetch("81000-0002"))
  gdp <- parse_genesis(raw_gdp,
                        value_var     = "VGR014",
                        class_filters = list("2_variable_attribute_code" = "DG",
                                              "3_variable_attribute_code" = "X13JDKSB",
                                              "4_variable_attribute_code" = "VGRPVK"),
                        series_name   = label_bip,
                        geo           = "DEU") |>
    dplyr::filter(date >= as.Date(paste0(DATA_START_MONTH, "-01")))

  dat <- dplyr::bind_rows(employed, gdp)
  plot_dual_axis(dat, source = source,
                  y_axis_left  = y_axis_left,
                  y_axis_right = y_axis_right,
                  series_left  = label_employed,
                  series_right = label_bip,
                  colors       = c(rubin, blue),
                  decimal_mark = decimal_mark,
                  big_mark     = big_mark,
                  x_breaks     = "2 years",
                  y_min_at_zero = FALSE)
}

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "ger_employed_gdp_quarterly", category = "Employment", label = "Germany Employed Persons and GDP - Quarterly Seasonally Adjusted",
    render = function() {
        DE <- file.path(OUT_DIR, "employment graphs/German labeling")
        EN <- file.path(OUT_DIR, "employment graphs/English labeling")
        render_graph(ger_employed_gdp_quarterly(source = "Datenquelle: Statistisches Bundesamt (Destatis)",
            label_employed = "Erwerbstätige (Arbeitsort, saisonbereinigt)", label_bip = "BIP (saisonbereinigt, preisbereinigt, verkettet)",
            y_axis_left = "Anzahl Erwerbstätige (in Tsd.)", y_axis_right = "BIP nach Quartalen (Mrd. EUR)",
            decimal_mark = ",", big_mark = "."), "GER number of employed persons and gdp by quarter (seasonal adjusted)_de",
            DE)
        render_graph(ger_employed_gdp_quarterly(source = "Data source: Federal Statistical Office (Destatis)",
            label_employed = "Employed persons (in Germany, seasonally adjusted)", label_bip = "GDP (seasonally adjusted, price adjusted, chain-linked)",
            y_axis_left = "Number of employed persons (in 1000)", y_axis_right = "GDP by quarter (bn EUR)",
            decimal_mark = ".", big_mark = ","), "GER number of employed persons and gdp by quarter (seasonal adjusted)_en",
            EN)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/employment/ger_employed_gdp_quarterly.R", .graph_specs)
