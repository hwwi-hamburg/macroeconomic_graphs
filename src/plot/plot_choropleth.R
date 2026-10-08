.choropleth_world_theme <- function() {
  ggplot2::theme(
    legend.position      = "bottom",
    legend.justification = "center",
    legend.direction     = "horizontal",
    legend.key.height    = grid::unit(0.45, "cm"),
    legend.text          = ggplot2::element_text(size = 9),
    legend.title         = ggplot2::element_text(size = 10, colour = hwwi_dark_grey, face = "bold"),
    legend.background    = ggplot2::element_blank(),
    plot.caption         = ggplot2::element_text(hjust = 0, margin = ggplot2::margin(t = 10))
  )
}

plot_choropleth_world <- function(dat, fill_col = "value", legend_title = "",
                                   source = "", low = "white", high = hwwi_blue,
                                   xlim = c(-179, 179), ylim = c(-56, 85), year = NULL) {
  # Some GENESIS country tables include a monetary observation and a tiny
  # auxiliary observation under the same country code. Choropleths need one
  # non-negative trade value per country; retain the monetary (largest) value.
  map_dat <- dat |>
    dplyr::filter(!is.na(geo), is.finite(.data[[fill_col]]), .data[[fill_col]] >= 0) |>
    dplyr::group_by(geo) |>
    dplyr::summarise(.map_value = max(.data[[fill_col]]), .groups = "drop")

  world  <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")
  dat_sf <- dplyr::left_join(world, map_dat, by = c("iso_a3_eh" = "geo")) |> sf::st_as_sf()
  fill_max <- max(map_dat$.map_value, na.rm = TRUE)

  ggplot2::ggplot() +
    ggplot2::geom_sf(data = dat_sf, ggplot2::aes(fill = .map_value),
                     na.rm = TRUE, colour = NA) +
    ggplot2::geom_sf(data = world, fill = NA, linewidth = 0.2, colour = "grey70") +
    ggplot2::scale_fill_gradient(low = low, high = high, na.value = "grey88",
                                  trans = "sqrt", limits = c(0, fill_max),
                                  breaks = scales::breaks_pretty(n = 4),
                                  guide = ggplot2::guide_colorbar(
                                    direction = "horizontal",
                                    title.position = "top",
                                    barwidth = grid::unit(10, "cm"),
                                    barheight = grid::unit(0.45, "cm")
                                  )) +
    ggplot2::coord_sf(xlim = xlim, ylim = ylim, expand = FALSE) +
    ggplot2::labs(fill = legend_title, caption = paste0(source, " ", year %||% format(Sys.Date(), "%Y"))) +
    theme_hwwi(no_axes = TRUE) +
    .choropleth_world_theme()
}

plot_choropleth_world_div <- function(dat, fill_col = "value", legend_title = "",
                                       source = "", xlim = c(-179, 179), ylim = c(-56, 85),
                                       year = NULL) {
  world   <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")
  dat_sf  <- dplyr::left_join(world, dat, by = c("iso_a3_eh" = "geo")) |> sf::st_as_sf()
  abs_max <- max(abs(dat[[fill_col]]), na.rm = TRUE)

  ggplot2::ggplot() +
    ggplot2::geom_sf(data = dat_sf, ggplot2::aes(fill = .data[[fill_col]]),
                     na.rm = TRUE, colour = NA) +
    ggplot2::geom_sf(data = world, fill = NA, linewidth = 0.2, colour = "grey70") +
    ggplot2::scale_fill_gradient2(low = hwwi_rubin, mid = "white", high = hwwi_blue,
                                   midpoint = 0, na.value = "grey88",
                                   limits = c(-abs_max, abs_max),
                                   breaks = scales::breaks_pretty(n = 4),
                                   guide = ggplot2::guide_colorbar(
                                     direction = "horizontal",
                                     title.position = "top",
                                     barwidth = grid::unit(10, "cm"),
                                     barheight = grid::unit(0.45, "cm")
                                   )) +
    ggplot2::coord_sf(xlim = xlim, ylim = ylim, expand = FALSE) +
    ggplot2::labs(fill = legend_title, caption = paste0(source, " ", year %||% format(Sys.Date(), "%Y"))) +
    theme_hwwi(no_axes = TRUE) +
    .choropleth_world_theme()
}

plot_choropleth_ger <- function(dat, fill_col = "value", legend_title = "",
                                  source = "", low = hwwi_rubin, high = hwwi_dark_rubin, year = NULL) {
  states     <- rnaturalearth::ne_states(country = "germany", returnclass = "sf")
  lbl_pts    <- sf::st_point_on_surface(states)
  dat_sf     <- dplyr::left_join(dat, states[, c("name", "geometry")],
                                  by = c("geo" = "name")) |> sf::st_as_sf()
  fill_min   <- min(dat[[fill_col]], na.rm = TRUE)
  fill_max   <- max(dat[[fill_col]], na.rm = TRUE)

  ggplot2::ggplot() +
    ggplot2::geom_sf(data = dat_sf, ggplot2::aes(fill = .data[[fill_col]]),
                     na.rm = TRUE, colour = NA) +
    ggplot2::geom_sf(data = states, fill = NA, linewidth = 0.2) +
    ggrepel::geom_label_repel(
      data = lbl_pts,
      ggplot2::aes(x = sf::st_coordinates(lbl_pts)[, 1],
                   y = sf::st_coordinates(lbl_pts)[, 2], label = name),
      fill = "white", color = "black", size = 3,
      box.padding = 0.3, segment.color = "grey50"
    ) +
    ggplot2::scale_fill_gradient(low = low, high = high, na.value = NA,
                                  limits = c(fill_min, fill_max)) +
    ggplot2::labs(fill = legend_title,
                  caption = paste0(source, " ", year %||% format(Sys.Date(), "%Y"))) +
    theme_hwwi(no_axes = TRUE) +
    ggplot2::theme(legend.position = "right",
                   legend.text  = ggplot2::element_text(size = 9),
                   legend.title = ggplot2::element_text(size = 12))
}
