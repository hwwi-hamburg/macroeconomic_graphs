# Pie charts for trade structure by commodity group (top 10 + rest).
# Hamburg/LS from GENESIS 51000-0034; Germany from 51000-0005.

.as_trade_pie_tibble <- function(dat, value_col, year, geo) {
  tibble::tibble(
    date = as.Date(paste0(year, "-01-01")),
    value = as.numeric(dat[[value_col]]),
    series = as.character(dat$Group),
    unit = "Mrd. EUR",
    geo = geo
  )
}

.state_pie <- function(state_key, state_label, direction,
                        source, big_mark, decimal_mark, n_inside, start_angle) {
  year <- as.integer(format(Sys.Date(), "%Y")) - 1
  raw  <- with_cache(paste0("genesis_51000-0034_gp19_explicit_", state_label, "_", year),
                     fetch_state_trade_commodity(year, state_key = state_key))
  top  <- raw[1:10, c("Group", direction)]
  rest <- setNames(
    data.frame("Sonstige", sum(raw[[direction]][11:nrow(raw)], na.rm = TRUE)),
    c("Group", direction)
  )
  dat <- .as_trade_pie_tibble(rbind(top, rest), direction, year, state_label)
  plot_pie(dat,
            source = source, big_mark = big_mark, decimal_mark = decimal_mark,
            n_inside = n_inside, text_size = 2.4,
            start_angle = start_angle, x_limit = 4.75,
            plot_margin = ggplot2::margin(-20, 100, 20, -100))
}

trade_export_hamburg_pie <- function(source, big_mark = ".", decimal_mark = ",")
  .state_pie("02", "HH", "Export", source, big_mark, decimal_mark,
              n_inside = 2, start_angle = pi / 3)

trade_import_hamburg_pie <- function(source, big_mark = ".", decimal_mark = ",")
  .state_pie("02", "HH", "Import", source, big_mark, decimal_mark,
              n_inside = 2, start_angle = pi / 3)

trade_export_lowersaxony_pie <- function(source, big_mark = ".", decimal_mark = ",")
  .state_pie("03", "LS", "Export", source, big_mark, decimal_mark,
              n_inside = 1, start_angle = pi / 4.5)

trade_import_lowersaxony_pie <- function(source, big_mark = ".", decimal_mark = ",")
  .state_pie("03", "LS", "Import", source, big_mark, decimal_mark,
              n_inside = 1, start_angle = pi / 4.5)

trade_export_germany_pie <- function(source, big_mark = ".", decimal_mark = ",") {
  year <- as.integer(format(Sys.Date(), "%Y")) - 1
  raw  <- with_cache(paste0("genesis_51000-0005_wam2_explicit_", year), fetch_ger_trade_commodity(year))
  top  <- raw[1:10, c("Group", "GerExport")]
  rest <- data.frame(Group = "Sonstige",
                     GerExport = sum(raw$GerExport[11:nrow(raw)], na.rm = TRUE))
  dat <- .as_trade_pie_tibble(rbind(top, rest), "GerExport", year, "DEU")
  plot_pie(dat,
            source = source, big_mark = big_mark, decimal_mark = decimal_mark,
            n_inside = 1, inside_x = 2)
}

trade_import_germany_pie <- function(source, big_mark = ".", decimal_mark = ",") {
  year <- as.integer(format(Sys.Date(), "%Y")) - 1
  raw  <- with_cache(paste0("genesis_51000-0005_wam2_explicit_", year), fetch_ger_trade_commodity(year))
  top  <- raw[1:10, c("Group", "GerImport")]
  rest <- data.frame(Group     = "Sonstige",
                     GerImport = sum(raw$GerImport[11:nrow(raw)], na.rm = TRUE))
  dat <- .as_trade_pie_tibble(rbind(top, rest), "GerImport", year, "DEU")
  plot_pie(dat,
            source = source, big_mark = big_mark, decimal_mark = decimal_mark,
            n_inside = 1, inside_x = 2)
}

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "trade_export_germany_pie", category = "Trade", label = "Germany Export Structure (pie)", render = function() {
    DE <- file.path(OUT_DIR, "trade graphs/German labeling")
    EN <- file.path(OUT_DIR, "trade graphs/English labeling")
    yr <- as.integer(format(Sys.Date(), "%Y")) - 1
    render_graph(trade_export_germany_pie("Datenquelle: Statistisches Bundesamt (Destatis)"), paste0("Germany's Export Structure in ",
        yr, " pie_de"), DE, width = 9, height = 7, dpi = 400)
    render_graph(trade_export_germany_pie("Data source: Federal statistical office (Destatis)", big_mark = ",",
        decimal_mark = "."), paste0("Germany's Export Structure in ", yr, " pie_en"), EN, width = 9,
        height = 7, dpi = 400)
}),
list(id = "trade_import_germany_pie", category = "Trade", label = "Germany Import Structure (pie)", render = function() {
    DE <- file.path(OUT_DIR, "trade graphs/German labeling")
    EN <- file.path(OUT_DIR, "trade graphs/English labeling")
    yr <- as.integer(format(Sys.Date(), "%Y")) - 1
    render_graph(trade_import_germany_pie("Datenquelle: Statistisches Bundesamt (Destatis)"), paste0("Germany's Import Structure in ",
        yr, " pie_de"), DE, width = 9, height = 7, dpi = 400)
    render_graph(trade_import_germany_pie("Data source: Federal statistical office (Destatis)", big_mark = ",",
        decimal_mark = "."), paste0("Germany's Import Structure in ", yr, " pie_en"), EN, width = 9,
        height = 7, dpi = 400)
}),
list(id = "trade_export_hamburg_pie", category = "Trade", label = "Hamburg Export Structure (pie)", render = function() {
    DE <- file.path(OUT_DIR, "trade graphs/German labeling")
    EN <- file.path(OUT_DIR, "trade graphs/English labeling")
    yr <- as.integer(format(Sys.Date(), "%Y")) - 1
    render_graph(trade_export_hamburg_pie("Datenquelle: Statistisches Bundesamt (Destatis)"), paste0("Hamburg's Export Structure in ",
        yr, " pie_de"), DE, width = 9, height = 5.5, dpi = 400)
    render_graph(trade_export_hamburg_pie("Data source: Federal statistical office (Destatis)", big_mark = ",",
        decimal_mark = "."), paste0("Hamburg's Export Structure in ", yr, " pie_en"), EN, width = 9,
        height = 5.5, dpi = 400)
}),
list(id = "trade_import_hamburg_pie", category = "Trade", label = "Hamburg Import Structure (pie)", render = function() {
    DE <- file.path(OUT_DIR, "trade graphs/German labeling")
    EN <- file.path(OUT_DIR, "trade graphs/English labeling")
    yr <- as.integer(format(Sys.Date(), "%Y")) - 1
    render_graph(trade_import_hamburg_pie("Datenquelle: Statistisches Bundesamt (Destatis)"), paste0("Hamburg's Import Structure in ",
        yr, " pie_de"), DE, width = 9, height = 5.5, dpi = 400)
    render_graph(trade_import_hamburg_pie("Data source: Federal statistical office (Destatis)", big_mark = ",",
        decimal_mark = "."), paste0("Hamburg's Import Structure in ", yr, " pie_en"), EN, width = 9,
        height = 5.5, dpi = 400)
}),
list(id = "trade_export_lowersaxony_pie", category = "Trade", label = "Lower Saxony Export Structure (pie)",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        yr <- as.integer(format(Sys.Date(), "%Y")) - 1
        render_graph(trade_export_lowersaxony_pie("Datenquelle: Statistisches Bundesamt (Destatis)"),
            paste0("Lower Saxony's Export Structure in ", yr, " pie_de"), DE, width = 9, height = 5.5,
            dpi = 400)
        render_graph(trade_export_lowersaxony_pie("Data source: Federal statistical office (Destatis)",
            big_mark = ",", decimal_mark = "."), paste0("Lower Saxony's Export Structure in ", yr, " pie_en"),
            EN, width = 9, height = 5.5, dpi = 400)
    }),
list(id = "trade_import_lowersaxony_pie", category = "Trade", label = "Lower Saxony Import Structure (pie)",
    render = function() {
        DE <- file.path(OUT_DIR, "trade graphs/German labeling")
        EN <- file.path(OUT_DIR, "trade graphs/English labeling")
        yr <- as.integer(format(Sys.Date(), "%Y")) - 1
        render_graph(trade_import_lowersaxony_pie("Datenquelle: Statistisches Bundesamt (Destatis)"),
            paste0("Lower Saxony's Import Structure in ", yr, " pie_de"), DE, width = 9, height = 5.5,
            dpi = 400)
        render_graph(trade_import_lowersaxony_pie("Data source: Federal statistical office (Destatis)",
            big_mark = ",", decimal_mark = "."), paste0("Lower Saxony's Import Structure in ", yr, " pie_en"),
            EN, width = 9, height = 5.5, dpi = 400)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/trade/trade_state_pies.R", .graph_specs)
