gdp_world_by_region_growth <- function(y_axis, caption, labels = NULL,
                                        decimal_mark = ".", n_years = 3) {
  dat <- with_cache(paste0("wdi_NY.GDP.PCAP.KD.ZG_regions_", DATA_START_YEAR),
                    fetch_wdi("NY.GDP.PCAP.KD.ZG", country = REGION_CODES))
  region_labels <- if (!is.null(labels)) setNames(labels, REGION_ISO3C) else NULL

  recent_years <- tail(sort(unique(dat$date[!is.na(dat$value)])), n_years)

  bar_dat <- dat |>
    dplyr::filter(date %in% recent_years, !is.na(value)) |>
    dplyr::mutate(
      label = if (!is.null(region_labels)) dplyr::coalesce(region_labels[geo], series) else series,
      year  = factor(as.integer(format(date, "%Y")))
    )

  year_levels <- levels(bar_dat$year)
  bar_colors  <- setNames(
    c(blue, rubin, grey)[seq_along(year_levels)],
    year_levels
  )

  y_min <- floor(min(bar_dat$value, na.rm = TRUE))
  y_max <- ceiling(max(bar_dat$value, na.rm = TRUE))

  ggplot2::ggplot(bar_dat, ggplot2::aes(
    x    = label,
    y    = value,
    fill = year
  )) +
    ggplot2::geom_col(position = ggplot2::position_dodge(width = 0.9), width = 0.8) +
    ggplot2::geom_text(
      ggplot2::aes(
        label = paste0(format(round(value, 1), decimal.mark = decimal_mark, nsmall = 1), "%"),
        vjust = ifelse(value >= 0, -0.5, 1.5)
      ),
      position = ggplot2::position_dodge(width = 0.9),
      size = 3,
      fontface = "bold",
      color = "black"
    ) +
    ggplot2::scale_fill_manual(
      values = bar_colors,
      guide  = ggplot2::guide_legend(title = "")
    ) +
    ggplot2::scale_x_discrete(
      labels = function(x) stringr::str_wrap(x, width = 16)
    ) +
    ggplot2::scale_y_continuous(
      breaks = seq(y_min, y_max, by = 1),
      labels = function(x) paste0(format(x, decimal.mark = decimal_mark, scientific = FALSE), "%")
    ) +
    ggplot2::labs(x = "", y = y_axis, caption = caption) +
    theme_hwwi() +
    ggplot2::theme(
      legend.position = "bottom",
      axis.text.x = ggplot2::element_text(
        size = 10,
        lineheight = 0.9,
        margin = ggplot2::margin(t = 8)
      )
    )
}

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "world_gdp_by_region_growth", category = "GDP", label = "World GDP Per Capita Growth by Region",
    render = function() {
        GER <- file.path(OUT_DIR, "GDP graphs/German labeling")
        EN <- file.path(OUT_DIR, "GDP graphs/English labeling")
        render_graph(gdp_world_by_region_growth("BIP pro Kopf Wachstum (in %)", "Datenquelle: Nationale Statistik der Weltbank und OECD",
            labels = c("Ostasien und Pazifik", "Europa & Zentralasien", "Lateinamerika & Karibik", "Naher Osten & Nordafrika",
                "Nordamerika", "Südasien", "Sub-Sahara Afrika"), decimal_mark = ","), "W GDP p.c. real annual Growth World Regions_ger",
            GER)
        render_graph(gdp_world_by_region_growth("GDP Per Capita Growth (in %)", "Data Source: World Bank National Accounts Data, and OECD National Accounts Data Files",
            labels = c("East Asia & Pacific", "Europe & Central Asia", "Latin America & Caribbean", "Middle East & North Africa",
                "North America", "South Asia", "Sub-Saharan Africa")), "W GDP p.c. real annual Growth World Regions_en",
            EN)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/gdp/world_gdp_by_region_growth.R", .graph_specs)
