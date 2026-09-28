#!/usr/bin/env Rscript

# Build one searchable HTML page containing every graph currently in out/.
#
# Usage:
#   Rscript src/create_output_gallery.R
#   Rscript src/create_output_gallery.R --input-dir=out --output=out/all_outputs.html
#   Rscript src/create_output_gallery.R --open

args <- commandArgs(trailingOnly = TRUE)

if (any(args %in% c("-h", "--help"))) {
  cat(
    "Create a single HTML gallery for graph output files.\n\n",
    "Options:\n",
    "  --input-dir=DIR   Folder to scan recursively (default: out)\n",
    "  --output=FILE     HTML file to create (default: DIR/all_outputs.html)\n",
    "  --open            Open the completed page in the default browser\n",
    sep = ""
  )
  quit(status = 0)
}

read_option <- function(name, default = NULL) {
  prefix <- paste0("--", name, "=")
  matches <- args[startsWith(args, prefix)]
  if (length(matches) > 1L) {
    stop("Option --", name, " may only be supplied once.", call. = FALSE)
  }
  if (!length(matches)) return(default)
  value <- sub(prefix, "", matches[[1]], fixed = TRUE)
  if (!nzchar(value)) stop("Option --", name, " cannot be empty.", call. = FALSE)
  value
}

input_dir <- read_option("input-dir", "out")
output_file <- read_option("output", file.path(input_dir, "all_outputs.html"))
open_page <- "--open" %in% args

known_args <- args == "--open" |
  startsWith(args, "--input-dir=") |
  startsWith(args, "--output=")
if (any(!known_args)) {
  stop("Unknown option(s): ", paste(args[!known_args], collapse = ", "), call. = FALSE)
}

if (!dir.exists(input_dir)) {
  stop("Input directory does not exist: ", input_dir, call. = FALSE)
}

input_dir <- normalizePath(input_dir, winslash = "/", mustWork = TRUE)
output_file <- normalizePath(
  file.path(dirname(output_file), basename(output_file)),
  winslash = "/",
  mustWork = FALSE
)

extensions <- c("png", "jpg", "jpeg", "gif", "webp", "svg", "pdf")
pattern <- paste0("\\.(", paste(extensions, collapse = "|"), ")$")
files <- list.files(
  input_dir,
  pattern = pattern,
  recursive = TRUE,
  full.names = TRUE,
  ignore.case = TRUE
)
files <- sort(normalizePath(files, winslash = "/", mustWork = TRUE))

if (!length(files)) {
  stop(
    "No graph outputs found in ", input_dir,
    ". Supported extensions: ", paste(extensions, collapse = ", "),
    call. = FALSE
  )
}

html_escape <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  x <- gsub('"', "&quot;", x, fixed = TRUE)
  gsub("'", "&#39;", x, fixed = TRUE)
}

relative_path <- function(path, base_dir) {
  path_parts <- strsplit(normalizePath(path, winslash = "/", mustWork = TRUE), "/", fixed = TRUE)[[1]]
  base_parts <- strsplit(normalizePath(base_dir, winslash = "/", mustWork = TRUE), "/", fixed = TRUE)[[1]]
  shared <- 0L
  limit <- min(length(path_parts), length(base_parts))
  while (shared < limit && identical(path_parts[[shared + 1L]], base_parts[[shared + 1L]])) {
    shared <- shared + 1L
  }
  parts <- c(
    rep("..", length(base_parts) - shared),
    path_parts[seq.int(shared + 1L, length(path_parts))]
  )
  paste(parts, collapse = "/")
}

url_path <- function(path) {
  parts <- strsplit(path, "/", fixed = TRUE)[[1]]
  paste(vapply(parts, utils::URLencode, character(1), reserved = TRUE), collapse = "/")
}

pretty_size <- function(bytes) {
  if (bytes < 1024) return(paste0(bytes, " B"))
  if (bytes < 1024^2) return(sprintf("%.1f KB", bytes / 1024))
  sprintf("%.1f MB", bytes / 1024^2)
}

relative_files <- substring(files, nchar(input_dir) + 2L)
folders <- dirname(relative_files)
folders[folders == "."] <- "Top level"
names <- tools::file_path_sans_ext(basename(files))
extensions_found <- tolower(tools::file_ext(files))
info <- file.info(files)

language <- ifelse(
  grepl("(^|/)(German labeling)(/|$)|_de$", relative_files, ignore.case = TRUE),
  "German",
  ifelse(
    grepl("(^|/)(English labeling)(/|$)|_en$", relative_files, ignore.case = TRUE),
    "English",
    "Other"
  )
)

page_dir <- dirname(output_file)
dir.create(page_dir, recursive = TRUE, showWarnings = FALSE)
links <- vapply(files, function(x) url_path(relative_path(x, page_dir)), character(1))

folder_order <- unique(folders)
folder_options <- paste0(
  '<option value="', html_escape(folder_order), '">',
  html_escape(folder_order), "</option>"
)

cards <- character(length(files))
for (i in seq_along(files)) {
  preview <- if (extensions_found[[i]] == "pdf") {
    paste0(
      '<object class="preview pdf" data="', html_escape(links[[i]]),
      '" type="application/pdf"><a href="', html_escape(links[[i]]),
      '" target="_blank">Open PDF</a></object>'
    )
  } else {
    paste0(
      '<a class="image-link" href="', html_escape(links[[i]]), '" target="_blank">',
      '<img class="preview" src="', html_escape(links[[i]]), '" loading="lazy" ',
      'decoding="async" alt="', html_escape(names[[i]]), '"></a>'
    )
  }

  cards[[i]] <- paste0(
    '<article class="card" data-folder="', html_escape(folders[[i]]),
    '" data-language="', language[[i]], '" data-search="',
    html_escape(tolower(paste(names[[i]], folders[[i]], language[[i]]))), '">',
    preview,
    '<div class="card-body"><h2>', html_escape(names[[i]]), '</h2>',
    '<p><span>', html_escape(folders[[i]]), '</span><span>', language[[i]],
    '</span><span>', pretty_size(info$size[[i]]), '</span></p></div></article>'
  )
}

generated_at <- format(Sys.time(), "%Y-%m-%d %H:%M %Z")

html <- c(
  "<!doctype html>",
  '<html lang="en">',
  "<head>",
  '<meta charset="utf-8">',
  '<meta name="viewport" content="width=device-width, initial-scale=1">',
  "<title>Graph output review</title>",
  "<style>",
  ":root { color-scheme: light; --ink:#18202a; --muted:#657181; --line:#dce2e8; --brand:#007f86; --bg:#f3f5f7; }",
  "* { box-sizing:border-box; }",
  "body { margin:0; background:var(--bg); color:var(--ink); font:15px/1.45 system-ui,-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif; }",
  "header { background:#fff; border-bottom:1px solid var(--line); padding:24px max(24px,calc((100vw - 1500px)/2)); }",
  "h1 { margin:0 0 4px; font-size:clamp(24px,3vw,38px); letter-spacing:-.03em; }",
  ".summary { margin:0; color:var(--muted); }",
  ".controls { position:sticky; top:0; z-index:5; display:grid; grid-template-columns:minmax(220px,2fr) minmax(180px,1fr) auto; gap:10px; padding:14px max(24px,calc((100vw - 1500px)/2)); background:rgba(255,255,255,.96); border-bottom:1px solid var(--line); backdrop-filter:blur(8px); }",
  "input,select,button { min-height:42px; border:1px solid #bdc7d0; border-radius:7px; background:#fff; color:var(--ink); padding:8px 11px; font:inherit; }",
  "button { cursor:pointer; } button.active { color:#fff; background:var(--brand); border-color:var(--brand); }",
  ".languages { display:flex; gap:6px; }",
  "main { max-width:1500px; margin:0 auto; padding:24px; }",
  ".results { margin:0 0 14px; color:var(--muted); }",
  ".grid { display:grid; grid-template-columns:repeat(2,minmax(0,1fr)); gap:18px; }",
  ".card { min-width:0; overflow:hidden; background:#fff; border:1px solid var(--line); border-radius:10px; box-shadow:0 2px 8px rgba(25,35,45,.05); }",
  ".preview { display:block; width:100%; aspect-ratio:11/6; object-fit:contain; background:#fff; border:0; }",
  ".image-link { display:block; border-bottom:1px solid var(--line); }",
  ".card-body { padding:12px 14px 14px; }",
  ".card h2 { margin:0 0 8px; font-size:15px; overflow-wrap:anywhere; }",
  ".card p { display:flex; flex-wrap:wrap; gap:6px; margin:0; color:var(--muted); font-size:12px; }",
  ".card p span { padding:3px 7px; background:#eef2f4; border-radius:99px; }",
  ".hidden { display:none !important; }",
  ".empty { padding:50px 0; text-align:center; color:var(--muted); }",
  "@media (max-width:800px) { .controls { grid-template-columns:1fr; position:static; } .grid { grid-template-columns:1fr; } .languages button { flex:1; } }",
  "</style>",
  "</head>",
  "<body>",
  "<header>",
  "<h1>Graph output review</h1>",
  paste0('<p class="summary">', length(files), " outputs from <strong>",
         html_escape(basename(input_dir)), "</strong> · generated ", html_escape(generated_at), "</p>"),
  "</header>",
  '<section class="controls" aria-label="Gallery filters">',
  '<input id="search" type="search" placeholder="Search graphs or folders…" aria-label="Search graphs">',
  paste0('<select id="folder" aria-label="Filter by folder"><option value="">All folders</option>',
         paste(folder_options, collapse = ""), "</select>"),
  '<div class="languages" aria-label="Filter by language">',
  '<button class="active" type="button" data-language="">All</button>',
  '<button type="button" data-language="German">German</button>',
  '<button type="button" data-language="English">English</button>',
  '<button type="button" data-language="Other">Other</button>',
  "</div>",
  "</section>",
  "<main>",
  paste0('<p id="results" class="results">Showing all ', length(files), " outputs</p>"),
  paste0('<section class="grid">', paste(cards, collapse = "\n"), "</section>"),
  '<p id="empty" class="empty hidden">No outputs match these filters.</p>',
  "</main>",
  "<script>",
  "const cards=[...document.querySelectorAll('.card')];",
  "const search=document.querySelector('#search');",
  "const folder=document.querySelector('#folder');",
  "const result=document.querySelector('#results');",
  "const empty=document.querySelector('#empty');",
  "const buttons=[...document.querySelectorAll('[data-language]')].filter(x=>x.tagName==='BUTTON');",
  "let selectedLanguage='';",
  "function filterCards(){",
  "  const query=search.value.trim().toLowerCase(); let visible=0;",
  "  cards.forEach(card=>{",
  "    const show=(!query||card.dataset.search.includes(query))&&(!folder.value||card.dataset.folder===folder.value)&&(!selectedLanguage||card.dataset.language===selectedLanguage);",
  "    card.classList.toggle('hidden',!show); if(show) visible++;",
  "  });",
  "  result.textContent=`Showing ${visible} of ${cards.length} outputs`; empty.classList.toggle('hidden',visible!==0);",
  "}",
  "search.addEventListener('input',filterCards); folder.addEventListener('change',filterCards);",
  "buttons.forEach(button=>button.addEventListener('click',()=>{ selectedLanguage=button.dataset.language; buttons.forEach(x=>x.classList.toggle('active',x===button)); filterCards(); }));",
  "</script>",
  "</body>",
  "</html>"
)

writeLines(html, output_file, useBytes = TRUE)
cat("Created ", output_file, " with ", length(files), " output(s).\n", sep = "")

if (open_page) utils::browseURL(output_file)
