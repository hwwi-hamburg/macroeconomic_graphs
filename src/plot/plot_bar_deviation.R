plot_bar_deviation <- function(dat, caption,
                                x_axis          = "",
                                decimal_mark    = ".",
                                big_mark        = ",",
                                positive_label  = "Above average",
                                negative_label  = "Below average",
                                colors          = c(blue, rubin)) {
  dat <- dat[order(dat$value), ]
  dat$series <- factor(dat$series, levels = unique(dat$series))
  dat$direction <- ifelse(dat$value >= 0, positive_label, negative_label)
  dat$direction <- factor(dat$direction, levels = c(positive_label, negative_label))

  ggplot2::ggplot(dat, ggplot2::aes(x = value,
                                     y = series,
                                     fill = direction)) +
    ggplot2::geom_col() +
    ggplot2::geom_vline(xintercept = 0, linewidth = 0.5, color = "grey40") +
    ggplot2::scale_fill_manual(
      values = setNames(colors, c(positive_label, negative_label)),
      guide  = ggplot2::guide_legend(title = "")
    ) +
    ggplot2::scale_x_continuous(
      labels = function(x) format(x, big.mark = big_mark,
                                   decimal.mark = decimal_mark, scientific = FALSE)
    ) +
    ggplot2::labs(x = x_axis, y = "", caption = paste0(caption, " ", format(Sys.Date(), "%Y"))) +
    theme_hwwi() +
    ggplot2::theme(legend.position = "bottom")
}
