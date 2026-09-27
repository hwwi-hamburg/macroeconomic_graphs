.wdi_gdppc_growth <- function(country, y_axis, caption, decimal_mark = ".") {
  dat <- with_cache(paste0("wdi_NY.GDP.PCAP.KD.ZG_", country),
                    fetch_wdi("NY.GDP.PCAP.KD.ZG", country = country)) |>
    dplyr::filter(!is.na(value)) |>
    dplyr::arrange(date)
  plot_bar_growth(dat, y_axis = y_axis, caption = caption, decimal_mark = decimal_mark)
}

gdp_high_income_growth   <- function(y_axis, caption, decimal_mark = ".") .wdi_gdppc_growth("HIC", y_axis, caption, decimal_mark)
gdp_upper_middle_growth  <- function(y_axis, caption, decimal_mark = ".") .wdi_gdppc_growth("UMC", y_axis, caption, decimal_mark)
gdp_lower_middle_growth  <- function(y_axis, caption, decimal_mark = ".") .wdi_gdppc_growth("LMC", y_axis, caption, decimal_mark)
gdp_low_income_growth    <- function(y_axis, caption, decimal_mark = ".") .wdi_gdppc_growth("LIC", y_axis, caption, decimal_mark)

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "high_income_gdppc_growth", category = "GDP", label = "High Income GDP Per Capita Growth (WDI)",
    render = function() {
        GER <- file.path(OUT_DIR, "GDP graphs/German labeling")
        EN <- file.path(OUT_DIR, "GDP graphs/English labeling")
        render_graph(gdp_high_income_growth("BIP pro Kopf Wachstum (in %) – Hocheinkommensländer",
            "Datenquelle: Nationale Statistik der Weltbank und OECD", decimal_mark = ","), "HIC GDP p.c. real annual Growth_ger",
            GER)
        render_graph(gdp_high_income_growth("GDP Per Capita Growth (in %) – High Income", "Data Source: World Bank National Accounts Data, and OECD National Accounts Data Files"),
            "HIC GDP p.c. real annual Growth_en", EN)
    }),
list(id = "upper_middle_gdppc_growth", category = "GDP", label = "Upper Middle Income GDP Per Capita Growth (WDI)",
    render = function() {
        GER <- file.path(OUT_DIR, "GDP graphs/German labeling")
        EN <- file.path(OUT_DIR, "GDP graphs/English labeling")
        render_graph(gdp_upper_middle_growth("BIP pro Kopf Wachstum (in %) – Obere Mitteleinkommensländer",
            "Datenquelle: Nationale Statistik der Weltbank und OECD", decimal_mark = ","), "UMC GDP p.c. real annual Growth_ger",
            GER)
        render_graph(gdp_upper_middle_growth("GDP Per Capita Growth (in %) – Upper Middle Income",
            "Data Source: World Bank National Accounts Data, and OECD National Accounts Data Files"),
            "UMC GDP p.c. real annual Growth_en", EN)
    }),
list(id = "lower_middle_gdppc_growth", category = "GDP", label = "Lower Middle Income GDP Per Capita Growth (WDI)",
    render = function() {
        GER <- file.path(OUT_DIR, "GDP graphs/German labeling")
        EN <- file.path(OUT_DIR, "GDP graphs/English labeling")
        render_graph(gdp_lower_middle_growth("BIP pro Kopf Wachstum (in %) – Untere Mitteleinkommensländer",
            "Datenquelle: Nationale Statistik der Weltbank und OECD", decimal_mark = ","), "LMC GDP p.c. real annual Growth_ger",
            GER)
        render_graph(gdp_lower_middle_growth("GDP Per Capita Growth (in %) – Lower Middle Income",
            "Data Source: World Bank National Accounts Data, and OECD National Accounts Data Files"),
            "LMC GDP p.c. real annual Growth_en", EN)
    }),
list(id = "low_income_gdppc_growth", category = "GDP", label = "Low Income GDP Per Capita Growth (WDI)",
    render = function() {
        GER <- file.path(OUT_DIR, "GDP graphs/German labeling")
        EN <- file.path(OUT_DIR, "GDP graphs/English labeling")
        render_graph(gdp_low_income_growth("BIP pro Kopf Wachstum (in %) – Niedrigeinkommensländer",
            "Datenquelle: Nationale Statistik der Weltbank und OECD", decimal_mark = ","), "LIC GDP p.c. real annual Growth_ger",
            GER)
        render_graph(gdp_low_income_growth("GDP Per Capita Growth (in %) – Low Income", "Data Source: World Bank National Accounts Data, and OECD National Accounts Data Files"),
            "LIC GDP p.c. real annual Growth_en", EN)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/gdp/income_gdppc_growth.R", .graph_specs)
