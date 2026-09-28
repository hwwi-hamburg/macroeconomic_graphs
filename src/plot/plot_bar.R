# Single-series annual bar chart for growth rate data.
# Adds bold % text labels, 1% y-axis breaks, 2-year x-axis breaks.
plot_bar_growth <- function(dat, y_axis, source, decimal_mark = ".",
                             color = blue, x_breaks = "2 years", year = NULL) {
  y_min <- floor(min(dat$value, na.rm = TRUE))
  y_max <- ceiling(max(dat$value, na.rm = TRUE))
  ggplot2::ggplot(dat, ggplot2::aes(x = date, y = value)) +
    ggplot2::geom_col(fill = color) +
    ggplot2::geom_text(
      ggplot2::aes(
        label = paste0(formatC(value, format = "f", digits = 1, decimal.mark = decimal_mark), "%"),
        vjust = ifelse(value >= 0, -0.5, 1.5)
      ),
      size = 3, fontface = "bold", color = "black"
    ) +
    ggplot2::scale_x_date(date_breaks = x_breaks, date_labels = "%Y") +
    ggplot2::scale_y_continuous(
      breaks = seq(y_min, y_max, by = 1),
      labels = function(x) paste0(format(x, decimal.mark = decimal_mark, scientific = FALSE), "%")
    ) +
    ggplot2::labs(x = "", y = y_axis, caption = paste0(source, " ", year %||% format(Sys.Date(), "%Y"))) +
    theme_hwwi()
}

plot_bar <- function(dat, y_axis, source, labels = NULL,
                      decimal_mark = ".",
                      colors = c(alpha(blue, 0.9), alpha(rubin, 0.9)),
                      y_limits = NULL, position = "dodge", year = NULL) {
  ggplot2::ggplot(dat, ggplot2::aes(
    x = date,
    y = value,
    fill = series
  )) +
    ggplot2::geom_bar(stat = "identity", position = position) +
    ggplot2::scale_fill_manual(
      values = colors,
      labels = if (!is.null(labels)) labels else ggplot2::waiver(),
      guide  = ggplot2::guide_legend(title = "")
    ) +
    ggplot2::scale_x_date(
      breaks = sort(unique(dat$date)),
      date_labels = "%Y"
    ) +
    ggplot2::scale_y_continuous(
      limits = y_limits,
      labels = function(x) format(x, decimal.mark = decimal_mark, scientific = FALSE)
    ) +
    ggplot2::labs(x = "", y = y_axis, caption = paste0(source, " ", year %||% format(Sys.Date(), "%Y"))) +
    theme_hwwi() +
    ggplot2::theme(legend.position = "bottom",
                   axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
}
