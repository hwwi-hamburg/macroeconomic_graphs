.wdi_gdppc_dev <- function(country, y_axis, source, decimal_mark = ".", big_mark = ",") {
  dat <- with_cache(paste0("wdi_NY.GDP.PCAP.PP.KD_", country),
                    fetch_wdi("NY.GDP.PCAP.PP.KD", country = country)) |>
    dplyr::arrange(date)
  plot_timeseries(dat, y_axis = y_axis, source = source,
                  decimal_mark = decimal_mark, big_mark = big_mark)
}

gdp_high_income_development  <- function(y_axis, source, decimal_mark = ".", big_mark = ",")
  .wdi_gdppc_dev("HIC", y_axis, source, decimal_mark, big_mark)

gdp_upper_middle_development <- function(y_axis, source, decimal_mark = ".", big_mark = ",")
  .wdi_gdppc_dev("UMC", y_axis, source, decimal_mark, big_mark)

gdp_lower_middle_development <- function(y_axis, source, decimal_mark = ".", big_mark = ",")
  .wdi_gdppc_dev("LMC", y_axis, source, decimal_mark, big_mark)

gdp_low_income_development   <- function(y_axis, source, decimal_mark = ".", big_mark = ",")
  .wdi_gdppc_dev("LIC", y_axis, source, decimal_mark, big_mark)

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "high_income_gdppc_development", category = "GDP", label = "High Income GDP Per Capita Development (WDI)",
    notes = "GDP per capita, PPP, constant 2021 international $ (World Bank NY.GDP.PCAP.PP.KD). World Bank income classification.",
    render = function() {
        DE <- file.path(OUT_DIR, "GDP graphs/German labeling")
        EN <- file.path(OUT_DIR, "GDP graphs/English labeling")
        render_graph(gdp_high_income_development("BIP pro Kopf, PPP (in 2021 Int'l $) – Hocheinkommensländer",
            "Datenquelle: Nationale Statistik der Weltbank und OECD", decimal_mark = ",", big_mark = "."),
            "HIC GDP p.c. (PPP) real annual Level_de", DE)
        render_graph(gdp_high_income_development("GDP Per Capita, PPP (in 2021 Int'l $) – High Income",
            "Data Source: World Bank National Accounts Data, and OECD National Accounts Data Files",
            big_mark = ","), "HIC GDP p.c. (PPP) real annual Level_en", EN)
    }),
list(id = "upper_middle_gdppc_development", category = "GDP", label = "Upper Middle Income GDP Per Capita Development (WDI)",
    notes = "GDP per capita, PPP, constant 2021 international $ (World Bank NY.GDP.PCAP.PP.KD). World Bank income classification.",
    render = function() {
        DE <- file.path(OUT_DIR, "GDP graphs/German labeling")
        EN <- file.path(OUT_DIR, "GDP graphs/English labeling")
        render_graph(gdp_upper_middle_development("BIP pro Kopf, PPP (in 2021 Int'l $) – Obere Mitteleinkommensländer",
            "Datenquelle: Nationale Statistik der Weltbank und OECD", decimal_mark = ",", big_mark = "."),
            "UMC GDP p.c. (PPP) real annual Level_de", DE)
        render_graph(gdp_upper_middle_development("GDP Per Capita, PPP (in 2021 Int'l $) – Upper Middle Income",
            "Data Source: World Bank National Accounts Data, and OECD National Accounts Data Files",
            big_mark = ","), "UMC GDP p.c. (PPP) real annual Level_en", EN)
    }),
list(id = "lower_middle_gdppc_development", category = "GDP", label = "Lower Middle Income GDP Per Capita Development (WDI)",
    notes = "GDP per capita, PPP, constant 2021 international $ (World Bank NY.GDP.PCAP.PP.KD). World Bank income classification.",
    render = function() {
        DE <- file.path(OUT_DIR, "GDP graphs/German labeling")
        EN <- file.path(OUT_DIR, "GDP graphs/English labeling")
        render_graph(gdp_lower_middle_development("BIP pro Kopf, PPP (in 2021 Int'l $) – Untere Mitteleinkommensländer",
            "Datenquelle: Nationale Statistik der Weltbank und OECD", decimal_mark = ",", big_mark = "."),
            "LMC GDP p.c. (PPP) real annual Level_de", DE)
        render_graph(gdp_lower_middle_development("GDP Per Capita, PPP (in 2021 Int'l $) – Lower Middle Income",
            "Data Source: World Bank National Accounts Data, and OECD National Accounts Data Files",
            big_mark = ","), "LMC GDP p.c. (PPP) real annual Level_en", EN)
    }),
list(id = "low_income_gdppc_development", category = "GDP", label = "Low Income GDP Per Capita Development (WDI)",
    notes = "GDP per capita, PPP, constant 2021 international $ (World Bank NY.GDP.PCAP.PP.KD). World Bank income classification.",
    render = function() {
        DE <- file.path(OUT_DIR, "GDP graphs/German labeling")
        EN <- file.path(OUT_DIR, "GDP graphs/English labeling")
        render_graph(gdp_low_income_development("BIP pro Kopf, PPP (in 2021 Int'l $) – Niedrigeinkommensländer",
            "Datenquelle: Nationale Statistik der Weltbank und OECD", decimal_mark = ",", big_mark = "."),
            "LIC GDP p.c. (PPP) real annual Level_de", DE)
        render_graph(gdp_low_income_development("GDP Per Capita, PPP (in 2021 Int'l $) – Low Income",
            "Data Source: World Bank National Accounts Data, and OECD National Accounts Data Files",
            big_mark = ","), "LIC GDP p.c. (PPP) real annual Level_en", EN)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/gdp/income_gdppc_development.R", .graph_specs)
