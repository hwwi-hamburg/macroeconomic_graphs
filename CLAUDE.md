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

# Override DATA_START_MONTH for this run only; output goes to a separate
# out/custom start <YYYY[-MM]>/ tree instead of the standard out/
Rscript src/cli.R --start-year=1995 gdp
Rscript src/cli.R --start-month=1995-06 gdp

# Flatten selected output into out/monthly-report/ and render one language
Rscript src/cli.R --output-folder=monthly-report --language=en gdp

# Category-specific batch runners (used e.g. for scheduled/partial refreshes)
Rscript src/run_gdp.R
Rscript src/run_employment_prices.R
Rscript src/run_trade.R
```

`src/cli.R` accepts an optional leading `render` verb which is stripped (e.g. `Rscript src/cli.R render all`), plus `--start-year=YYYY`, `--start-month=YYYY-MM`, `--output-folder=NAME`, and `--language=de|en`. Use `--start-year` or `--start-month`, not both. The output-folder option writes all selected files directly into `out/NAME/`; it deliberately removes category/language subfolders.

Output is written to `out/<Category> graphs/<German|English> labeling/<title>.jpeg`. Fetched data is memoized to `cache/*.rds` (see `with_cache()`/`bust_cache()` in [src/fetch/cache.R](src/fetch/cache.R)) — delete the relevant `.rds` or call `bust_cache()` to force a refetch.

### `--start-year` / `--start-month` override

`DATA_START_MONTH` ([src/config.R](src/config.R)) is a `"YYYY-MM"` string (default `"2000-01"`) and, together with `OUT_DIR`, a plain global variable. Every fetcher/spec reads `DATA_START_MONTH` as a free variable — not via `genesis_fetch()`/`fetch_wdi()`'s own `start_month`/`start` defaults, which always mean "the entire available history" (see below), but via a downstream trim: `trim_start_month()`, or a direct `dplyr::filter(date >= as.Date(paste0(DATA_START_MONTH, "-01")))` such as the one in `graphs/gdp/ger_bip_annual.R`. Because R resolves free variables and default-argument promises at call time, not at function-definition time, reassigning `DATA_START_MONTH` after `bootstrap.R` is sourced but before any `render()` is called changes every graph's display window without touching the ~50 individual spec files.

`src/cli.R` uses exactly this: `--start-year=YYYY` (normalized to `"YYYY-01"`) or `--start-month=YYYY-MM` reassigns `DATA_START_MONTH` and `OUT_DIR <- file.path(OUT_DIR, "custom start YYYY[-MM]")` right after `bootstrap.R` runs (see the top of [src/cli.R](src/cli.R)); the two flags are mutually exclusive. Cache keys do **not** embed `DATA_START_MONTH` — fetchers always pull the full history (GENESIS/WDI's own defaults), so a custom start reuses the default run's cache instead of triggering a separate fetch; only the trim step downstream sees the new value. Snapshot-style graphs that fetch a single fixed year (trade structure pies, country choropleths) don't reference `DATA_START_MONTH` at all and are unaffected by either flag — that's expected, not a bug.

There is no test suite or lint config in this repo.

## Architecture

The pipeline for every graph is: **fetch → cache → transform → plot → render**. Each file in `src/graphs/` contains both its implementation and `.graph_specs` metadata; the CLI discovers these modules at runtime.

- **[src/bootstrap.R](src/bootstrap.R)** — entry point sourced by every runner. Loads all packages via `pacman::p_load` (tidyverse, sf, ggplot2, WDI, restatis, httr2, etc.) and sources `config.R`, `theme.R`, `render.R`, and everything in `fetch/`, `transform/`, and `plot/`. Authentication is deliberately not performed during bootstrap: each user configures `restatis` once with `gen_auth_save("genesis", use_token = TRUE)` for an API token or `use_token = FALSE` for username/password. No credentials or encryption keys belong in the repository.
- **[src/config.R](src/config.R)** — global constants: `DATA_START_MONTH` (a `"YYYY-MM"` string), `OUT_DIR`, `CACHE_DIR`, default render settings (`OUT_FORMAT`, `OUT_WIDTH/HEIGHT/DPI`), and `start_month_year()`, a helper that pulls the year out of `DATA_START_MONTH` (or a bare year) for GENESIS/WDI APIs that only understand years.
- **`src/fetch/`** — one adapter per data source (`fetch_genesis.R` for Destatis GENESIS via `restatis`, `fetch_wdi.R` for World Bank WDI, `fetch_bundesbank.R` for the Bundesbank REST API, `fetch_excel.R` for local spreadsheets). Every fetcher normalizes its source into a common tibble shape: `date, value, series, unit, geo`, and — for time-series fetches — defaults to the entire available history rather than narrowing by `DATA_START_MONTH`; graph modules trim to the display window afterwards. `fetch_genesis.R` also holds GENESIS-specific parsing helpers (`parse_genesis()`, date-dimension handling, German→ISO3C country name mapping) and the domain-specific fetchers used by trade graphs (state trade, trade-by-country, commodity structure, deviation vs. Germany).
- **`src/fetch/cache.R`** — `with_cache(key, expr)` memoizes any fetch call to `cache/<key>.rds` and auto-refetches at most once per calendar month (based on the cached file's mtime). Cache keys are chosen per call site (source table + any fixed filter params) and deliberately exclude `DATA_START_MONTH`, since the underlying fetch doesn't depend on it.
- **`src/transform/`** — small reusable data transforms: `growth_rate.R` (`yoy_growth()`), `index_rebase.R`, `seasonal_adjust.R`.
- **[src/theme.R](src/theme.R)** — loads the shared HWWI theme from the `hwwi-theme` git submodule (brand colors `hwwi_blue`, `hwwi_rubin`, `hwwi_palette_default`, etc., and `theme_hwwi()`), and adds project extensions (`wrap_axis_label()`, `theme_hwwi(no_axes = TRUE)`, extra packages). Clone with `--recursive` or run `git submodule update --init`.
- **`src/plot/`** — one builder per chart type (`plot_timeseries.R`, `plot_bar.R`, `plot_choropleth.R`, `plot_pie.R`, `plot_dual_axis.R`, `plot_bar_deviation.R`, `plot_bar_ranking.R`). These take already-normalized data plus labels/source-caption/number-formatting args (`decimal_mark`, `big_mark`) and return a ggplot object; they know nothing about data sources.
- **`src/graphs/<category>/*.R`** (`gdp/`, `employment/`, `prices/`, `trade/`) — the graph "specs": one function per logical graph (e.g. `gdp_world_development()`, `ger_bip_annual_growth()`) that wires a fetcher (via `with_cache`) → optional transform → a plot builder, parameterized by `y_axis`, `source`, `decimal_mark`, `big_mark` so the same function produces both language variants. Several specs in the same file share one cached raw fetch (e.g. all `ger_bip_annual_*` functions in `ger_bip_annual.R` reuse GENESIS table `81000-0001`).
- **[src/graph_modules.R](src/graph_modules.R)** — discovers graph files in isolated environments, collects their `.graph_specs`, validates required fields and unique IDs, and supports running a graph file directly with `Rscript`.
- **[src/render.R](src/render.R)** — `render_graph()` creates the output directory and saves a plot with `ggplot2::ggsave()`. CLI options can make it skip one language and replace each graph spec's output path with one flat output directory.
- **[src/cli.R](src/cli.R)** — loads `bootstrap.R`, calls `discover_graphs()`, renders the numbered/category menu, parses IDs, numbers, ranges, categories, or `all`, and runs each selected entry with per-entry error isolation.

### Adding a new graph

See [ADDING_GRAPHS.md](ADDING_GRAPHS.md) for the full walkthrough. In short: create one file under `src/graphs/<category>/`, add the fetch/transform/plot function and its `.graph_specs` entry in that same file, then run the file directly. No central registration step is required.
