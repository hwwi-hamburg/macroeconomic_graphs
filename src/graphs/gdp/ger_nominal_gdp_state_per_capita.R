# Nominal GDP per capita for German Bundesländer — bar chart and choropleth map.
# Source: Statistische Ämter des Bundes und der Länder (local CSV, not fetched
# live — update the file and .GDP_STATE_PER_CAPITA_CSV below together when a
# newer vintage becomes available).
.GDP_STATE_PER_CAPITA_CSV <- file.path("data", "wirtschaftsleistung-bundeslaender-2024.csv")

# The source year always reflects this file's actual vintage, not today's
# date, since the data doesn't move with time the way a live fetch would.
.gdp_state_per_capita_year <- function(csv_path = .GDP_STATE_PER_CAPITA_CSV) {
  as.integer(sub(".*-([0-9]{4})\\.csv$", "\\1", basename(csv_path)))
}

.read_gdp_state_per_capita <- function(csv_path = .GDP_STATE_PER_CAPITA_CSV) {
  if (!file.exists(csv_path)) stop("Missing repository data file: ", csv_path)
  raw <- utils::read.csv2(csv_path, fileEncoding = "UTF-8-BOM", stringsAsFactors = FALSE)
  colnames(raw) <- c("geo", "value")
  exclude <- c("Westliche Bundesländer", "Östliche Bundesländer", "Deutschland")
  dat <- raw[!raw$geo %in% exclude, , drop = FALSE]
  dat$value <- as.numeric(dat$value)
  dat[!is.na(dat$value) & !is.na(dat$geo), ]
}

ger_nominal_gdp_state_per_capita <- function(y_axis, source,
                                              decimal_mark = ",", big_mark = ".",
                                              year = .gdp_state_per_capita_year()) {
  dat    <- .read_gdp_state_per_capita()
  dat    <- dat[order(dat$value, decreasing = TRUE), ]
  y_high <- ceiling(max(dat$value, na.rm = TRUE) / 10000) * 10000
  ggplot2::ggplot(dat, ggplot2::aes(x = factor(geo, levels = dat$geo), y = value)) +
    ggplot2::geom_col(fill = hwwi_blue, width = 0.8) +
    ggplot2::scale_y_continuous(
      limits = c(0, y_high),
      breaks = seq(0, y_high, by = 10000),
      labels = function(x) format(x, big.mark = big_mark,
                                   decimal.mark = decimal_mark, scientific = FALSE)
    ) +
    ggplot2::labs(x = "", y = wrap_axis_label(y_axis), caption = paste0(source, " ", year)) +
    theme_hwwi() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, vjust = 0.5, hjust = 1))
}

ger_nominal_gdp_state_per_capita_map <- function(legend_title, source,
                                                  year = .gdp_state_per_capita_year()) {
  dat <- .read_gdp_state_per_capita()
  plot_choropleth_ger(dat, fill_col = "value",
                      legend_title = legend_title, source = source,
                      low = "white", high = hwwi_rubin, year = year)
}

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "ger_nominal_gdp_state_per_capita", category = "GDP", label = "Germany Nominal GDP per Capita by State (StatLA)",
    render = function() {
        DE <- file.path(OUT_DIR, "GDP graphs/German labeling")
        EN <- file.path(OUT_DIR, "GDP graphs/English labeling")
        render_graph(ger_nominal_gdp_state_per_capita("Nominales BIP pro Einwohner (in EUR)", "Datenquelle: Statistische Ämter des Bundes und der Länder",
            decimal_mark = ",", big_mark = "."), "GER Nominal GDP by State per Capita_de", DE, height = 7)
        render_graph(ger_nominal_gdp_state_per_capita("Nominal GDP per Capita (in EUR)", "Data source: Federal and State Statistical Offices",
            decimal_mark = ".", big_mark = ","), "GER Nominal GDP by State per Capita_en", EN, height = 7)
    }),
list(id = "ger_nominal_gdp_state_per_capita_map", category = "GDP", label = "Germany Nominal GDP per Capita by State - Choropleth (StatLA)",
    render = function() {
        DE <- file.path(OUT_DIR, "GDP graphs/German labeling")
        EN <- file.path(OUT_DIR, "GDP graphs/English labeling")
        render_graph(ger_nominal_gdp_state_per_capita_map("Nominales BIP pro Einwohner (in EUR)", "Datenquelle: Statistische Ämter des Bundes und der Länder"),
            "GER Nominal GDP by State per Capita Map_de", DE)
        render_graph(ger_nominal_gdp_state_per_capita_map("Nominal GDP per Capita (in EUR)", "Data source: Federal and State Statistical Offices"),
            "GER Nominal GDP by State per Capita Map_en", EN)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/gdp/ger_nominal_gdp_state_per_capita.R", .graph_specs)
