plot_dual_axis <- function(dat, caption,
                            y_axis_left, y_axis_right,
                            series_left, series_right,
                            decimal_mark = ".", big_mark = ",",
                            colors = c(blue, rubin),
                            x_breaks = "5 years",
                            y_max_right = NULL,
                            y_min_at_zero = TRUE,
                            angle = 0) {
  left  <- dat[dat$series == series_left,  ]
  right <- dat[dat$series == series_right, ]

  left_max  <- max(left$value,  na.rm = TRUE) * 1.05
  right_max <- if (!is.null(y_max_right)) y_max_right else max(right$value, na.rm = TRUE) * 1.05

  if (y_min_at_zero) {
    L_lo <- 0
    R_lo <- 0
  } else {
    L_lo <- min(left$value,  na.rm = TRUE) * 0.97
    R_lo <- min(right$value, na.rm = TRUE) * 0.97
  }

  # Affine map: right → left coordinate space
  # Solves: a * R_lo + b = L_lo  and  a * right_max + b = left_max
  a <- (left_max - L_lo) / (right_max - R_lo)
  b <- L_lo - a * R_lo

  combined <- dplyr::bind_rows(
    dplyr::mutate(left,  value_plot = value),
    dplyr::mutate(right, value_plot = a * value + b)
  )
  combined$series <- factor(combined$series, levels = c(series_left, series_right))

  ggplot2::ggplot(combined, ggplot2::aes(x = date, y = value_plot, color = series)) +
    ggplot2::geom_line(linewidth = 1.8) +
    ggplot2::scale_color_manual(
      values = setNames(colors, c(series_left, series_right)),
      guide  = ggplot2::guide_legend(title = "")
    ) +
    ggplot2::scale_x_date(date_breaks = x_breaks, date_labels = "%Y") +
    ggplot2::scale_y_continuous(
      name   = y_axis_left,
      limits = c(L_lo, left_max),
      labels = function(x) format(x, big.mark = big_mark,
                                   decimal.mark = decimal_mark, scientific = FALSE),
      sec.axis = ggplot2::sec_axis(
        transform = ~ (. - b) / a,
        name = y_axis_right,
        labels = function(x) format(x, big.mark = big_mark,
                                     decimal.mark = decimal_mark, scientific = FALSE)
      )
    ) +
    ggplot2::labs(x = "", caption = paste0(caption, " ", format(Sys.Date(), "%Y"))) +
    theme_hwwi() +
    ggplot2::theme(
      legend.position  = "bottom",
      axis.title.y     = ggplot2::element_text(color = colors[1]),
      axis.title.y.right = ggplot2::element_text(color = colors[2]),
      axis.text.x = ggplot2::element_text(angle = angle, hjust = 0.5)
    )
}
