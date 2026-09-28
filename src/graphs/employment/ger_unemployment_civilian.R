# Two annual unemployment rates from table 13211-0001 (Insgesamt):
#   ERW112 = Arbeitslosenquote aller zivilen Erwerbspersonen (all civilian)
#   ERW113 = Arbeitslosenquote abhängiger ziviler Erwerbspersonen (dependent civilian)
# If variable codes are wrong, inspect:
#   unique(with_cache("genesis_13211-0001_raw", genesis_fetch("13211-0001"))$value_variable_code)
ger_unemployment_civilian <- function(y_axis, source,
                                       label_all, label_dep,
                                       decimal_mark = ",") {
  raw <- with_cache("genesis_13211-0001",
                    genesis_fetch("13211-0001"))
  rate_all <- parse_genesis(raw,
                              value_var     = "ERW112",
                              class_filters = list("1_variable_attribute_code" = NA_character_),
                              series_name   = label_all,
                              geo           = "DEU") |>
    dplyr::filter(date >= as.Date(paste0(DATA_START_MONTH, "-01")))
  rate_dep <- parse_genesis(raw,
                              value_var     = "ERW116",
                              class_filters = list("1_variable_attribute_code" = NA_character_),
                              series_name   = label_dep,
                              geo           = "DEU") |>
    dplyr::filter(date >= as.Date(paste0(DATA_START_MONTH, "-01")))
  dat <- dplyr::bind_rows(rate_all, rate_dep)
  plot_timeseries_multi(dat, y_axis = y_axis, source = source,
                         colors = c(rubin, blue),
                         decimal_mark = decimal_mark,
                         x_breaks = "2 years")
}

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "ger_unemployment_civilian", category = "Employment", label = "Germany Unemployment Rate: Civilian and Registered (annual)",
    render = function() {
        DE <- file.path(OUT_DIR, "employment graphs/German labeling")
        EN <- file.path(OUT_DIR, "employment graphs/English labeling")
        render_graph(ger_unemployment_civilian(y_axis = "Arbeitslosenquote in %", source = "Datenquelle: Statistisches Bundesamt (Destatis)",
            label_all = "Arbeitslosenquote aller ziv. Erwerbspersonen", label_dep = "Arbeitslosenquote abh. ziv. Erwerbspersonen",
            decimal_mark = ","), "GER unemployment rate civilian and registered_de", DE)
        render_graph(ger_unemployment_civilian(y_axis = "Unemployment rate in %", source = "Data source: Federal statistical office (Destatis)",
            label_all = "Unemployment as percent of civilian labour force", label_dep = "Rate of registered unemployed",
            decimal_mark = "."), "GER unemployment rate civilian and registered_en", EN)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/employment/ger_unemployment_civilian.R", .graph_specs)
