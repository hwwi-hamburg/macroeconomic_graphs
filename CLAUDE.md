# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

An R script project that generates HWWI's standard macroeconomic charts (GDP, Employment, Prices, Trade) as branded JPEGs, each rendered in both German and English labeling. Data comes from Destatis GENESIS, World Bank WDI, Bundesbank, and local Excel files. There is no package structure (no DESCRIPTION/renv) — it's a plain `Rscript`-driven project.

## Commands

Run from the project root (paths in the scripts are relative to it).

```bash
# Interactive menu (lists all graphs by category, prompts for a selection)
Rscript src/cli.R

# Non-interactive: generate everything
Rscript src/cli.R all

# Non-interactive: by category name (case-insensitive)
Rscript src/cli.R gdp
Rscript src/cli.R trade

# Non-interactive: by stable graph ID, menu number, comma list, and/or ranges
Rscript src/cli.R ger_bip_annual_growth
Rscript src/cli.R 1,3,5-7

# Override DATA_START_YEAR for this run only; output goes to a separate
# out/custom start <YYYY>/ tree instead of the standard out/
Rscript src/cli.R --start-year=1995 gdp

# Flatten selected output into out/monthly-report/ and render one language
Rscript src/cli.R --output-folder=monthly-report --language=en gdp

# Category-specific batch runners (used e.g. for scheduled/partial refreshes)
Rscript src/run_gdp.R
Rscript src/run_employment_prices.R
Rscript src/run_trade.R
```

`src/cli.R` accepts an optional leading `render` verb which is stripped (e.g. `Rscript src/cli.R render all`), plus `--start-year=YYYY`, `--output-folder=NAME`, and `--language=de|en`. The output-folder option writes all selected files directly into `out/NAME/`; it deliberately removes category/language subfolders.

Output is written to `out/<Category> graphs/<German|English> labeling/<title>.jpeg`. Fetched data is memoized to `cache/*.rds` (see `with_cache()`/`bust_cache()` in [src/fetch/cache.R](src/fetch/cache.R)) — delete the relevant `.rds` or call `bust_cache()` to force a refetch.

### `--start-year` override

`DATA_START_YEAR` ([src/config.R](src/config.R)) and `OUT_DIR` are plain global variables, and every fetcher/spec reads `DATA_START_YEAR` as a free variable (default args like `fetch_wdi(..., start = DATA_START_YEAR)`, or direct references like the `dplyr::filter(date >= ...)` calls in `graphs/gdp/ger_bip_annual.R`) rather than a value threaded through explicitly. Because R resolves free variables and default-argument promises at call time, not at function-definition time, reassigning these globals after `bootstrap.R` is sourced but before any `render()` is called changes every graph's behavior without touching the ~50 individual spec files.

`src/cli.R` uses exactly this: `--start-year=YYYY` reassigns `DATA_START_YEAR <- YYYY` and `OUT_DIR <- file.path(OUT_DIR, "custom start YYYY")` right after `bootstrap.R` runs (see the top of [src/cli.R](src/cli.R)). Cache keys embed `DATA_START_YEAR` (e.g. `wdi_<indicator>_<country>_<year>`, `genesis_<table>_<year>`), so a custom start year fetches fresh data into new cache entries rather than colliding with or invalidating the default run's cache. Snapshot-style graphs that fetch a single fixed year (trade structure pies, country choropleths) don't reference `DATA_START_YEAR` and are unaffected by this flag — that's expected, not a bug.

There is no test suite or lint config in this repo.

## Architecture

The pipeline for every graph is: **fetch → cache → transform → plot → render**. Each file in `src/graphs/` contains both its implementation and `.graph_specs` metadata; the CLI discovers these modules at runtime.

- **[src/bootstrap.R](src/bootstrap.R)** — entry point sourced by every runner. Loads all packages via `pacman::p_load` (tidyverse, sf, ggplot2, WDI, restatis, httr2, etc.) and sources `config.R`, `theme.R`, `render.R`, and everything in `fetch/`, `transform/`, and `plot/`. Authentication is deliberately not performed during bootstrap: each user configures `restatis` once with `gen_auth_save("genesis", use_token = TRUE)` for an API token or `use_token = FALSE` for username/password. No credentials or encryption keys belong in the repository.
- **[src/config.R](src/config.R)** — global constants: `DATA_START_YEAR`, `OUT_DIR`, `CACHE_DIR`, and default render settings (`OUT_FORMAT`, `OUT_WIDTH/HEIGHT/DPI`).
- **`src/fetch/`** — one adapter per data source (`fetch_genesis.R` for Destatis GENESIS via `restatis`, `fetch_wdi.R` for World Bank WDI, `fetch_bundesbank.R` for the Bundesbank REST API, `fetch_excel.R` for local spreadsheets). Every fetcher normalizes its source into a common tibble shape: `date, value, series, unit, geo`. `fetch_genesis.R` also holds GENESIS-specific parsing helpers (`parse_genesis()`, date-dimension handling, German→ISO3C country name mapping) and the domain-specific fetchers used by trade graphs (state trade, trade-by-country, commodity structure, deviation vs. Germany).
- **`src/fetch/cache.R`** — `with_cache(key, expr)` memoizes any fetch call to `cache/<key>.rds`; cache keys are chosen per call site (typically source table + params + `DATA_START_YEAR`) and are not invalidated automatically.
- **`src/transform/`** — small reusable data transforms: `growth_rate.R` (`yoy_growth()`), `index_rebase.R`, `seasonal_adjust.R`.
- **[src/theme.R](src/theme.R)** — HWWI brand colors (`blue`, `rubin`, `hwwi_palette`, etc.) and `theme_hwwi()`, the shared ggplot2 theme used by every plot builder.
- **`src/plot/`** — one builder per chart type (`plot_timeseries.R`, `plot_bar.R`, `plot_choropleth.R`, `plot_pie.R`, `plot_dual_axis.R`, `plot_bar_deviation.R`, `plot_bar_ranking.R`). These take already-normalized data plus labels/captions/number-formatting args (`decimal_mark`, `big_mark`) and return a ggplot object; they know nothing about data sources.
- **`src/graphs/<category>/*.R`** (`gdp/`, `employment/`, `prices/`, `trade/`) — the graph "specs": one function per logical graph (e.g. `gdp_world_development()`, `ger_bip_annual_growth()`) that wires a fetcher (via `with_cache`) → optional transform → a plot builder, parameterized by `y_axis`, `caption`, `decimal_mark`, `big_mark` so the same function produces both language variants. Several specs in the same file share one cached raw fetch (e.g. all `ger_bip_annual_*` functions in `ger_bip_annual.R` reuse GENESIS table `81000-0001`).
- **[src/graph_modules.R](src/graph_modules.R)** — discovers graph files in isolated environments, collects their `.graph_specs`, validates required fields and unique IDs, and supports running a graph file directly with `Rscript`.
- **[src/render.R](src/render.R)** — `render_graph()` creates the output directory and saves a plot with `ggplot2::ggsave()`. CLI options can make it skip one language and replace each graph spec's output path with one flat output directory.
- **[src/cli.R](src/cli.R)** — loads `bootstrap.R`, calls `discover_graphs()`, renders the numbered/category menu, parses IDs, numbers, ranges, categories, or `all`, and runs each selected entry with per-entry error isolation.

### Adding a new graph

See [ADDING_GRAPHS.md](ADDING_GRAPHS.md) for the full walkthrough. In short: create one file under `src/graphs/<category>/`, add the fetch/transform/plot function and its `.graph_specs` entry in that same file, then run the file directly. No central registration step is required.
