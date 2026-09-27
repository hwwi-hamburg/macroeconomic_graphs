# A cache entry is refetched at most once per calendar month, independent of
# DATA_START_MONTH: fetchers always pull the full available history, so the
# same cached file serves every display start date.
.cache_is_stale <- function(path) {
  format(file.info(path)$mtime, "%Y-%m") != format(Sys.Date(), "%Y-%m")
}

with_cache <- function(key, expr, cache_dir = CACHE_DIR) {
  path <- file.path(cache_dir, paste0(key, ".rds"))
  if (file.exists(path) && !.cache_is_stale(path)) return(readRDS(path))
  dir.create(cache_dir, showWarnings = FALSE, recursive = TRUE)
  result <- expr  # R lazy-evaluates: only runs if cache miss
  saveRDS(result, path)
  result
}

bust_cache <- function(key = NULL, cache_dir = CACHE_DIR) {
  if (is.null(key)) {
    files <- list.files(cache_dir, pattern = "\\.rds$", full.names = TRUE)
    file.remove(files)
    message("Removed ", length(files), " cached files")
  } else {
    path <- file.path(cache_dir, paste0(key, ".rds"))
    if (file.exists(path)) file.remove(path)
  }
  invisible(NULL)
}
