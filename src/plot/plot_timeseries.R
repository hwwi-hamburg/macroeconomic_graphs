plot_timeseries <- function(dat, y_axis, source,
                             decimal_mark = ".", big_mark = ",",
                             color = blue, x_breaks = "5 years",
                             y_limits = NULL, y_breaks = ggplot2::waiver(),
                             linewidth = 1.8,
                             angle = 0,
                             year = NULL) {
  ggplot2::ggplot(dat, ggplot2::aes(x = date, y = value)) +
    ggplot2::geom_line(linewidth = linewidth, color = color) +
    ggplot2::scale_x_date(date_breaks = x_breaks, date_labels = "%Y") +
    ggplot2::scale_y_continuous(
      limits = y_limits, breaks = y_breaks,
      labels = function(x) format(x, big.mark = big_mark,
                                   decimal.mark = decimal_mark, scientific = FALSE)
    ) +
    ggplot2::labs(x = "", y = y_axis, caption = paste0(source, " ", year %||% format(Sys.Date(), "%Y"))) +
    theme_hwwi() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = angle, hjust = 0.5))
}

# Grouped bar chart with a date x-axis. Uses position="identity" so bars overlap:
# the first factor level is drawn behind, the second on top. Caller should set
# factor levels so the larger-value series comes first (drawn behind the shorter).
plot_bar_date <- function(dat, y_axis, source, labels = NULL,
                           decimal_mark = ".", big_mark = ",",
                           colors = c(scales::alpha(blue, 0.6), rubin),
                           x_breaks = "2 years", y_limits = NULL,
                          angle = 0, year = NULL) {
  ggplot2::ggplot(dat, ggplot2::aes(x = date, y = value, fill = series)) +
    ggplot2::geom_col(position = "identity") +
    ggplot2::scale_fill_manual(values = colors,
                                labels = if (!is.null(labels)) labels else ggplot2::waiver()) +
    ggplot2::scale_x_date(date_breaks = x_breaks, date_labels = "%Y") +
    ggplot2::scale_y_continuous(
      limits = y_limits,
      labels = function(x) format(x, big.mark = big_mark,
                                   decimal.mark = decimal_mark, scientific = FALSE)
    ) +
    ggplot2::labs(x = "", y = y_axis, fill = "",
                  caption = paste0(source, " ", year %||% format(Sys.Date(), "%Y"))) +
    theme_hwwi() +
    ggplot2::theme(legend.position = "bottom",
                   axis.text.x = ggplot2::element_text(angle = angle, hjust = 0.5))
}

plot_timeseries_multi <- function(dat, y_axis, source, labels = NULL,
                                   decimal_mark = ".", big_mark = ",",
                                   colors = hwwi_palette, x_breaks = "5 years",
                                   y_limits = NULL, linewidth = 1.8, angle = 0,
                                   year = NULL) {
  ggplot2::ggplot(dat, ggplot2::aes(x = date, y = value, color = series)) +
    ggplot2::geom_line(linewidth = linewidth) +
    ggplot2::scale_color_manual(values = colors,
                                 labels = if (!is.null(labels)) labels else ggplot2::waiver()) +
    ggplot2::scale_x_date(date_breaks = x_breaks, date_labels = "%Y") +
    ggplot2::scale_y_continuous(
      limits = y_limits,
      labels = function(x) format(x, big.mark = big_mark,
                                   decimal.mark = decimal_mark, scientific = FALSE)
    ) +
    ggplot2::labs(x = "", y = y_axis, color = "", caption = paste0(source, " ", year %||% format(Sys.Date(), "%Y"))) +
    theme_hwwi() +
    ggplot2::theme(legend.position = "bottom", 
  axis.text.x = ggplot2::element_text(angle = angle, hjust = 0.5))
}
