# Dual Y-axis: employed (left, Mio.) and registered unemployed (right, Mio.), annual.
# Sources: Erwerbstätige from 81000-0015 (ETR/VGR, Inlandskonzept);
#          Arbeitslose from 13211-0001 (BA registered, Insgesamt).
# The complete 1991 archives are reused; displayed history follows DATA_START_MONTH.
ger_employed_unemployed <- function(caption,
                                     label_employed   = "Erwerbstätige",
                                     label_unemployed = "Arbeitslose",
                                     y_axis_left      = "Erwerbstätige (in Mio.)",
                                     y_axis_right     = "Arbeitslose (in Mio.)",
                                     decimal_mark     = ",",
                                     big_mark         = ".") {
  raw_emp   <- with_cache("genesis_81000-0015_1991",
                           genesis_fetch("81000-0015", start_month = 1991))
  raw_unemp <- with_cache("genesis_13211-0001", genesis_fetch("13211-0001"))
  employed <- parse_genesis(raw_emp,
                             value_var     = "ERW063",
                             class_filters = list("2_variable_attribute_code" = NA_character_),
                             series_name   = label_employed,
                             geo           = "DEU",
                             scale         = 1 / 1e3) |>
    dplyr::filter(date >= as.Date(paste0(DATA_START_MONTH, "-01")))
  unemployed <- parse_genesis(raw_unemp,
                               value_var     = "ERW006",
                               class_filters = list("1_variable_attribute_code" = NA_character_),
                               series_name   = label_unemployed,
                               geo           = "DEU",
                               scale         = 1 / 1e6) |>
    dplyr::filter(date >= as.Date(paste0(DATA_START_MONTH, "-01")))
  dat <- dplyr::bind_rows(employed, unemployed)
  plot_dual_axis(dat, caption = caption,
                  y_axis_left  = y_axis_left,
                  y_axis_right = y_axis_right,
                  series_left  = label_employed,
                  series_right = label_unemployed,
                  decimal_mark = decimal_mark,
                  big_mark     = big_mark,
                  x_breaks     = "5 years")
}

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "ger_employed_unemployed", category = "Employment", label = "Germany Employed and Unemployed Persons",
    render = function() {
        GER <- file.path(OUT_DIR, "employment graphs/German labeling")
        EN <- file.path(OUT_DIR, "employment graphs/English labeling")
        render_graph(ger_employed_unemployed(caption = "Datenquelle: Statistisches Bundesamt (Destatis)",
            label_employed = "Erwerbstätige", label_unemployed = "Erwerbslose", y_axis_left = "Erwerbstätige (in Mio.)",
            y_axis_right = "Erwerbslose (in Mio.)", decimal_mark = ",", big_mark = "."), "GER employed unemployed_ger",
            GER)
        render_graph(ger_employed_unemployed(caption = "Data source: Federal statistical office (Destatis)",
            label_employed = "Employed", label_unemployed = "Unemployed", y_axis_left = "Employed (in million)",
            y_axis_right = "Unemployed (in million)", decimal_mark = ".", big_mark = ","), "GER employed unemployed_en",
            EN)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/employment/ger_employed_unemployed.R", .graph_specs)
