# Annual registered unemployed (Arbeitslose), West vs East Germany.
# Table 13211-0001 (annual). Geographic codes in 1_variable_attribute_code:
#   DF = Früheres Bundesgebiet (West), DN = Neue Länder (East).
# If parse fails: unique(raw[["1_variable_attribute_code"]])
ger_unemployed_west_east <- function(y_axis, source, labels = NULL,
                                      decimal_mark = ",", big_mark = ".") {
  raw <- with_cache("genesis_13211-0001",
                    genesis_fetch("13211-0001"))
  west <- parse_genesis(raw,
                         value_var     = "ERW006",
                         class_filters = list("1_variable_attribute_code" = "DF"),
                         series_name   = "West",
                         geo           = "DEU-W",
                         scale         = 1 / 1e6) |>
    dplyr::filter(date >= as.Date(paste0(DATA_START_MONTH, "-01")))
  east <- parse_genesis(raw,
                         value_var     = "ERW006",
                         class_filters = list("1_variable_attribute_code" = "DN"),
                         series_name   = "East",
                         geo           = "DEU-E",
                         scale         = 1 / 1e6) |>
    dplyr::filter(date >= as.Date(paste0(DATA_START_MONTH, "-01")))
  dat <- dplyr::bind_rows(west, east)
  plot_timeseries_multi(dat, y_axis = y_axis, source = source,
                         labels = labels,
                         colors = c(hwwi_rubin, hwwi_blue),
                         decimal_mark = decimal_mark, big_mark = big_mark,
                         x_breaks = "2 years")
}

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "ger_unemployed_west_east", category = "Employment", label = "Germany Registered Unemployed: West vs East",
    notes = "Registered unemployed, annual averages. West: former federal territory; East: new Länder (Destatis classification). GENESIS 13211-0001.",
    render = function() {
        DE <- file.path(OUT_DIR, "employment graphs/German labeling")
        EN <- file.path(OUT_DIR, "employment graphs/English labeling")
        render_graph(ger_unemployed_west_east("Arbeitslose (in Mio.)", "Datenquelle: Statistisches Bundesamt (Destatis)",
            labels = c("Früheres Bundesgebiet", "Neue Länder"), decimal_mark = ",", big_mark = "."),
            "GER unemployed west east_de", DE)
        render_graph(ger_unemployed_west_east("Unemployed in Mill.", "Data source: Federal statistical office (Destatis)",
            labels = c("West Germany", "East Germany"), decimal_mark = ".", big_mark = ","), "GER unemployed west east_en",
            EN)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/employment/ger_unemployed_west_east.R", .graph_specs)
