#------------------------------------------
# Title: HWWI Basic Graph Settings
# Purpose: Shared packages, colours, fonts, theme settings, and save helper
# Author: Ali Raza
# Date: March 2026
#------------------------------------------



#---------------------------- Packages -----------------------------------------

if (!require("pacman", quietly = TRUE)) install.packages("pacman")

pacman::p_load(
  tidyverse, purrr, sf, tidygeocoder, stringr, ggplot2, ggpubr,
  ggnewscale, extrafont, forcats, patchwork, countrycode, dplyr,
  janitor, knitr, readr, readxl, tidyr, writexl, grid, scales, rlang,
  WDI, jsonlite, xml2, rnaturalearth, ggrepel
)


#-------------------------- Font handling --------------------------------------

if (!("Verdana" %in% extrafont::fonts())) {
  suppressWarnings(extrafont::font_import(prompt = FALSE))
  suppressWarnings(extrafont::loadfonts(device = "win", quiet = TRUE))
}



#-------------------------- HWWI Color Setting ---------------------------------

light_blue <- "#B4CAE2"
blue       <- "#004F9F"
dark_blue  <- "#14387F"
rubin      <- "#B80E80"
dark_rubin <- "#810759"
grey       <- "#D0D0D0"
dark_grey  <- "#3C3C3C"

col6  <- colorRampPalette(c(dark_blue, grey, dark_rubin))(6)
col10 <- colorRampPalette(c(dark_blue, grey, dark_rubin))(10)
col7  <- colorRampPalette(c(dark_blue, light_blue, dark_rubin, rubin))(14)

hwwi_palette         <- c(blue, rubin, dark_blue, dark_rubin, light_blue, grey)
hwwi_palette_default <- hwwi_palette
hwwi_palette_blue    <- c(light_blue, blue, dark_blue)
hwwi_palette_rb      <- c(dark_blue, blue, light_blue, grey, rubin, dark_rubin)



#------------------------------ HWWI Theme -------------------------------------

theme_hwwi <- function(base_size = 12, base_family = "Verdana", grid = c("h", "hv"), no_axes = FALSE) {
  grid <- match.arg(grid)
  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      panel.grid.minor      = element_blank(),
      panel.grid.major.y    = element_line(colour = "grey85", linewidth = 0.4),
      panel.grid.major.x    = if (no_axes || grid == "h") element_blank() else element_line(colour = "grey85", linewidth = 0.4),
      axis.line.x           = if (no_axes) element_blank() else element_line(colour = "grey40", linewidth = 0.6),
      axis.line.y           = element_blank(),
      axis.ticks            = if (no_axes) element_blank() else element_blank(),
      axis.text.x           = if (no_axes) element_blank() else element_text(colour = dark_grey, face = "bold", margin = margin(t=8), size = base_size + 4),
      axis.text.y           = if (no_axes) element_blank() else element_text(colour = dark_grey, face = "bold", margin = margin(r=8), size = base_size + 4),
      axis.title.x          = if (no_axes) element_blank() else element_text(colour = dark_grey, face = "bold", margin = margin(t=12), size = base_size + 6),
      axis.title.y          = if (no_axes) element_blank() else element_text(colour = dark_grey, face = "bold", margin = margin(r=12), size = base_size + 6),
      legend.position       = "none",
      legend.title          = element_blank(),
      legend.text           = element_text(colour = dark_grey, face = "bold", size = base_size + 4),
      plot.caption.position = "plot",
      plot.caption          = element_text(hjust = 1, colour = dark_grey, size = base_size, margin = margin(t=15)),
      plot.title.position   = "plot",
      plot.title            = element_text(colour = dark_grey, face = "bold", size = base_size + 4),
      plot.subtitle         = element_text(colour = dark_grey, size = base_size)
    )
}

#horizontal bar charts - use with coord_flip()
theme_hwwi_flip <- function(base_size = 12, base_family = "Verdana") {
  theme_hwwi(base_size = base_size, base_family = base_family) %+replace%
    theme(
      panel.grid.major.y = element_blank(),
      panel.grid.major.x = element_line(colour = "grey85", linewidth = 0.4)
    )
}


#pie charts
theme_hwwi_pie <- function(base_size = 12, base_family = "Verdana") {
  theme_hwwi(base_size = base_size, base_family = base_family) %+replace%
    theme(
      panel.grid          = element_blank(), 
      axis.text.x         = element_blank(),
      axis.text.y         = element_blank(),
      axis.title.x        = element_blank(),
      axis.title.y        = element_blank(),
      axis.ticks          = element_blank(), 
      axis.line.y         = element_blank(),
      panel.border        = element_blank(), 
      plot.caption          = element_text(hjust = 0.5, colour = dark_grey, size = base_size - 1, margin = margin(t=15)),
      legend.position     = "bottom"
    )
}

#maps
theme_hwwi_map <- function(base_size = 12, base_family = "Verdana") {
  theme_hwwi(base_size = base_size, base_family = base_family) %+replace%
    theme(
      panel.grid          = element_blank(),
      axis.text.x         = element_blank(),
      axis.text.y         = element_blank(),
      axis.title.x        = element_blank(),
      axis.title.y        = element_blank(),
      axis.ticks          = element_blank(), 
      axis.line.y         = element_blank(),
      plot.caption          = element_text(hjust = 0.5, colour = dark_grey, size = base_size, margin = margin(t=15)),
      legend.position     = "bottom",  
      legend.direction    = "horizontal"
    )
}


#------------------------------ Save helper ------------------------------------


hwwi_save_plot <- function(plot, filename,
                           width = 11,
                           height = 6,
                           dpi = 400,
                           bg = "white",
                           device = NULL) {
  ext <- tolower(tools::file_ext(filename))
  
  if (is.null(device)) {
    device <- switch(
      ext,
      "png"  = "png",
      "jpg"  = "jpeg",
      "jpeg" = "jpeg",
      "pdf"  = if (capabilities("cairo")) grDevices::cairo_pdf else grDevices::pdf,
      stop("Unsupported file extension: .", ext,
           ". Use .png, .jpg, .jpeg, or .pdf.", call. = FALSE)
    )
  }
  
  ggplot2::ggsave(
    filename = filename,
    plot = plot,
    width = width,
    height = height,
    dpi = dpi,
    units = "in",
    bg = bg,
    device = device
  )
}

