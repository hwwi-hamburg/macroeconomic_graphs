# Nominal GDP (Mrd. EUR) for German Bundesländer - bar chart, latest available year.
# GENESIS 82111-0010, BIP006 (GDP at current prices, Mill. EUR). Sorted alphabetically.
ger_nominal_gdp_state <- function(y_axis, source, decimal_mark = ",", big_mark = ".") {
  raw <- with_cache("genesis_82111-0010",
                    genesis_fetch("82111-0010"))
  dat <- raw[!is.na(raw$value_variable_code) & raw$value_variable_code == "BIP006" &
               !is.na(raw$value) & !raw$value %in% c("-", "/", ".", "", "..."), , drop = FALSE]
  yr  <- max(as.integer(dat$time), na.rm = TRUE)
  dat <- dat[dat$time == as.character(yr), , drop = FALSE]
  geo   <- dat[["1_variable_attribute_label"]]
  value <- as.numeric(gsub(",", ".", dat$value)) / 1e3   # Mill. EUR → Mrd. EUR
  df  <- data.frame(geo = geo, value = value, stringsAsFactors = FALSE)
  df  <- df[!is.na(df$value) & !is.na(df$geo), ]
  df  <- df[order(df$geo), ]
  y_high <- ceiling(max(df$value, na.rm = TRUE) / 100) * 100
  ggplot2::ggplot(df, ggplot2::aes(x = factor(geo, levels = df$geo), y = value)) +
    ggplot2::geom_col(fill = hwwi_blue, width = 0.8) +
    ggplot2::scale_y_continuous(
      limits = c(0, y_high),
      labels = function(x) format(x, big.mark = big_mark,
                                   decimal.mark = decimal_mark, scientific = FALSE)
    ) +
    ggplot2::labs(x = "", y = wrap_axis_label(y_axis), caption = source) +
    theme_hwwi() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, vjust = 0.5, hjust = 1))
}

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "ger_nominal_gdp_state", category = "GDP", label = "Germany Nominal GDP by State - Bar Chart (Destatis)",
    render = function() {
        DE <- file.path(OUT_DIR, "GDP graphs/German labeling")
        EN <- file.path(OUT_DIR, "GDP graphs/English labeling")
        render_graph(ger_nominal_gdp_state("Nominales BIP (in Mrd. EUR)", "Datenquelle: Statistisches Bundesamt (Destatis)",
            decimal_mark = ",", big_mark = "."), "GER BIP nominal by state_de", DE, height = 7)
        render_graph(ger_nominal_gdp_state("Nominal GDP (in Billion EUR)", "Data source: Federal statistical office (Destatis)",
            decimal_mark = ".", big_mark = ","), "GER BIP nominal by state_en", EN, height = 7)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/gdp/ger_nominal_gdp_state.R", .graph_specs)
