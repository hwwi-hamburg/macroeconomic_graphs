# World choropleth maps for trade by destination/origin country.
# Hamburg/LS exports: fetch_trade_by_country; imports: fetch_trade_by_country_import.
# Germany: fetch_ger_trade_by_country with direction argument.

trade_export_hamburg_country <- function(legend_title, source, year = "2025") {
  dat <- with_cache(paste0("genesis_hh_exports_by_country_", year),
                    fetch_trade_by_country(as.integer(year), regional_key = "02"))
  plot_choropleth_world(dat, fill_col = "value", legend_title = legend_title, source = source)
}

trade_import_hamburg_country <- function(legend_title, source, year = "2025") {
  dat <- with_cache(paste0("genesis_hh_imports_by_country_", year),
                    fetch_trade_by_country_import(as.integer(year), regional_key = "02"))
  plot_choropleth_world(dat, fill_col = "value", legend_title = legend_title, source = source)
}

trade_export_lowersaxony_country <- function(legend_title, source, year = "2025") {
  dat <- with_cache(paste0("genesis_ls_exports_by_country_", year),
                    fetch_trade_by_country(as.integer(year), regional_key = "03"))
  plot_choropleth_world(dat, fill_col = "value", legend_title = legend_title, source = source)
}

trade_import_lowersaxony_country <- function(legend_title, source, year = "2025") {
  dat <- with_cache(paste0("genesis_ls_imports_by_country_", year),
                    fetch_trade_by_country_import(as.integer(year), regional_key = "03"))
  plot_choropleth_world(dat, fill_col = "value", legend_title = legend_title, source = source)
}

trade_export_germany_country <- function(legend_title, source, year = "2025") {
  dat <- with_cache(paste0("genesis_ger_exports_by_country_", year),
                    fetch_ger_trade_by_country(as.integer(year), direction = "export"))
  plot_choropleth_world(dat, fill_col = "value", legend_title = legend_title, source = source)
}

trade_import_germany_country <- function(legend_title, source, year = "2025") {
  dat <- with_cache(paste0("genesis_ger_imports_by_country_", year),
                    fetch_ger_trade_by_country(as.integer(year), direction = "import"))
  plot_choropleth_world(dat, fill_col = "value", legend_title = legend_title, source = source)
}

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "trade_export_hamburg_country", category = "Trade", label = "Hamburg Exports by Country (choropleth)",
    render = function() {
        GER <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        yr <- as.character(as.integer(format(Sys.Date(), "%Y")) - 1)
        render_graph(trade_export_hamburg_country("Exporte Hamburgs nach Ländern (in Mio. EUR)", "Datenquelle: Statistisches Bundesamt (Destatis)",
            year = yr), paste0("Hamburg Export by Country ", yr, "_ger"), GER)
        render_graph(trade_export_hamburg_country("Hamburg Exports by Country (in Mio. EUR)", "Data source: Federal statistical office (Destatis)",
            year = yr), paste0("Hamburg Export by Country ", yr, "_en"), EN)
    }),
list(id = "trade_import_hamburg_country", category = "Trade", label = "Hamburg Imports by Country (choropleth)",
    render = function() {
        GER <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        yr <- as.character(as.integer(format(Sys.Date(), "%Y")) - 1)
        render_graph(trade_import_hamburg_country("Importe Hamburgs nach Ländern (in Mio. EUR)", "Datenquelle: Statistisches Bundesamt (Destatis)",
            year = yr), paste0("Hamburg Import by Country ", yr, "_ger"), GER)
        render_graph(trade_import_hamburg_country("Hamburg Imports by Country (in Mio. EUR)", "Data source: Federal statistical office (Destatis)",
            year = yr), paste0("Hamburg Import by Country ", yr, "_en"), EN)
    }),
list(id = "trade_export_lowersaxony_country", category = "Trade", label = "Lower Saxony Exports by Country (choropleth)",
    render = function() {
        GER <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        yr <- as.character(as.integer(format(Sys.Date(), "%Y")) - 1)
        render_graph(trade_export_lowersaxony_country("Exporte Niedersachsens nach Ländern (in Mio. EUR)",
            "Datenquelle: Statistisches Bundesamt (Destatis)", year = yr), paste0("Lower Saxony Export by Country ",
            yr, "_ger"), GER)
        render_graph(trade_export_lowersaxony_country("Lower Saxony Exports by Country (in Mio. EUR)",
            "Data source: Federal statistical office (Destatis)", year = yr), paste0("Lower Saxony Export by Country ",
            yr, "_en"), EN)
    }),
list(id = "trade_import_lowersaxony_country", category = "Trade", label = "Lower Saxony Imports by Country (choropleth)",
    render = function() {
        GER <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        yr <- as.character(as.integer(format(Sys.Date(), "%Y")) - 1)
        render_graph(trade_import_lowersaxony_country("Importe Niedersachsens nach Ländern (in Mio. EUR)",
            "Datenquelle: Statistisches Bundesamt (Destatis)", year = yr), paste0("Lower Saxony Import by Country ",
            yr, "_ger"), GER)
        render_graph(trade_import_lowersaxony_country("Lower Saxony Imports by Country (in Mio. EUR)",
            "Data source: Federal statistical office (Destatis)", year = yr), paste0("Lower Saxony Import by Country ",
            yr, "_en"), EN)
    }),
list(id = "trade_export_germany_country", category = "Trade", label = "Germany Exports by Country (choropleth)",
    render = function() {
        GER <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        yr <- as.character(as.integer(format(Sys.Date(), "%Y")) - 1)
        render_graph(trade_export_germany_country("Ausfuhren nach Ländern (in Mio. EUR)", "Datenquelle: Statistisches Bundesamt (Destatis)",
            year = yr), paste0("Germany Export by Country ", yr, "_ger"), GER)
        render_graph(trade_export_germany_country("Germany Exports by Country (in Mio. EUR)", "Data source: Federal statistical office (Destatis)",
            year = yr), paste0("Germany Export by Country ", yr, "_en"), EN)
    }),
list(id = "trade_import_germany_country", category = "Trade", label = "Germany Imports by Country (choropleth)",
    render = function() {
        GER <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        yr <- as.character(as.integer(format(Sys.Date(), "%Y")) - 1)
        render_graph(trade_import_germany_country("Einfuhren nach Ländern (in Mio. EUR)", "Datenquelle: Statistisches Bundesamt (Destatis)",
            year = yr), paste0("Germany Import by Country ", yr, "_ger"), GER)
        render_graph(trade_import_germany_country("Germany Imports by Country (in Mio. EUR)", "Data source: Federal statistical office (Destatis)",
            year = yr), paste0("Germany Import by Country ", yr, "_en"), EN)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/trade/trade_country_choropleths.R", .graph_specs)
