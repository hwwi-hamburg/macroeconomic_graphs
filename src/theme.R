#------------------------------------------
# Title: HWWI Basic Graph Settings (project layer)
# Purpose: Load the shared HWWI theme from the hwwi-theme submodule and add
#          the project-specific extensions this repository relies on.
#------------------------------------------

.hwwi_theme_file <- "hwwi-theme/hwwi_theme.R"
if (!file.exists(.hwwi_theme_file)) {
  stop("HWWI theme submodule not found at '", .hwwi_theme_file, "'. ",
       "Run `git submodule update --init` from the project root.", call. = FALSE)
}
source(.hwwi_theme_file)


#---------------------------- Packages -----------------------------------------

# Used by fetchers and plot builders but not loaded by the shared theme.
pacman::p_load(WDI, jsonlite, xml2, rnaturalearth, ggrepel)


#------------------------------ Theme extensions -------------------------------

# Axis titles are rotated 90 degrees by ggplot2 (y-axis) and can run the full
# height of the plot, sometimes taller than the plot itself. Wrapping long
# titles onto multiple lines keeps each line short, trading a little extra
# margin width for a much shorter (and less easily clipped) title.
wrap_axis_label <- function(label, width = 30) {
  if (is.null(label) || is.na(label)) return(label)
  stringr::str_wrap(label, width = width)
}

# Extends the shared theme_hwwi() with `no_axes`, used by the choropleth maps
# to hide axis lines, text and titles.
.theme_hwwi_shared <- theme_hwwi
theme_hwwi <- function(base_size = 12, base_family = "Verdana", grid = c("h", "hv"), no_axes = FALSE) {
  th <- .theme_hwwi_shared(base_size = base_size, base_family = base_family, grid = grid)
  if (!no_axes) return(th)
  th + ggplot2::theme(
    panel.grid.major.x = ggplot2::element_blank(),
    axis.line.x        = ggplot2::element_blank(),
    axis.text.x        = ggplot2::element_blank(),
    axis.text.y        = ggplot2::element_blank(),
    axis.title.x       = ggplot2::element_blank(),
    axis.title.y       = ggplot2::element_blank()
  )
}
