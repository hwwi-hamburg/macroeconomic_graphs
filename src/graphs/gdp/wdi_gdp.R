.wdi_gdp_line <- function(indicator, country, scale = 1, y_axis, source,
                           decimal_mark = ".", big_mark = ",", y_limits = NULL) {
  dat <- with_cache(paste0("wdi_", indicator, "_", country),
                    fetch_wdi(indicator, country = country)) |>
    dplyr::mutate(value = value * scale) |>
    dplyr::arrange(date)
  plot_timeseries(dat, y_axis = y_axis, source = source,
                  decimal_mark = decimal_mark, big_mark = big_mark, y_limits = y_limits)
}

.wdi_gdp_bar <- function(indicator, country, scale = 1, y_axis, source,
                          decimal_mark = ".") {
  dat <- with_cache(paste0("wdi_", indicator, "_", country),
                    fetch_wdi(indicator, country = country)) |>
    dplyr::mutate(value = value * scale) |>
    dplyr::filter(!is.na(value)) |>
    dplyr::arrange(date)
  plot_bar_growth(dat, y_axis = y_axis, source = source, decimal_mark = decimal_mark)
}

gdp_world_development  <- function(y_axis, source, decimal_mark = ".", big_mark = ",", y_limits = c(55e3, 100e3))
  .wdi_gdp_line("NY.GDP.MKTP.KD", "1W", 1 / 1e9, y_axis, source, decimal_mark, big_mark, y_limits)

gdp_germany_development <- function(y_axis, source, decimal_mark = ".", big_mark = ",")
  .wdi_gdp_line("NY.GDP.MKTP.KD", "DEU", 1 / 1e9, y_axis, source, decimal_mark, big_mark)

gdp_world_growth   <- function(y_axis, source, decimal_mark = ".")
  .wdi_gdp_bar("NY.GDP.MKTP.KD.ZG", "1W", 1, y_axis, source, decimal_mark)

gdp_germany_growth <- function(y_axis, source, decimal_mark = ".")
  .wdi_gdp_bar("NY.GDP.MKTP.KD.ZG", "DEU", 1, y_axis, source, decimal_mark)

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "world_gdp_development", category = "GDP", label = "World Real GDP Development", render = function() {
    DE <- file.path(OUT_DIR, "GDP graphs/German labeling")
    EN <- file.path(OUT_DIR, "GDP graphs/English labeling")
    render_graph(gdp_world_development("BIP (in Milliarden 2015 US$)", "Datenquelle: Nationale Statistik der Weltbank und OECD",
        decimal_mark = ",", big_mark = "."), "W GDP real annual Level_de", DE)
    render_graph(gdp_world_development("GDP (in Billion 2015 US$)", "Data Source: World Bank National Accounts Data, and OECD National Accounts Data Files",
        decimal_mark = ".", big_mark = ","), "W GDP real annual Level_en", EN)
}),
list(id = "world_gdp_growth", category = "GDP", label = "World GDP Growth Rate (WDI)", render = function() {
    DE <- file.path(OUT_DIR, "GDP graphs/German labeling")
    EN <- file.path(OUT_DIR, "GDP graphs/English labeling")
    render_graph(gdp_world_growth("BIP-Wachstum (in %)", "Datenquelle: Nationale Statistik der Weltbank und OECD",
        decimal_mark = ","), "W GDP real annual Growth_de", DE)
    render_graph(gdp_world_growth("GDP Growth (in %)", "Data Source: World Bank National Accounts Data, and OECD National Accounts Data Files"),
        "W GDP real annual Growth_en", EN)
}),
list(id = "germany_gdp_development", category = "GDP", label = "Germany Real GDP Development (WDI)",
    render = function() {
        DE <- file.path(OUT_DIR, "GDP graphs/German labeling")
        EN <- file.path(OUT_DIR, "GDP graphs/English labeling")
        render_graph(gdp_germany_development("Reales BIP (in Milliarden 2015 US$)", "Datenquelle: Nationale Statistik der Weltbank und OECD",
            decimal_mark = ",", big_mark = "."), "GER GDP real annual Level WDI_de", DE)
        render_graph(gdp_germany_development("Real GDP (in Billion 2015 US$)", "Data Source: World Bank National Accounts Data, and OECD National Accounts Data Files",
            big_mark = ","), "GER GDP real annual Level WDI_en", EN)
    }),
list(id = "germany_gdp_growth", category = "GDP", label = "Germany GDP Growth Rate (WDI)", render = function() {
    DE <- file.path(OUT_DIR, "GDP graphs/German labeling")
    EN <- file.path(OUT_DIR, "GDP graphs/English labeling")
    render_graph(gdp_germany_growth("BIP-Wachstum (in %)", "Datenquelle: Nationale Statistik der Weltbank und OECD",
        decimal_mark = ","), "GER GDP real annual Growth WDI_de", DE)
    render_graph(gdp_germany_growth("GDP Growth (in %)", "Data Source: World Bank National Accounts Data, and OECD National Accounts Data Files"),
        "GER GDP real annual Growth WDI_en", EN)
})
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/gdp/wdi_gdp.R", .graph_specs)
