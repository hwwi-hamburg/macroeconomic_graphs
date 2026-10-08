gdp_world_by_region <- function(y_axis, source, labels,
                                  decimal_mark = ".", big_mark = ",") {
  dat <- with_cache("wdi_NY.GDP.PCAP.PP.KD_regions",
                    fetch_wdi("NY.GDP.PCAP.PP.KD", country = REGION_CODES))
  region_labels <- setNames(labels, REGION_ISO3C)
  dat <- dat |>
    dplyr::filter(!is.na(value)) |>
    dplyr::mutate(series = dplyr::coalesce(region_labels[geo], series))
  plot_timeseries_multi(dat, y_axis = y_axis, source = source,
                        colors = c(hwwi_light_blue, hwwi_blue, hwwi_dark_blue,
                                   hwwi_rubin, hwwi_dark_rubin, hwwi_grey, hwwi_dark_grey),
                        decimal_mark = decimal_mark, big_mark = big_mark)
}

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "world_gdp_by_region", category = "GDP", label = "World GDP Per Capita by Region", render = function() {
    DE <- file.path(OUT_DIR, "GDP graphs/German labeling")
    EN <- file.path(OUT_DIR, "GDP graphs/English labeling")
    render_graph(gdp_world_by_region("BIP Pro Kopf, PPP (in 2021 International $)", "Datenquelle: Nationale Statistik der Weltbank und OECD",
        labels = c("Ostasien und Pazifik", "Europa & Zentralasien", "Lateinamerika & Karibik", "Mittlerer Osten & Nordafrika",
            "Nordamerika", "Südasien", "Sub-Sahara Afrika"), decimal_mark = ",", big_mark = "."), "W GDP p.c. (PPP) real annual Level World Regions_de",
        DE)
    render_graph(gdp_world_by_region("GDP Per Capita, PPP (in 2021 International $)", "Data Source: World Bank National Accounts Data, and OECD National Accounts Data Files",
        labels = c("East Asia & Pacific", "Europe & Central Asia", "Latin America & Caribbean", "Middle East & North Africa",
            "North America", "South Asia", "Sub-Saharan Africa"), decimal_mark = ".", big_mark = ","),
        "W GDP p.c. (PPP) real annual Level World Regions_en", EN)
})
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/gdp/world_gdp_by_region.R", .graph_specs)
