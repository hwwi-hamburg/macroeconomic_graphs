# Dual-axis: short-time workers (Kurzarbeiter, left) and unemployment rate (right).
# Table 13211-0002. ERW064 = Kurzarbeiter (Anzahl → scale 1/1000 → Tsd.),
# ERW112 = Arbeitslosenquote (%). Both filtered to 2_variable_attribute_label = "Insgesamt".
ger_short_time_employment <- function(source,
                                       label_kurzarbeit  = "Kurzarbeiter",
                                       label_unemployment = "Arbeitslosenquote",
                                       y_axis_left       = "Kurzarbeiter (in Tsd.)",
                                       y_axis_right      = "Arbeitslosenquote in %",
                                       decimal_mark      = ",",
                                       y_max_right       = NULL) {
  raw <- with_cache("genesis_13211-0002",
                    genesis_fetch("13211-0002"))
  kurzarbeit <- parse_genesis(raw,
                               value_var     = "ERW064",
                               class_filters = list("2_variable_attribute_code" = NA),
                               series_name   = label_kurzarbeit,
                               geo           = "DEU",
                               scale         = 1 / 1000) |>
    dplyr::filter(date >= as.Date(paste0(DATA_START_MONTH, "-01")))
  unemployment <- parse_genesis(raw,
                                 value_var     = "ERW112",
                                 class_filters = list("2_variable_attribute_code" = NA),
                                 series_name   = label_unemployment,
                                 geo           = "DEU") |>
    dplyr::arrange(date) |>
    dplyr::filter(date >= as.Date(paste0(DATA_START_MONTH, "-01")))
  dat <- dplyr::bind_rows(kurzarbeit, unemployment)
  plot_dual_axis(dat, source = source,
                  y_axis_left  = y_axis_left,
                  y_axis_right = y_axis_right,
                  series_left  = label_kurzarbeit,
                  series_right = label_unemployment,
                  colors       = c(hwwi_rubin, hwwi_blue),
                  decimal_mark = decimal_mark,
                  y_max_right  = y_max_right)
}

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "employment_short_time", category = "Employment", label = "Germany Short-Time Work and Unemployment Rate",
    render = function() {
        DE <- file.path(OUT_DIR, "employment graphs/German labeling")
        EN <- file.path(OUT_DIR, "employment graphs/English labeling")
        render_graph(ger_short_time_employment("Datenquelle: Statistisches Bundesamt (Destatis)", label_kurzarbeit = "Kurzarbeiter",
            label_unemployment = "Arbeitslosenquote", y_axis_left = "Kurzarbeiter (in Tsd.)", y_axis_right = "Arbeitslosenquote in %",
            decimal_mark = ",", y_max_right = 15), "GER unemployed rate and short term employee_de",
            DE)
        render_graph(ger_short_time_employment("Data source: Federal statistical office (Destatis)",
            label_kurzarbeit = "Short-time workers", label_unemployment = "Unemployment rate", y_axis_left = "Short-time workers (in thousands)",
            y_axis_right = "Unemployment rate in %", decimal_mark = ".", y_max_right = 15), "GER unemployed rate and short term employee_en",
            EN)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/employment/ger_short_time_employment.R", .graph_specs)
