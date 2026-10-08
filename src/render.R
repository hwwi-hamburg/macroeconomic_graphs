.render_language_from_dir <- function(out_dir) {
  path <- tolower(gsub("\\\\", "/", out_dir))
  if (grepl("german labeling", path, fixed = TRUE)) return("de")
  if (grepl("english labeling", path, fixed = TRUE)) return("en")
  NA_character_
}

.filter_frame_from_month <- function(dat, start_month) {
  if (!is.data.frame(dat) || !"date" %in% names(dat)) return(dat)
  if (!inherits(dat$date, c("Date", "POSIXct", "POSIXt"))) return(dat)

  cutoff <- as.Date(paste0(start_month, "-01"))
  keep <- is.na(dat$date) | as.Date(dat$date) >= cutoff
  dat[keep, , drop = FALSE]
}

# Enforce --start-month at the final rendering boundary. Most graph modules
# already filter their source data, but this also covers older modules with a
# hard-coded historical start and custom plots that keep data on their layers.
.apply_render_start_month <- function(plot) {
  start_month <- getOption("hwwi.start.month")
  if (is.null(start_month) || !inherits(plot, "ggplot")) return(plot)

  plot$data <- .filter_frame_from_month(plot$data, start_month)
  for (i in seq_along(plot$layers)) {
    plot$layers[[i]]$data <- .filter_frame_from_month(plot$layers[[i]]$data, start_month)
  }
  plot
}

render_graph <- function(plot, title, out_dir, format = OUT_FORMAT,
                         width = OUT_WIDTH, height = OUT_HEIGHT, dpi = OUT_DPI) {
  requested_language <- getOption("hwwi.render.language")
  output_language <- .render_language_from_dir(out_dir)

  # Dry run (see expected_graph_files()): note the path without evaluating
  # `plot`, so nothing is fetched or written.
  if (isTRUE(getOption("hwwi.dry.run"))) {
    path <- file.path(out_dir, paste0(title, ".", format))
    .render_log$planned[[length(.render_log$planned) + 1L]] <- list(
      path = path, language = .render_language(path, output_language))
    return(invisible(path))
  }

  # `plot` is a lazy argument. Returning before it is evaluated means that a
  # one-language run does not fetch data or build the unrequested variant.
  if (!is.null(requested_language) && !is.na(output_language) &&
      !identical(requested_language, output_language)) {
    return(invisible(NULL))
  }

  output_override <- getOption("hwwi.output.dir")
  if (!is.null(output_override)) out_dir <- output_override

  plot <- .apply_render_start_month(plot)

  dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
  path <- file.path(out_dir, paste0(title, ".", format))
  ggplot2::ggsave(filename = path, plot = plot, width = width, height = height,
                  dpi = dpi, units = "in", bg = "white")
  .record_render(path, output_language, plot)
  invisible(path)
}

# Files written in this R session, used to build the graph lists. Each entry
# holds the graph id (from with_graph_context()), the file path, its label
# language, and the chart caption, which serves as the fallback source text.
.render_log <- new.env(parent = emptyenv())
.render_log$entries <- list()
.render_log$planned <- list()

# Label language from the output folder, or else from a _de/_en file suffix.
.render_language <- function(path, dir_language) {
  if (!is.na(dir_language)) return(dir_language)
  stem <- tools::file_path_sans_ext(path)
  if (grepl("_de$", stem)) "de" else if (grepl("_en$", stem)) "en" else NA_character_
}

.record_render <- function(path, language, plot) {
  caption <- if (inherits(plot, "ggplot")) plot$labels$caption else NULL
  .render_log$entries[[length(.render_log$entries) + 1L]] <- list(
    id = getOption("hwwi.current.graph", NA_character_),
    path = path,
    language = .render_language(path, language),
    caption = if (is.character(caption) && length(caption) == 1L) caption else NA_character_
  )
}

rendered_files <- function() .render_log$entries

render_all <- function(specs_dir = "src/graphs", out_base = "Graphs",
                       format = "jpeg", width = 11, height = 6, dpi = 300) {
  spec_files <- list.files(specs_dir, pattern = "\\.R$", recursive = TRUE, full.names = TRUE)
  for (f in spec_files) source(f, local = new.env(parent = .GlobalEnv))
  message("Sourced ", length(spec_files), " spec files from ", specs_dir)
}
