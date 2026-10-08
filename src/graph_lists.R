# Graph lists for colleagues browsing the output folders.
#
# - Long list ("Available graphs.html"), written to the standard output folder:
#   every graph in the catalog with its full name and links that open the
#   German/English image, preceded by a short usage text maintained in
#   src/templates/available_graphs_intro.md. Links point to the files each
#   graph writes in the standard folder (found with a dry run of its render
#   function, see expected_graph_files()); graphs not rendered yet show "–".
# - Short list ("Graph list.html"), written to custom output folders
#   (--output-folder / --start-year / --start-month): only the graphs of that
#   run, with full name, file names, source, and notes.
#
# Both lists number graphs like the CLI menu, so `Rscript src/cli.R 12` renders
# graph no. 12.

GRAPH_OVERVIEW_FILE  <- "Available graphs.html"
GRAPH_SELECTION_FILE <- "Graph list.html"
GRAPH_OVERVIEW_INTRO <- "src/templates/available_graphs_intro.md"

# ── Expected files ────────────────────────────────────────────────────────────

.gl_relative_path <- function(path, base_dir) {
  path <- normalizePath(path, winslash = "/", mustWork = FALSE)
  base <- normalizePath(base_dir, winslash = "/", mustWork = FALSE)
  if (!startsWith(path, paste0(base, "/"))) return(NA_character_)
  substring(path, nchar(base) + 2L)
}

# Call every render function in dry-run mode: render_graph() then only records
# the path it would write and never evaluates its (lazy) plot argument, so no
# data is fetched. Returns a list keyed by graph id of list(path, language).
expected_graph_files <- function(catalog, out_dir = OUT_DIR) {
  old_out_dir <- get("OUT_DIR", envir = .GlobalEnv)
  old_options <- options(hwwi.dry.run = TRUE, hwwi.output.dir = NULL,
                         hwwi.render.language = NULL)
  on.exit({
    assign("OUT_DIR", old_out_dir, envir = .GlobalEnv)
    options(old_options)
    .render_log$planned <- list()
  }, add = TRUE)
  assign("OUT_DIR", out_dir, envir = .GlobalEnv)

  files <- list()
  for (spec in catalog) {
    .render_log$planned <- list()
    tryCatch(with_graph_context(spec$id, spec$render()),
             error = function(e) warning("Could not list files of ", spec$id, ": ",
                                         conditionMessage(e), call. = FALSE))
    files[[spec$id]] <- .render_log$planned
  }
  files
}

# ── Text helpers ──────────────────────────────────────────────────────────────

.gl_escape <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  gsub('"', "&quot;", x, fixed = TRUE)
}

.gl_url <- function(rel_path) {
  parts <- strsplit(rel_path, "/", fixed = TRUE)[[1]]
  paste(vapply(parts, utils::URLencode, character(1), reserved = TRUE), collapse = "/")
}

.gl_link <- function(rel_path, text) {
  sprintf('<a href="%s" target="_blank">%s</a>', .gl_escape(.gl_url(rel_path)), .gl_escape(text))
}

# Metadata `source` if set, otherwise the chart caption without its
# "Data source:" prefix and trailing year. English captions are preferred.
.gl_source_text <- function(spec, entries) {
  if (!is.null(spec[["source"]]) && nzchar(spec[["source"]])) return(spec[["source"]])
  captions <- vapply(entries, `[[`, character(1), "caption")
  languages <- vapply(entries, function(e) e$language %||% NA_character_, character(1))
  captions <- c(captions[languages %in% "en"], captions[!languages %in% "en"])
  captions <- captions[!is.na(captions) & nzchar(captions)]
  if (!length(captions)) return("")
  text <- gsub("\\s+", " ", captions[[1]])
  text <- sub("^(data ?sources?|sources?|datenquellen?|quellen?)\\s*:\\s*", "", text, ignore.case = TRUE)
  trimws(sub("[,;]?\\s*(19|20)[0-9]{2}$", "", text))
}

# Minimal Markdown for the intro text: "## " headings, "- " and "1. " list
# items, blank-line separated paragraphs, **bold**, and [text](url) links.
.gl_markdown <- function(lines) {
  inline <- function(x) {
    x <- .gl_escape(x)
    x <- gsub("\\*\\*(.+?)\\*\\*", "<strong>\\1</strong>", x, perl = TRUE)
    gsub("\\[([^]]+)\\]\\(([^)]+)\\)", '<a href="\\2">\\1</a>', x, perl = TRUE)
  }
  out <- character()
  block <- NULL  # "p", "ul", or "ol"
  close_block <- function() {
    if (!is.null(block)) out <<- c(out, sprintf("</%s>", block))
    block <<- NULL
  }
  open_block <- function(type) {
    if (!identical(block, type)) {
      close_block()
      out <<- c(out, sprintf("<%s>", type))
      block <<- type
    }
  }
  for (line in lines) {
    line <- trimws(line, which = "right")
    if (!nzchar(trimws(line))) {
      close_block()
    } else if (grepl("^#+ ", line)) {
      close_block()
      out <- c(out, sprintf("<h2>%s</h2>", inline(sub("^#+ ", "", line))))
    } else if (grepl("^\\s*[-*] ", line)) {
      open_block("ul")
      out <- c(out, sprintf("<li>%s</li>", inline(sub("^\\s*[-*] ", "", line))))
    } else if (grepl("^\\s*[0-9]+\\. ", line)) {
      open_block("ol")
      out <- c(out, sprintf("<li>%s</li>", inline(sub("^\\s*[0-9]+\\. ", "", line))))
    } else {
      open_block("p")
      out <- c(out, inline(line))
    }
  }
  close_block()
  out
}

# ── Page template ─────────────────────────────────────────────────────────────

.gl_page <- function(title, subtitle, body, searchable = FALSE) {
  c(
    "<!doctype html>",
    '<html lang="en">',
    "<head>",
    '<meta charset="utf-8">',
    '<meta name="viewport" content="width=device-width, initial-scale=1">',
    sprintf("<title>%s</title>", .gl_escape(title)),
    "<style>",
    ":root { --blue:#004F9F; --dark:#3C3C3C; --muted:#6b7480; --line:#dde3ea; --soft:#f2f5f9; }",
    "* { box-sizing:border-box; }",
    "body { margin:0; background:#fff; color:var(--dark); font:15px/1.5 Verdana,'Segoe UI',system-ui,sans-serif; }",
    "main { max-width:1100px; margin:0 auto; padding:32px 20px 60px; }",
    "h1 { margin:0 0 4px; color:var(--blue); font-size:26px; }",
    ".subtitle { margin:0 0 24px; color:var(--muted); font-size:13px; }",
    ".intro { background:var(--soft); border-left:4px solid var(--blue); padding:6px 22px; margin-bottom:28px; }",
    ".intro h2 { font-size:16px; color:var(--blue); margin:16px 0 4px; }",
    ".intro ol, .intro ul { padding-left:22px; }",
    "input[type=search] { width:100%; padding:10px 12px; font:inherit; border:1px solid #b9c3cf; border-radius:6px; margin-bottom:8px; }",
    "h2.category { font-size:18px; color:var(--blue); margin:28px 0 8px; }",
    "table { width:100%; border-collapse:collapse; font-size:14px; }",
    "th { text-align:left; font-size:12px; text-transform:uppercase; letter-spacing:.04em; color:var(--muted); border-bottom:2px solid var(--line); padding:6px 8px; }",
    "td { border-bottom:1px solid var(--line); padding:7px 8px; vertical-align:top; }",
    "td a { color:var(--blue); white-space:nowrap; margin-right:10px; }",
    "td.files a { white-space:normal; display:block; }",
    ".missing { color:var(--muted); font-style:italic; }",
    ".num { width:3.5em; text-align:right; color:var(--muted); font-variant-numeric:tabular-nums; }",
    ".hidden { display:none; }",
    "@media print { input[type=search] { display:none; } }",
    "</style>",
    "</head>",
    "<body>",
    "<main>",
    sprintf("<h1>%s</h1>", .gl_escape(title)),
    sprintf('<p class="subtitle">%s</p>', .gl_escape(subtitle)),
    body,
    "</main>",
    if (searchable) c(
      "<script>",
      "const rows=[...document.querySelectorAll('tbody tr')];",
      "document.querySelector('#search').addEventListener('input',e=>{",
      "  const q=e.target.value.trim().toLowerCase();",
      "  rows.forEach(r=>r.classList.toggle('hidden',q&&!r.textContent.toLowerCase().includes(q)));",
      "  document.querySelectorAll('section.category').forEach(s=>s.classList.toggle('hidden',!s.querySelector('tbody tr:not(.hidden)')));",
      "});",
      "</script>"
    ),
    "</body>",
    "</html>"
  )
}

# ── Long list: all available graphs ───────────────────────────────────────────

# Contact for the intro's {{CONTACT}} placeholder. It comes from
# GRAPH_LIST_CONTACT in the git-ignored src/local_config.R, so names and
# e-mail addresses stay out of the repository.
.gl_contact <- function() {
  contact <- if (exists("GRAPH_LIST_CONTACT", envir = .GlobalEnv)) {
    get("GRAPH_LIST_CONTACT", envir = .GlobalEnv)
  }
  if (is.character(contact) && length(contact) == 1L && nzchar(trimws(contact))) {
    return(trimws(contact))
  }
  message("Note: GRAPH_LIST_CONTACT is not set; add it to src/local_config.R ",
          "to show a contact in \"", GRAPH_OVERVIEW_FILE, "\".")
  "[contact not configured]"
}

write_graph_overview <- function(catalog, out_dir = OUT_DIR, intro_file = GRAPH_OVERVIEW_INTRO) {
  expected <- expected_graph_files(catalog, out_dir)

  file_links <- function(files, language) {
    files <- Filter(function(f) identical(f$language, language) && file.exists(f$path), files)
    if (!length(files)) return('<span class="missing">–</span>')
    rels <- vapply(files, function(f) .gl_relative_path(f$path, out_dir), character(1))
    text <- if (language == "de") "German" else "English"
    if (length(rels) == 1L) return(.gl_link(rels[[1]], text))
    paste(vapply(rels, function(r) .gl_link(r, tools::file_path_sans_ext(basename(r))),
                 character(1)), collapse = "<br>")
  }

  numbers <- setNames(seq_along(catalog), vapply(catalog, `[[`, character(1), "id"))
  categories <- unique(vapply(catalog, `[[`, character(1), "category"))
  sections <- character()
  for (category in categories) {
    specs <- Filter(function(s) s$category == category, catalog)
    rows <- vapply(specs, function(spec) {
      files <- expected[[spec$id]] %||% list()
      sprintf('<tr><td class="num">%d</td><td>%s</td><td>%s</td><td>%s</td></tr>',
              numbers[[spec$id]], .gl_escape(spec$label),
              file_links(files, "de"), file_links(files, "en"))
    }, character(1))
    sections <- c(sections,
      '<section class="category">',
      sprintf('<h2 class="category">%s</h2>', .gl_escape(category)),
      "<table><thead><tr><th class=\"num\">No.</th><th>Graph</th><th style=\"width:12%\">German</th><th style=\"width:12%\">English</th></tr></thead><tbody>",
      rows,
      "</tbody></table>",
      "</section>")
  }

  intro <- if (file.exists(intro_file)) {
    lines <- readLines(intro_file, encoding = "UTF-8", warn = FALSE)
    lines <- gsub("{{CONTACT}}", .gl_contact(), lines, fixed = TRUE)
    c('<div class="intro">', .gl_markdown(lines), "</div>")
  }

  html <- .gl_page(
    "Available graphs",
    sprintf("%d graphs · list updated %s", length(catalog), format(Sys.time(), "%d.%m.%Y %H:%M")),
    c(intro,
      '<input id="search" type="search" placeholder="Search graphs, e.g. Hamburg, inflation, exports …" aria-label="Search graphs">',
      sections),
    searchable = TRUE
  )
  path <- file.path(out_dir, GRAPH_OVERVIEW_FILE)
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  writeLines(enc2utf8(html), path, useBytes = TRUE)
  invisible(path)
}

# ── Short list: graphs of one custom run ──────────────────────────────────────

write_graph_selection <- function(catalog, ids, out_dir = OUT_DIR, entries = rendered_files()) {
  numbers <- setNames(seq_along(catalog), vapply(catalog, `[[`, character(1), "id"))
  rows <- character()
  for (spec in Filter(function(s) s$id %in% ids, catalog)) {
    spec_entries <- Filter(function(e) identical(e$id, spec$id) && file.exists(e$path), entries)
    if (!length(spec_entries)) next
    rels <- unique(vapply(spec_entries, function(e) .gl_relative_path(e$path, out_dir), character(1)))
    rels <- rels[!is.na(rels)]
    files <- paste(vapply(rels, function(r) .gl_link(r, basename(r)), character(1)), collapse = "")
    rows <- c(rows, sprintf(
      '<tr><td class="num">%d</td><td>%s</td><td class="files">%s</td><td>%s</td><td>%s</td></tr>',
      numbers[[spec$id]], .gl_escape(spec$label), files,
      .gl_escape(.gl_source_text(spec, spec_entries)),
      .gl_escape(spec[["notes"]] %||% "")))
  }

  html <- .gl_page(
    "Graph list",
    sprintf("%d graphs in this folder · generated %s", length(rows), format(Sys.time(), "%d.%m.%Y %H:%M")),
    c("<table><thead><tr><th class=\"num\">No.</th><th style=\"width:30%\">Graph</th><th style=\"width:30%\">File</th><th>Source</th><th>Notes</th></tr></thead><tbody>",
      rows,
      "</tbody></table>")
  )
  path <- file.path(out_dir, GRAPH_SELECTION_FILE)
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  writeLines(enc2utf8(html), path, useBytes = TRUE)
  invisible(path)
}
