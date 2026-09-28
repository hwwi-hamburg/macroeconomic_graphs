#!/usr/bin/env Rscript
# Run from project root: Rscript src/cli.R
# Optional flags:
#   --start-year=YYYY      override the earliest year fetched
#   --start-month=YYYY-MM  override the earliest year-month fetched
#   --output-folder=NAME   save selected graphs in out/custom/NAME/
#   --language=de|en       render only German or only English labels

.cli_args <- commandArgs(trailingOnly = TRUE)

.start_year_flag <- grep("^--start-year=", .cli_args, value = TRUE)
.start_month_flag <- grep("^--start-month=", .cli_args, value = TRUE)
.output_folder_flag <- grep("^--output-folder=", .cli_args, value = TRUE)
.language_flag <- grep("^--language=", .cli_args, value = TRUE)
.list_graphs_flag <- any(tolower(.cli_args) == "--list-graphs")

if (length(.start_year_flag) > 1L || length(.start_month_flag) > 1L ||
    length(.output_folder_flag) > 1L || length(.language_flag) > 1L ||
    sum(tolower(.cli_args) == "--list-graphs") > 1L) {
  stop("Each CLI option may be specified only once", call. = FALSE)
}
if (length(.start_year_flag) > 0 && length(.start_month_flag) > 0) {
  stop("Use either --start-year or --start-month, not both", call. = FALSE)
}

.custom_start_month <- if (length(.start_year_flag) > 0) {
  raw <- sub("^--start-year=", "", .start_year_flag[1])
  if (grepl("^[0-9]{4}$", raw)) paste0(raw, "-01") else NA_character_
} else if (length(.start_month_flag) > 0) {
  raw <- sub("^--start-month=", "", .start_month_flag[1])
  if (grepl("^[0-9]{4}-(0[1-9]|1[0-2])$", raw)) raw else NA_character_
} else {
  NULL
}
if (!is.null(.custom_start_month) && is.na(.custom_start_month)) {
  if (length(.start_year_flag) > 0) {
    stop("Invalid --start-year value: ", .start_year_flag[1], " (expected YYYY)")
  } else {
    stop("Invalid --start-month value: ", .start_month_flag[1], " (expected YYYY-MM)")
  }
}

.output_folder <- if (length(.output_folder_flag)) {
  trimws(sub("^--output-folder=", "", .output_folder_flag[[1]]))
} else {
  NULL
}
if (!is.null(.output_folder) &&
    (!nzchar(.output_folder) || .output_folder %in% c(".", "..") ||
     grepl("[/\\\\]", .output_folder) || startsWith(.output_folder, "~"))) {
  stop(
    "--output-folder must be one folder name directly inside out/custom/",
    call. = FALSE
  )
}

.language <- if (length(.language_flag)) {
  tolower(trimws(sub("^--language=", "", .language_flag[[1]])))
} else {
  NULL
}
.language_aliases <- c(de = "de", german = "de", en = "en", english = "en")
if (!is.null(.language) && !.language %in% names(.language_aliases)) {
  stop("--language must be 'de', 'en', 'german', or 'english'", call. = FALSE)
}
if (!is.null(.language)) .language <- unname(.language_aliases[[.language]])

.cli_args <- .cli_args[
  !grepl("^--(start-year|start-month|output-folder|language)=", .cli_args)
]

source("src/bootstrap.R")

.base_out_dir <- OUT_DIR
.custom_out_dir <- file.path(.base_out_dir, "custom")
.run_out_dir <- .base_out_dir

if (!is.null(.custom_start_month)) {
  DATA_START_MONTH <- .custom_start_month
  options(hwwi.start.month = .custom_start_month)

  .run_out_dir <- file.path(
    .custom_out_dir,
    paste0("custom start ", .custom_start_month)
  )

  cat("Custom start month:", .custom_start_month, "\n")
}

# An explicit folder takes precedence when both flags are provided.
if (!is.null(.output_folder)) {
  .run_out_dir <- file.path(.custom_out_dir, .output_folder)
}

# Use one authoritative, stable output location for renderers and status messages.
dir.create(.run_out_dir, recursive = TRUE, showWarnings = FALSE)
OUT_DIR <- .run_out_dir
options(hwwi.output.dir = .run_out_dir)

if (!is.null(.custom_start_month) || !is.null(.output_folder) || .list_graphs_flag) {
  cat("Output folder:", .run_out_dir, "\n")
}

if (!is.null(.language)) {
  options(hwwi.render.language = .language)
  cat("Label language:", if (.language == "de") "German" else "English", "\n")
}

.graphs <- discover_graphs()

# ── helpers ───────────────────────────────────────────────────────────────────

.hr <- function() cat(strrep("─", 58), "\n", sep = "")

.read_line <- function(prompt) {
  cat(prompt)
  readLines(con = stdin(), n = 1)
}

.write_graph_list <- function(path, reg, selected = NULL, title = "HWWI Macroeconomic Standard Graphs") {
  if (is.null(selected)) {
    selected <- seq_along(reg)
  }

  lines <- c(
    "",
    strrep("─", 58),
    sprintf("  %s", title),
    strrep("─", 58),
    ""
  )

  cur_cat <- ""
  for (i in selected) {
    g <- reg[[i]]
    if (g$category != cur_cat) {
      if (nzchar(cur_cat)) lines <- c(lines, "")
      lines <- c(lines, sprintf("  %s", g$category))
      cur_cat <- g$category
    }
    lines <- c(lines, sprintf("    %2d  %s", i, g$label))
  }

  lines <- c(lines, "", strrep("─", 58), "")
  writeLines(lines, path)
}

if (.list_graphs_flag) {
  list_path <- file.path(OUT_DIR, "available_graphs.txt")
  .write_graph_list(list_path, .graphs)
  cat("Graph list written to", list_path, "\n")
  quit(status = 0)
}

.show_menu <- function(reg, show_cli_options = FALSE) {
  cat("\n")
  .hr()
  cat("  HWWI Macroeconomic Standard Graphs\n")
  .hr()
  cat("\n")

  cur_cat <- ""
  for (i in seq_along(reg)) {
    g <- reg[[i]]
    if (g$category != cur_cat) {
      if (nzchar(cur_cat)) cat("\n")
      cat("  ", g$category, "\n", sep = "")
      cur_cat <- g$category
    }
    cat(sprintf("    %2d  %s\n", i, g$label))
  }

  cat("\n")
  .hr()
  cat("  Enter numbers (e.g. 1,3,5-7), graph IDs, category names\n")
  cat("  (e.g. gdp,trade), or 'all'.\n")

  if (show_cli_options) {
    cat("\n")
    cat("  Optional command-line flags (restart with these before selecting):\n")
    cat("    --start-year=YYYY      Set the earliest data year\n")
    cat("    --start-month=YYYY-MM  Set the earliest data year-month\n")
    cat("    --output-folder=NAME   Save files in out/custom/NAME/\n")
    cat("    --language=de|en       Render German or English labels only\n")
    cat("    --list-graphs          Write all available graph IDs and labels to txt\n")
    cat("  Example:\n")
    cat("    Rscript src/cli.R --output-folder=report --language=en gdp\n")
  }

  .hr()
  cat("\n")
}

.parse_selection <- function(input, reg) {
  input <- trimws(tolower(input))
  if (input == "all") return(seq_along(reg))

  cats <- tolower(sapply(reg, `[[`, "category"))
  ids <- tolower(sapply(reg, `[[`, "id"))
  idx <- integer(0)

  for (token in strsplit(input, "[[:space:],]+")[[1]]) {
    token <- trimws(token)
    if (!nzchar(token)) next

    if (grepl("^\\d+-\\d+$", token)) {
      parts <- as.integer(strsplit(token, "-")[[1]])
      idx <- c(idx, seq(parts[1], parts[2]))
    } else if (grepl("^\\d+$", token)) {
      idx <- c(idx, as.integer(token))
    } else if (token %in% cats) {
      idx <- c(idx, which(cats == token))
    } else if (token %in% ids) {
      idx <- c(idx, which(ids == token))
    } else {
      cat("  Unknown token ignored:", token, "\n")
    }
  }

  unique(sort(idx[idx >= 1 & idx <= length(reg)]))
}

# ── main ──────────────────────────────────────────────────────────────────────

# Support non-interactive usage:
# Rscript src/cli.R [options] [render] <selection>
# e.g. Rscript src/cli.R all
#      Rscript src/cli.R render all
#      Rscript src/cli.R gdp
#      Rscript src/cli.R 1,3,5-7
#      Rscript src/cli.R --start-year=1995 gdp
#      Rscript src/cli.R --start-month=1995-06 gdp
#      Rscript src/cli.R --output-folder=report --language=en gdp
#      Rscript src/cli.R --list-graphs
.cli_args <- .cli_args[!tolower(.cli_args) %in% "render"]

if (length(.cli_args) > 0) {
  input <- paste(.cli_args, collapse = ",")
  .show_menu(.graphs)
  cat(">", input, "\n")

  selected <- .parse_selection(input, .graphs)
  if (length(selected) == 0) {
    cat("No valid graphs selected. Exiting.\n")
    quit(status = 1)
  }

  cat("\nWill generate", length(selected), "graph(s). Starting...\n\n")
} else {
  .show_menu(.graphs, show_cli_options = TRUE)
  input <- .read_line("> ")

  if (!nzchar(trimws(input))) {
    cat("No selection. Exiting.\n")
    quit(status = 0)
  }

  selected <- .parse_selection(input, .graphs)

  if (length(selected) == 0) {
    cat("No valid graphs selected. Exiting.\n")
    quit(status = 0)
  }

  cat("\nWill generate:\n")
  for (i in selected) cat(sprintf("  [%d] %s\n", i, .graphs[[i]]$label))

  cat("\nProceed? [Y/n] ")
  confirm <- readLines(con = stdin(), n = 1)

  if (tolower(trimws(confirm)) %in% c("n", "no")) {
    cat("Cancelled.\n")
    quit(status = 0)
  }
}

cat("\n")
errors <- character(0)
n_total <- length(selected)

for (k in seq_along(selected)) {
  i <- selected[[k]]
  g <- .graphs[[i]]

  cat(sprintf("[%d/%d] %s ... ", k, n_total, g$label))
  t0 <- proc.time()[["elapsed"]]

  tryCatch({
    g$render()
    cat(sprintf("done (%.0fs)\n", proc.time()[["elapsed"]] - t0))
  }, error = function(e) {
    cat("FAILED\n")
    errors <<- c(errors, sprintf("[%d] %s: %s", i, g$label, conditionMessage(e)))
  })
}

cat("\n")
.hr()

if (length(errors)) {
  cat("  Errors:\n")
  for (e in errors) cat("  ✗ ", e, "\n", sep = "")
} else {
  output_dir <- getOption("hwwi.output.dir", OUT_DIR)
  if (!is.null(.output_folder)) {
    index_path <- file.path(output_dir, "index.txt")
    .write_graph_list(index_path, .graphs, selected = selected)
  }
  cat(sprintf("  ✓ %d graph(s) generated in %s/\n", n_total, output_dir))
}

.hr()
cat("\n")