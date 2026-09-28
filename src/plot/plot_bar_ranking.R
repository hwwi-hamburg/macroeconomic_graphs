plot_bar_ranking <- function(dat, source, x_axis = "",
                              decimal_mark = ".", big_mark = ",",
                              color = blue, year = NULL) {
  dat$geo <- factor(dat$geo, levels = rev(unique(dat$geo)))
  ggplot2::ggplot(dat, ggplot2::aes(x = value, y = geo)) +
    ggplot2::geom_col(fill = color) +
    ggplot2::scale_x_continuous(
      labels = function(x) format(x, big.mark = big_mark,
                                   decimal.mark = decimal_mark, scientific = FALSE)
    ) +
    ggplot2::labs(x = x_axis, y = "", caption = paste0(source, " ", year %||% format(Sys.Date(), "%Y"))) +
    theme_hwwi()
}
