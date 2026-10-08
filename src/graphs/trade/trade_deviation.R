# Deviation charts: state trade structure vs. Germany, by commodity group or country.
# Three visualization types: group bar, country bar (top5/bottom5), world choropleth.

# ── private helpers ────────────────────────────────────────────────────────────

.deviation_group_bar <- function(state_key, direction, source, year,
                                  positive_label, negative_label, decimal_mark) {
  yr   <- if (is.null(year)) as.integer(format(Sys.Date(), "%Y")) - 1 else as.integer(year)
  comp <- fetch_state_deviation(yr, state_key = state_key, direction = direction)
  comp <- tibble::tibble(
    date = as.Date(paste0(yr, "-01-01")),
    value = comp$diff,
    series = comp$Group,
    unit = "percentage points",
    geo = state_key
  )
  comp <- comp[order(-comp$value), ]
  comp <- rbind(head(comp, 5), tail(comp, 5))
  plot_bar_deviation(comp, source = source,
                      x_axis = if (decimal_mark == ",") "Prozentpunkte" else "Percentage points",
                      decimal_mark = decimal_mark,
                      positive_label = positive_label, negative_label = negative_label)
}

.deviation_country_bar <- function(state_key, direction, source, year,
                                    positive_label, negative_label, decimal_mark) {
  yr  <- if (is.null(year)) as.integer(format(Sys.Date(), "%Y")) - 1 else as.integer(year)
  dat <- fetch_trade_share_deviation_by_country(yr, regional_key = state_key,
                                                 direction = direction)
  dat <- dat[!is.na(dat$value), ]
  dat$series <- countrycode::countrycode(dat$geo, "iso3c", "country.name", warn = FALSE)
  dat <- dat[!is.na(dat$series), ]
  dat$date <- as.Date(paste0(yr, "-01-01"))
  dat$unit <- "percentage points"
  dat <- dplyr::select(dat, date, value, series, unit, geo)
  comp <- rbind(head(dat[order(-dat$value), ], 5), tail(dat[order(-dat$value), ], 5))
  plot_bar_deviation(comp, source = source,
                      x_axis = if (decimal_mark == ",") "Prozentpunkte" else "Percentage points",
                      decimal_mark = decimal_mark,
                      positive_label = positive_label, negative_label = negative_label)
}

.deviation_country_choropleth <- function(state_key, direction,
                                           source, year, legend_title) {
  yr  <- if (is.null(year)) as.integer(format(Sys.Date(), "%Y")) - 1 else as.integer(year)
  dat <- fetch_trade_share_deviation_by_country(yr, regional_key = state_key,
                                                 direction = direction)
  plot_choropleth_world_div(dat, fill_col = "value", legend_title = legend_title,
                             source = source)
}

# ── commodity-group deviation bars (HH and LS) ────────────────────────────────

trade_hh_export_deviation_group <- function(source, year = NULL,
                                              positive_label = "HH > Deutschland",
                                              negative_label = "HH < Deutschland",
                                              decimal_mark = ",")
  .deviation_group_bar("02", "export", source, year, positive_label, negative_label, decimal_mark)

trade_hh_import_deviation_group <- function(source, year = NULL,
                                              positive_label = "HH > Deutschland",
                                              negative_label = "HH < Deutschland",
                                              decimal_mark = ",")
  .deviation_group_bar("02", "import", source, year, positive_label, negative_label, decimal_mark)

trade_ls_export_deviation_group <- function(source, year = NULL,
                                              positive_label = "LS > Deutschland",
                                              negative_label = "LS < Deutschland",
                                              decimal_mark = ",")
  .deviation_group_bar("03", "export", source, year, positive_label, negative_label, decimal_mark)

trade_ls_import_deviation_group <- function(source, year = NULL,
                                              positive_label = "LS > Deutschland",
                                              negative_label = "LS < Deutschland",
                                              decimal_mark = ",")
  .deviation_group_bar("03", "import", source, year, positive_label, negative_label, decimal_mark)

# Aliases used in registry for group-level deviation bar (identical computation).
hh_export_deviation_country_map <- function(source, year = NULL,
                                              positive_label = "HH > Deutschland",
                                              negative_label = "HH < Deutschland",
                                              decimal_mark = ",")
  .deviation_group_bar("02", "export", source, year, positive_label, negative_label, decimal_mark)

hh_import_deviation_country_map <- function(source, year = NULL,
                                              positive_label = "HH > Deutschland",
                                              negative_label = "HH < Deutschland",
                                              decimal_mark = ",")
  .deviation_group_bar("02", "import", source, year, positive_label, negative_label, decimal_mark)

# ── country deviation bars (HH and LS) ────────────────────────────────────────

hh_export_deviation_country <- function(source, year = NULL,
                                          positive_label = "HH > Deutschland",
                                          negative_label = "HH < Deutschland",
                                          decimal_mark = ",")
  .deviation_country_bar("02", "export", source, year,
                          positive_label, negative_label, decimal_mark)

hh_import_deviation_country <- function(source, year = NULL,
                                          positive_label = "HH > Deutschland",
                                          negative_label = "HH < Deutschland",
                                          decimal_mark = ",")
  .deviation_country_bar("02", "import", source, year,
                          positive_label, negative_label, decimal_mark)

ls_export_deviation_country <- function(source, year = NULL,
                                          positive_label = "LS > Deutschland",
                                          negative_label = "LS < Deutschland",
                                          decimal_mark = ",")
  .deviation_country_bar("03", "export", source, year,
                          positive_label, negative_label, decimal_mark)

ls_import_deviation_country <- function(source, year = NULL,
                                          positive_label = "LS > Deutschland",
                                          negative_label = "LS < Deutschland",
                                          decimal_mark = ",")
  .deviation_country_bar("03", "import", source, year,
                          positive_label, negative_label, decimal_mark)

# Top-5 / bottom-5 country variants (same computation, explicit year default).
trade_hh_export_topbottom_country <- function(source, year = "2025",
                                                positive_label = "HH > Deutschland",
                                                negative_label = "HH < Deutschland",
                                                decimal_mark = ",")
  .deviation_country_bar("02", "export", source, year,
                          positive_label, negative_label, decimal_mark)

trade_hh_import_topbottom_country <- function(source, year = "2025",
                                                positive_label = "HH > Deutschland",
                                                negative_label = "HH < Deutschland",
                                                decimal_mark = ",")
  .deviation_country_bar("02", "import", source, year,
                          positive_label, negative_label, decimal_mark)

trade_ls_export_topbottom_country <- function(source, year = "2025",
                                                positive_label = "LS > Deutschland",
                                                negative_label = "LS < Deutschland",
                                                decimal_mark = ",")
  .deviation_country_bar("03", "export", source, year,
                          positive_label, negative_label, decimal_mark)

trade_ls_import_topbottom_country <- function(source, year = "2025",
                                                positive_label = "LS > Deutschland",
                                                negative_label = "LS < Deutschland",
                                                decimal_mark = ",")
  .deviation_country_bar("03", "import", source, year,
                          positive_label, negative_label, decimal_mark)

# ── country deviation choropleths ──────────────────────────────────────────────

hh_export_deviation_choropleth <- function(legend_title, source, year = NULL)
  .deviation_country_choropleth("02", "export", source, year, legend_title)

hh_import_deviation_choropleth <- function(legend_title, source, year = NULL)
  .deviation_country_choropleth("02", "import", source, year, legend_title)

ls_export_deviation_choropleth <- function(legend_title, source, year = NULL)
  .deviation_country_choropleth("03", "export", source, year, legend_title)

ls_import_deviation_choropleth <- function(legend_title, source, year = NULL)
  .deviation_country_choropleth("03", "import", source, year, legend_title)

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "trade_hh_export_deviation_group", category = "Trade", label = "Hamburg vs Germany: Export Structure by Commodity Group",
    notes = "Share of each commodity group in Hamburg's exports minus its share in Germany's, in percentage points; previous calendar year. Own calculation.",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(trade_hh_export_deviation_group(source = "Datenquelle: Statistisches Bundesamt (Destatis)",
            positive_label = "HH überrepräsentiert", negative_label = "HH unterrepräsentiert", decimal_mark = ","),
            "HH vs GER Export Structure Deviation by Group_de", DE, height = 10)
        render_graph(trade_hh_export_deviation_group(source = "Data source: Federal statistical office (Destatis)",
            positive_label = "HH over-represented", negative_label = "HH under-represented", decimal_mark = "."),
            "HH vs GER Export Structure Deviation by Group_en", EN, height = 10)
    }),
list(id = "trade_hh_import_deviation_group", category = "Trade", label = "Hamburg vs Germany: Import Structure by Commodity Group",
    notes = "Share of each commodity group in Hamburg's imports minus its share in Germany's, in percentage points; previous calendar year. Own calculation.",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(trade_hh_import_deviation_group(source = "Datenquelle: Statistisches Bundesamt (Destatis)",
            positive_label = "HH überrepräsentiert", negative_label = "HH unterrepräsentiert", decimal_mark = ","),
            "HH vs GER Import Structure Deviation by Group_de", DE, height = 10)
        render_graph(trade_hh_import_deviation_group(source = "Data source: Federal statistical office (Destatis)",
            positive_label = "HH over-represented", negative_label = "HH under-represented", decimal_mark = "."),
            "HH vs GER Import Structure Deviation by Group_en", EN, height = 10)
    }),
list(id = "trade_ls_export_deviation_group", category = "Trade", label = "Lower Saxony vs Germany: Export Structure by Commodity Group",
    notes = "Share of each commodity group in Lower Saxony's exports minus its share in Germany's, in percentage points; previous calendar year. Own calculation.",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(trade_ls_export_deviation_group(source = "Datenquelle: Statistisches Bundesamt (Destatis)",
            positive_label = "LS überrepräsentiert", negative_label = "LS unterrepräsentiert", decimal_mark = ","),
            "LS vs GER Export Structure Deviation by Group_de", DE, height = 10)
        render_graph(trade_ls_export_deviation_group(source = "Data source: Federal statistical office (Destatis)",
            positive_label = "LS over-represented", negative_label = "LS under-represented", decimal_mark = "."),
            "LS vs GER Export Structure Deviation by Group_en", EN, height = 10)
    }),
list(id = "trade_ls_import_deviation_group", category = "Trade", label = "Lower Saxony vs Germany: Import Structure by Commodity Group",
    notes = "Share of each commodity group in Lower Saxony's imports minus its share in Germany's, in percentage points; previous calendar year. Own calculation.",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(trade_ls_import_deviation_group(source = "Datenquelle: Statistisches Bundesamt (Destatis)",
            positive_label = "LS überrepräsentiert", negative_label = "LS unterrepräsentiert", decimal_mark = ","),
            "LS vs GER Import Structure Deviation by Group_de", DE, height = 10)
        render_graph(trade_ls_import_deviation_group(source = "Data source: Federal statistical office (Destatis)",
            positive_label = "LS over-represented", negative_label = "LS under-represented", decimal_mark = "."),
            "LS vs GER Import Structure Deviation by Group_en", EN, height = 10)
    }),
list(id = "trade_hh_export_topbottom_country", category = "Trade", label = "Hamburg Top Export Partners (pp deviation vs Germany)",
    notes = "Share of each country in the state's exports minus its share in Germany's exports, in percentage points; previous calendar year. Own calculation.",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        yr <- as.character(as.integer(format(Sys.Date(), "%Y")) - 1)
        render_graph(trade_hh_export_topbottom_country(source = "Datenquelle: Statistisches Bundesamt (Destatis)",
            year = yr, positive_label = "HH überrepräsentiert", negative_label = "HH unterrepräsentiert",
            decimal_mark = ","), paste0("Hamburg Top Export Partners ", yr, "_de"), DE, height = 7)
        render_graph(trade_hh_export_topbottom_country(source = "Data source: Federal statistical office (Destatis)",
            year = yr, positive_label = "HH over-represented", negative_label = "HH under-represented",
            decimal_mark = "."), paste0("Hamburg Top Export Partners ", yr, "_en"), EN, height = 7)
    }),
list(id = "trade_hh_import_topbottom_country", category = "Trade", label = "Hamburg Top Import Partners (pp deviation vs Germany)",
    notes = "Share of each country in the state's imports minus its share in Germany's imports, in percentage points; previous calendar year. Own calculation.",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        yr <- as.character(as.integer(format(Sys.Date(), "%Y")) - 1)
        render_graph(trade_hh_import_topbottom_country(source = "Datenquelle: Statistisches Bundesamt (Destatis)",
            year = yr, positive_label = "HH überrepräsentiert", negative_label = "HH unterrepräsentiert",
            decimal_mark = ","), paste0("Hamburg Top Import Partners ", yr, "_de"), DE, height = 7)
        render_graph(trade_hh_import_topbottom_country(source = "Data source: Federal statistical office (Destatis)",
            year = yr, positive_label = "HH over-represented", negative_label = "HH under-represented",
            decimal_mark = "."), paste0("Hamburg Top Import Partners ", yr, "_en"), EN, height = 7)
    }),
list(id = "trade_ls_export_topbottom_country", category = "Trade", label = "Lower Saxony Top Export Partners (pp deviation vs Germany)",
    notes = "Share of each country in the state's exports minus its share in Germany's exports, in percentage points; previous calendar year. Own calculation.",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        yr <- as.character(as.integer(format(Sys.Date(), "%Y")) - 1)
        render_graph(trade_ls_export_topbottom_country(source = "Datenquelle: Statistisches Bundesamt (Destatis)",
            year = yr, positive_label = "LS überrepräsentiert", negative_label = "LS unterrepräsentiert",
            decimal_mark = ","), paste0("Lower Saxony Top Export Partners ", yr, "_de"), DE, height = 7)
        render_graph(trade_ls_export_topbottom_country(source = "Data source: Federal statistical office (Destatis)",
            year = yr, positive_label = "LS over-represented", negative_label = "LS under-represented",
            decimal_mark = "."), paste0("Lower Saxony Top Export Partners ", yr, "_en"), EN, height = 7)
    }),
list(id = "trade_ls_import_topbottom_country", category = "Trade", label = "Lower Saxony Top Import Partners (pp deviation vs Germany)",
    notes = "Share of each country in the state's imports minus its share in Germany's imports, in percentage points; previous calendar year. Own calculation.",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        yr <- as.character(as.integer(format(Sys.Date(), "%Y")) - 1)
        render_graph(trade_ls_import_topbottom_country(source = "Datenquelle: Statistisches Bundesamt (Destatis)",
            year = yr, positive_label = "LS überrepräsentiert", negative_label = "LS unterrepräsentiert",
            decimal_mark = ","), paste0("Lower Saxony Top Import Partners ", yr, "_de"), DE, height = 7)
        render_graph(trade_ls_import_topbottom_country(source = "Data source: Federal statistical office (Destatis)",
            year = yr, positive_label = "LS over-represented", negative_label = "LS under-represented",
            decimal_mark = "."), paste0("Lower Saxony Top Import Partners ", yr, "_en"), EN, height = 7)
    }),
list(id = "trade_hh_export_deviation_country_map", category = "Trade", label = "HH Export - Deviations from German Average (by category)",
    notes = "Share of each commodity group in Hamburg's exports minus its share in Germany's, in percentage points; previous calendar year. Own calculation.",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        yr <- as.character(as.integer(format(Sys.Date(), "%Y")) - 1)
        render_graph(hh_export_deviation_country_map(source = "Datenquelle: Statistisches Bundesamt (Destatis)",
            year = yr, positive_label = "HH überrepräsentiert", negative_label = "HH unterrepräsentiert",
            decimal_mark = ","), paste0("HH Export - Deviations from German Average ", yr, "_de"), DE,
            height = 7)
        render_graph(hh_export_deviation_country_map(source = "Data source: Federal statistical office (Destatis)",
            year = yr, positive_label = "HH over-represented", negative_label = "HH under-represented",
            decimal_mark = "."), paste0("HH Export - Deviations from German Average ", yr, "_en"), EN,
            height = 7)
    }),
list(id = "trade_hh_import_deviation_country_map", category = "Trade", label = "HH Import - Deviations from German Average (by category)",
    notes = "Share of each commodity group in Hamburg's imports minus its share in Germany's, in percentage points; previous calendar year. Own calculation.",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        yr <- as.character(as.integer(format(Sys.Date(), "%Y")) - 1)
        render_graph(hh_import_deviation_country_map(source = "Datenquelle: Statistisches Bundesamt (Destatis)",
            year = yr, positive_label = "HH überrepräsentiert", negative_label = "HH unterrepräsentiert",
            decimal_mark = ","), paste0("HH Import - Deviations from German Average ", yr, "_de"), DE,
            height = 7)
        render_graph(hh_import_deviation_country_map(source = "Data source: Federal statistical office (Destatis)",
            year = yr, positive_label = "HH over-represented", negative_label = "HH under-represented",
            decimal_mark = "."), paste0("HH Import - Deviations from German Average ", yr, "_en"), EN,
            height = 7)
    }),
list(id = "trade_hh_export_deviation_country", category = "Trade", label = "HH Export - Deviations from German Average by Country",
    notes = "Share of each country in the state's exports minus its share in Germany's exports, in percentage points; previous calendar year. Own calculation.",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        yr <- as.character(as.integer(format(Sys.Date(), "%Y")) - 1)
        render_graph(hh_export_deviation_country(source = "Datenquelle: Statistisches Bundesamt (Destatis)",
            year = yr, positive_label = "HH überrepräsentiert", negative_label = "HH unterrepräsentiert",
            decimal_mark = ","), paste0("HH Export - Deviations from German Average by Country ", yr,
            "_de"), DE, height = 7)
        render_graph(hh_export_deviation_country(source = "Data source: Federal statistical office (Destatis)",
            year = yr, positive_label = "HH over-represented", negative_label = "HH under-represented",
            decimal_mark = "."), paste0("HH Export - Deviations from German Average by Country ", yr,
            "_en"), EN, height = 7)
    }),
list(id = "trade_hh_import_deviation_country", category = "Trade", label = "HH Import - Deviations from German Average by Country",
    notes = "Share of each country in the state's imports minus its share in Germany's imports, in percentage points; previous calendar year. Own calculation.",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        yr <- as.character(as.integer(format(Sys.Date(), "%Y")) - 1)
        render_graph(hh_import_deviation_country(source = "Datenquelle: Statistisches Bundesamt (Destatis)",
            year = yr, positive_label = "HH überrepräsentiert", negative_label = "HH unterrepräsentiert",
            decimal_mark = ","), paste0("HH Import - Deviations from German Average by Country ", yr,
            "_de"), DE, height = 7)
        render_graph(hh_import_deviation_country(source = "Data source: Federal statistical office (Destatis)",
            year = yr, positive_label = "HH over-represented", negative_label = "HH under-represented",
            decimal_mark = "."), paste0("HH Import - Deviations from German Average by Country ", yr,
            "_en"), EN, height = 7)
    }),
list(id = "trade_hh_export_comparison_country_2025", category = "Trade", label = "Hamburg vs Germany Export Share Comparison by Country in 2025",
    notes = "Share of each country in the state's exports minus its share in Germany's exports, in percentage points; 2025. Own calculation.",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(hh_export_deviation_choropleth("Exportanteil HH minus Deutschland (in Pp.)", "Datenquelle: Statistisches Bundesamt (Destatis)",
            year = 2025), "Hamburg vs Germany Export Share Comparison by Country in 2025_de", DE)
        render_graph(hh_export_deviation_choropleth("HH export share minus Germany (in pp.)", "Data source: Federal statistical office (Destatis)",
            year = 2025), "Hamburg vs Germany Export Share Comparison by Country in 2025_en", EN)
    }),
list(id = "trade_hh_import_comparison_country_2025", category = "Trade", label = "Hamburg vs Germany Import Share Comparison by Country in 2025",
    notes = "Share of each country in the state's imports minus its share in Germany's imports, in percentage points; 2025. Own calculation.",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(hh_import_deviation_choropleth("Importanteil HH minus Deutschland (in Pp.)", "Datenquelle: Statistisches Bundesamt (Destatis)",
            year = 2025), "Hamburg vs Germany Import Share Comparison by Country in 2025_de", DE)
        render_graph(hh_import_deviation_choropleth("HH import share minus Germany (in pp.)", "Data source: Federal statistical office (Destatis)",
            year = 2025), "Hamburg vs Germany Import Share Comparison by Country in 2025_en", EN)
    }),
list(id = "trade_ls_export_deviation_country", category = "Trade", label = "Lower Saxony Export - Deviations from German Average by Country",
    notes = "Share of each country in the state's exports minus its share in Germany's exports, in percentage points; previous calendar year. Own calculation.",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        yr <- as.character(as.integer(format(Sys.Date(), "%Y")) - 1)
        render_graph(ls_export_deviation_country(source = "Datenquelle: Statistisches Bundesamt (Destatis)",
            year = yr, positive_label = "LS überrepräsentiert", negative_label = "LS unterrepräsentiert",
            decimal_mark = ","), paste0("LS Export - Deviations from German Average by Country ", yr,
            "_de"), DE, height = 7)
        render_graph(ls_export_deviation_country(source = "Data source: Federal statistical office (Destatis)",
            year = yr, positive_label = "LS over-represented", negative_label = "LS under-represented",
            decimal_mark = "."), paste0("LS Export - Deviations from German Average by Country ", yr,
            "_en"), EN, height = 7)
    }),
list(id = "trade_ls_import_deviation_country", category = "Trade", label = "Lower Saxony Import - Deviations from German Average by Country",
    notes = "Share of each country in the state's imports minus its share in Germany's imports, in percentage points; previous calendar year. Own calculation.",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        yr <- as.character(as.integer(format(Sys.Date(), "%Y")) - 1)
        render_graph(ls_import_deviation_country(source = "Datenquelle: Statistisches Bundesamt (Destatis)",
            year = yr, positive_label = "LS überrepräsentiert", negative_label = "LS unterrepräsentiert",
            decimal_mark = ","), paste0("LS Import - Deviations from German Average by Country ", yr,
            "_de"), DE, height = 7)
        render_graph(ls_import_deviation_country(source = "Data source: Federal statistical office (Destatis)",
            year = yr, positive_label = "LS over-represented", negative_label = "LS under-represented",
            decimal_mark = "."), paste0("LS Import - Deviations from German Average by Country ", yr,
            "_en"), EN, height = 7)
    }),
list(id = "trade_ls_export_comparison_country_2025", category = "Trade", label = "Lower Saxony vs Germany Export Share Comparison by Country in 2025",
    notes = "Share of each country in the state's exports minus its share in Germany's exports, in percentage points; 2025. Own calculation.",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(ls_export_deviation_choropleth("Exportanteil LS minus Deutschland (in Pp.)", "Datenquelle: Statistisches Bundesamt (Destatis)",
            year = 2025), "Lower Saxony vs Germany Export Share Comparison by Country in 2025_de", DE)
        render_graph(ls_export_deviation_choropleth("LS export share minus Germany (in pp.)", "Data source: Federal statistical office (Destatis)",
            year = 2025), "Lower Saxony vs Germany Export Share Comparison by Country in 2025_en", EN)
    }),
list(id = "trade_ls_import_comparison_country_2025", category = "Trade", label = "Lower Saxony vs Germany Import Share Comparison by Country in 2025",
    notes = "Share of each country in the state's imports minus its share in Germany's imports, in percentage points; 2025. Own calculation.",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        render_graph(ls_import_deviation_choropleth("Importanteil LS minus Deutschland (in Pp.)", "Datenquelle: Statistisches Bundesamt (Destatis)",
            year = 2025), "Lower Saxony vs Germany Import Share Comparison by Country in 2025_de", DE)
        render_graph(ls_import_deviation_choropleth("LS import share minus Germany (in pp.)", "Data source: Federal statistical office (Destatis)",
            year = 2025), "Lower Saxony vs Germany Import Share Comparison by Country in 2025_en", EN)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/trade/trade_deviation.R", .graph_specs)
