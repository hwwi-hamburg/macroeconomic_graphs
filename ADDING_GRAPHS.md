# Adding a New Graph
Extending the graphs library requires two steps. First, using the predefined building blocks, give a code specification of the graph to be created. 
Afterwards, add the metadata of the graph to the bottom of the file.

## Steps to adding a Graph
The code specification is divided into three stages: 
1. Fetch the data
2. Transform the data as necessary
3. Plot it using one of the predefined plotting helpers

For each stage, this library includes predefined helper functions to simplify the flow. 
First, in the next subsection, we explain the fundamental data type of this project.
Then, in Section 0, we show a small real example that uses one of the plot helpers; the later sections serve as a reference for the helper functions behind the graph generation flow.

## The Data Tibble

The flow is based on a data tibble which has 5 fields:

```r
tibble(date, value, series, unit, geo)
```

For all plots that are based on time series, the `date` and `value` fields are necessary. The `date` field is of type `Date` and the `value` field is numeric. More specialized plots may require other fields. The plot-builder reference [below](#3-pick-a-plot-builder) lists the necessary fields for every helper.

## Folder structure
The code for this project is located in src. 
The following tree shows the structure of the src folder and the location of the graph files.

```
src
└── graphs # Put new files in 
           # folders below
    ├── gdp
    └── employment
    └── trade
    └── prices
└── fetch  # fetching helpers 
└── transform # transformations
└── plot # plotting helpers

```
Put new graph files in the respective subfolder of `src/graphs/`.

## 1. Example Graph
This is a simple real module from [src/graphs/gdp/ger_bip_annual.R](src/graphs/gdp/ger_bip_annual.R).

Just have a look at the code to get an idea of the structure of a graph file. 

```r
# Wrap the plot logic in a function
ger_bip_annual_growth <- function(y_axis, caption, decimal_mark = ",") {
  # 1. Fetch the raw data
  raw <- with_cache(paste0("genesis_81000-0001_", DATA_START_YEAR),
                    genesis_fetch("81000-0001"))

  # 2. Parse the series you want to plot
  dat <- parse_genesis(
    raw,
    value_var     = "BIP005",
    class_filters = list("2_variable_attribute_code" = "VGRPKM"),
    series_name   = "gdp_growth_annual",
    geo           = "DEU"
  )

  # 3. Build the chart with a plot helper
  plot_timeseries(dat, y_axis = y_axis, caption = caption,
                  decimal_mark = decimal_mark, big_mark = ".")
}

# 4. Add graph metadata for discovery and rendering
.graph_specs <- list(
  list(
    id = "ger_bip_annual_growth",
    category = "GDP",
    label = "Germany Annual GDP Growth (Destatis)",
    render = function() {
      render_graph(
        ger_bip_annual_growth(
          "Kettenindex (2020=100)\nVeränderung in %",
          "Datenquelle: Statistisches Bundesamt (Destatis)"
        ),
        "GER BIP annual growth - chain index_ger",
        file.path(OUT_DIR, "GDP graphs/German labeling")
      )
    }
  )
)

auto_run_graph_file("src/graphs/gdp/ger_bip_annual.R", .graph_specs)
```
The plotting logic is wrapped as a function such that it can be called with different parameters for German and English labeling. 

The plotting logic starts with fetching the raw data from GENESIS. 
Afterwards, the data is parsed into the standard data format by specifying the neccessary filters. 
Then, the data is transformed as necessary, in this case by filtering the data to the requested start year. 
Finally, the plot is built using one of the predefined plot helpers.
In the following sections, each of the steps is explained in more detail.


## General Workflow
The easiest way to create a new graph is to first create an R file in respective folder, e.g. `src/graphs/employment/ger_new_graph.R`.
Then, start by importing the bootstrap file (`src/bootstrap.R`) and just writing out the plotting logic. 
You only need to import the bootstrap file while developing the graph, because it sources all the necessary helpers and sets up the environment.
This way, you can test it in the R console with `Ctrl + Enter`.
![bootstrap.R](doc/bootstrap.png)

Afterwards, delete the bootstrap import, as it is no longer neccessary and wrap this plotting logic in a function and add the graph_spec metadata at the bottom of the file.

![finished code](doc/finished%20code.png)

# Step-by-Step Workflow

## 2. Retrieving and Parsing the Data
In this section, we will explain how to fetch data from each of the available data sources.

### GENESIS
For creating a new graph from a GENESIS table, start in the [GENESIS-Online](https://www-genesis.destatis.de) catalog to find the **table key** used in `genesis_fetch()`.

For parsing the raw results, you usually need three pieces of information: the **value-variable code** to keep, any **classifying filters** for only using a specific subset, and, for lagged calculations, whether you need one extra **pre-roll year**.

To find the right value-variable code and filter values, fetch the raw table first and inspect its columns:

```r
source("src/bootstrap.R")
x <- genesis_fetch("81000-0001")

names(x)
dplyr::distinct(dplyr::select(x, value_variable_code, value_variable_label))

# Filter for the value-variable code you want to plot, and inspect the attribute codes for the other columns:
filtered <- dplyr::filter(x, value_variable_code == "BIP005")
dplyr::distinct(dplyr::select(filtered, dplyr::starts_with("1_variable_attribute")))
dplyr::distinct(dplyr::select(filtered, dplyr::starts_with("2_variable_attribute")))
```

Check the outputs of `value_variable_code` for the series you want to plot. 
Afterwards, use the `*_attribute_code` fields when the table contains multiple regions, units, or classifications and you only want one of them. 

If a graph needs a lagged calculation such as year-on-year growth, fetch one extra year of data with `genesis_fetch_window(..., pre_roll = TRUE)` and trim the visible range later with `trim_start_year()`.

#### `genesis_fetch()`

```r
genesis_fetch(table_key, start_year = DATA_START_YEAR, end_year = 2100, ...)
```

Downloads a raw table from Destatis GENESIS using `restatis::gen_table()`.

Parameters:

- `table_key`: GENESIS table identifier, such as `"81000-0001"`.
- `start_year`: First year to request. Defaults to `DATA_START_YEAR`.
- `end_year`: Last year to request. Defaults to `2100`, allowing GENESIS to return all currently available observations.
- `...`: Additional filters passed to `restatis::gen_table()`, such as `regionalvariable`, `regionalkey`, `classifyingvariable1`, or `classifyingkey1`.

Returns the raw long-format table supplied by GENESIS. Find table identifiers through the [GENESIS-Online](https://www-genesis.destatis.de) catalog.

#### `parse_genesis()`

```r
parse_genesis(
  raw,
  value_var,
  series_name = "value",
  unit = NA_character_,
  geo = "DEU",
  class_filters = NULL,
  unit_filter = NULL,
  scale = 1
)
```

Filters a raw GENESIS result and converts it to `tibble(date, value, series, unit, geo)`. This function is neccessary to extract the relevant value-variable from the often large GENESIS tables. 

Parameters:

- `raw`: Table returned by `genesis_fetch()`.
- `value_var`: Value-variable code to retain, such as `"BIP005"`.
- `series_name`: Constant value written to the output `series` column.
- `unit`: Constant output unit. If `NA`, the first matching GENESIS unit is used.
- `geo`: Constant value written to the output `geo` column. This does not extract changing geographic labels from `raw`.
- `class_filters`: Named list of additional column/value filters, for example `list("2_variable_attribute_code" = "DG")`.
- `unit_filter`: Optional GENESIS unit to retain before parsing, such as `"2020=100"`.
- `scale`: Multiplier applied to every parsed value, for example `1 / 1e6` to convert thousand euros to billion euros.

Returns a tibble in the standard shape.

### WDI
#### `fetch_wdi()`

```r
fetch_wdi(
  indicator,
  country,
  start = DATA_START_YEAR,
  end = as.integer(format(Sys.Date(), "%Y"))
)
```

Downloads an annual indicator from the World Bank WDI API and converts it to the standard shape.

Parameters:

- `indicator`: WDI indicator code, such as `"NY.GDP.PCAP.PP.KD"`.
- `country`: ISO3C country code, WDI aggregate code such as `"1W"`, or a vector of codes.
- `start`: First year to request.
- `end`: Last year to request. Defaults to the current year.

Returns `tibble(date, value, series, unit, geo)`.

### Bundesbank
#### `fetch_bundesbank_series()`

```r
fetch_bundesbank_series(dataset, key)
```

Downloads one series directly from the Bundesbank SDMX REST API.

Parameters:

- `dataset`: Bundesbank SDMX dataset identifier.
- `key`: Series key within the dataset.

Example: You can find Bundesbank time series on the [website](https://statistiken.bundesbank.de/statistiken-de/suche). 
The time series "Harmonisierter Verbraucherpreisindex / Deutschland / Ursprungswerte / Insgesamt / % gegen Vorjahr" has the time series code `BBDP1.​M.​DE.​N.​HVPI.​C.​A00000.​VGJ.​LV`. The first part BBDP1 is the dataset, and the rest is the series key.

Returns `tibble(date, value)`. Add `series`, `unit`, and `geo` columns if the selected plot builder requires them.

### Excel
#### `fetch_excel()`

```r
fetch_excel(
  path,
  sheet = 1,
  date_col,
  value_col,
  series_name = "value",
  unit = NA_character_,
  geo = NA_character_,
  date_format = "%Y-%m-%d",
  skip = 0
)
```

Reads one date/value series from a local Excel worksheet and converts it to the standard shape.

Parameters:

- `path`: Path to the Excel workbook.
- `sheet`: Sheet name or number. Defaults to the first sheet.
- `date_col`: Name or position of the column containing dates.
- `value_col`: Name or position of the column containing values.
- `series_name`: Constant value written to the output `series` column.
- `unit`: Constant value written to the output `unit` column.
- `geo`: Constant value written to the output `geo` column.
- `date_format`: Format used to parse character dates.
- `skip`: Number of rows to skip before reading the worksheet.

Returns `tibble(date, value, series, unit, geo)`.

If none of these fit, add a new `src/fetch/fetch_<source>.R` file with a function that returns the same `date, value, series, unit, geo` shape, and source it from [src/bootstrap.R](src/bootstrap.R).

Trade graphs also have higher-level domain fetchers in `fetch_genesis.R` (`fetch_hh_trade()`, `fetch_ger_trade_by_country()`, `fetch_state_deviation()`, etc.) worth checking before writing raw GENESIS calls from scratch.

## 3. Cache the raw fetch

Use `with_cache()` for any source that is expensive to fetch or likely to be reused. Include every parameter that changes the returned data in the cache key. For GENESIS graphs with a pre-roll year, key the cache on the display start year and the pre-roll flag, just like the graph modules do.

For GENESIS time-series graphs, `genesis_fetch_window(..., pre_roll = TRUE)` fetches one extra year before the visible range, and `trim_start_year()` removes that extra history after parsing or transformation.

#### `with_cache()`

```r
with_cache(key, expr, cache_dir = CACHE_DIR)
```

Returns a saved result when one exists; otherwise, evaluates the expression and saves its result as an RDS file.

Parameters:

- `key`: Unique cache identifier. Include every fetch parameter that changes the result.
- `expr`: Fetch expression to evaluate on a cache miss.
- `cache_dir`: Directory containing the RDS cache files. Defaults to `CACHE_DIR`.

Include `DATA_START_YEAR` in `key` whenever the fetch depends on it. This ensures that the `--start-year=YYYY` CLI option selects a separate cache entry (see [CLAUDE.md](CLAUDE.md#--start-year-override)):

```r
raw <- with_cache(paste0("genesis_81000-0001_", DATA_START_YEAR),
                  genesis_fetch("81000-0001"))
```

For snapshot-style data (a single year, e.g. trade-structure pies), key by that year instead:

```r
raw <- with_cache(paste0("genesis_51000-0005_", year), fetch_ger_trade_commodity(year))
```

## 4. Transform

`src/transform/` has three helpers:
#### `yoy_growth()`

```r
yoy_growth(dat, value_col = "value", lag_periods = 1)
```

Replaces a value column with its percentage change from the selected lag.

Parameters:

- `dat`: Data frame containing `date` and the value column. For multiple series, group the data before calling this function.
- `value_col`: Name of the column to transform.
- `lag_periods`: Number of rows to lag after sorting by `date`. Use `1` for annual data and `12` for monthly year-over-year growth.

Returns `dat` with the selected value column expressed as percentage growth. The first `lag_periods` values are `NA`.

#### `rebase_index()`

```r
rebase_index(dat, base_year, value_col = "value")
```

Rebases a series so that the mean observation in the selected year equals 100.

Parameters:

- `dat`: Data frame containing `date` and the value column.
- `base_year`: Calendar year to use as the index base.
- `value_col`: Name of the column to rebase.

Returns `dat` with the selected value column converted to the rebased index.

#### `seasonal_adjust()`

```r
seasonal_adjust(dat)
```

Applies monthly X-13ARIMA-SEATS seasonal adjustment using the `seasonal` package.

Parameters:

- `dat`: Data frame containing a monthly `date` column and a numeric `value` column.

Returns the input data with `value` replaced by the adjusted series. It returns the unadjusted data if the package is unavailable or adjustment fails.

Most GENESIS tables already offer seasonally adjusted or chain-indexed variants as a `class_filters` code (see the `ger_bip_*` specs), which is preferred over adjusting client-side.

When a graph needs lagged growth calculations, prefer `genesis_fetch_window(..., pre_roll = TRUE)` plus `trim_start_year()` over manual date filtering inside the graph module.

## 5. Pick a plot builder

All builders are located in `src/plot/` and append the current year to `caption`. Most apply `theme_hwwi()` automatically; `plot_pie()` uses `ggplot2::theme_void()` with its own caption and margin styling.

#### `plot_timeseries()`

```r
plot_timeseries(
  dat, y_axis, caption,
  decimal_mark = ".", big_mark = ",",
  color = blue, x_breaks = "5 years",
  y_limits = NULL, y_breaks = ggplot2::waiver(), linewidth = 1.8
)
```

Creates a single-series line chart.

Required fields for the data tibble:

- `date`: `Date` values used on the x-axis.
- `value`: Numeric observations used on the y-axis.

The standard `series`, `unit`, and `geo` fields are not required.

Parameters:

- `dat`: Data frame containing `date` and `value`.
- `y_axis`: Y-axis title.
- `caption`: Source caption.
- `decimal_mark`: Decimal separator used in value labels.
- `big_mark`: Thousands separator used in value labels.
- `color`: Line color.
- `x_breaks`: Date-break interval accepted by `ggplot2::scale_x_date()`.
- `y_limits`: Optional two-element vector of y-axis limits.
- `y_breaks`: Y-axis breaks or a ggplot2 waiver.
- `linewidth`: Width of the plotted line.

An example can be found [here](src/graphs/employment/ger_employed_seasonal.R). 

#### `plot_timeseries_multi()`

```r
plot_timeseries_multi(
  dat, y_axis, caption, labels = NULL,
  decimal_mark = ".", big_mark = ",",
  colors = hwwi_palette, x_breaks = "5 years",
  y_limits = NULL, linewidth = 1.8
)
```

Creates a multiple-series line chart using the `series` column. 
The series attribute gets added by the fetching function, so the to data tibble only have to be combined with dplyr::bind_rows(). 
The series names from the tibbles will be displayed below the plot as a legend.

Required fields for the data tibble:

- `date`: `Date` values used on the x-axis.
- `value`: Numeric observations used on the y-axis.
- `series`: Character or factor identifier used to separate and color the lines.

The standard `unit` and `geo` fields are not required.

Parameters:

- `dat`: Data frame containing `date`, `value`, and `series`.
- `y_axis`: Y-axis title.
- `caption`: Source caption.
- `labels`: Optional legend labels in series order.
- `decimal_mark`: Decimal separator used in value labels.
- `big_mark`: Thousands separator used in value labels.
- `colors`: Vector of line colors.
- `x_breaks`: Date-break interval.
- `y_limits`: Optional two-element vector of y-axis limits.
- `linewidth`: Width of the plotted lines.

An example can be found [here](src/graphs/employment/ger_unemployed_west_east.R). 

#### `plot_bar_date()`

```r
plot_bar_date(
  dat, y_axis, caption, labels = NULL,
  decimal_mark = ".", big_mark = ",",
  colors = c(scales::alpha(blue, 0.6), rubin),
  x_breaks = "2 years", y_limits = NULL
)
```

Creates overlapping bars on a date axis using the `series` column. Set factor levels so the series that should appear behind is drawn first.

Required fields for the data tibble:

- `date`: `Date` values used on the x-axis.
- `value`: Numeric observations determining bar heights.
- `series`: Character or factor identifier used to group and color the bars.

The standard `unit` and `geo` fields are not required.

Parameters:

- `dat`: Data frame containing `date`, `value`, and `series`.
- `y_axis`: Y-axis title.
- `caption`: Source caption.
- `labels`: Optional legend labels in series order.
- `decimal_mark`: Decimal separator used in value labels.
- `big_mark`: Thousands separator used in value labels.
- `colors`: Fill colors in series order.
- `x_breaks`: Date-break interval.
- `y_limits`: Optional two-element vector of y-axis limits.

An example can be found [here](src/graphs/trade/hh_trade_monthly.R).

#### `plot_bar_growth()`

```r
plot_bar_growth(
  dat, y_axis, caption,
  decimal_mark = ".", color = blue, x_breaks = "2 years"
)
```

Creates annual growth bars with percentage labels.

Required fields for the data tibble:

- `date`: `Date` values used on the x-axis.
- `value`: Numeric percentage values determining bar heights and labels.

The standard `series`, `unit`, and `geo` fields are not required.

Parameters:

- `dat`: Data frame containing `date` and percentage `value`.
- `y_axis`: Y-axis title.
- `caption`: Source caption.
- `decimal_mark`: Decimal separator used in percentage labels.
- `color`: Bar color.
- `x_breaks`: Date-break interval.

An example can be found [here](src/graphs/gdp/income_gdppc_growth.R). 

#### `plot_bar()`

```r
plot_bar(
  dat, y_axis, caption, labels = NULL,
  decimal_mark = ".",
  colors = c(alpha(blue, 0.9), alpha(rubin, 0.9)),
  y_limits = NULL, position = "dodge"
)
```

Creates grouped bars on a date axis. It uses the standard data-tibble fields directly and labels every observed date by year.

Required fields for the data tibble:

- `date`: `Date` values used on the x-axis.
- `value`: Numeric observations determining bar heights.
- `series`: Character or factor identifier used to group and color the bars.

The standard `unit` and `geo` fields are not required.

Parameters:

- `dat`: Data frame containing `date`, `value`, and `series`.
- `y_axis`: Y-axis title.
- `caption`: Source caption.
- `labels`: Optional legend labels in group order.
- `decimal_mark`: Decimal separator used in value labels.
- `colors`: Fill colors in group order.
- `y_limits`: Optional two-element vector of y-axis limits.
- `position`: Bar-position adjustment, such as `"dodge"`, `"stack"`, or `"identity"`.

An example can be found [here](src/graphs/trade/ger_export_development_nominal_real.R).

#### `plot_bar_deviation()`

```r
plot_bar_deviation(
  dat, caption,
  x_axis = "",
  decimal_mark = ".", big_mark = ",",
  positive_label = "Above average", negative_label = "Below average",
  colors = c(blue, rubin)
)
```

Creates horizontal diverging bars around zero.

Required fields for the data tibble:

- `series`: Character or factor category labels displayed on the y-axis.
- `value`: Numeric deviations; their signs determine the positive or negative group.

The standard `date`, `unit`, and `geo` fields are not used by this helper.

Parameters:

- `dat`: Standard data tibble containing `series` and `value`.
- `caption`: Source caption.
- `x_axis`: Numeric-axis title.
- `decimal_mark`: Decimal separator used in value labels.
- `big_mark`: Thousands separator used in value labels.
- `positive_label`: Legend label assigned to non-negative values.
- `negative_label`: Legend label assigned to negative values.
- `colors`: Colors for positive and negative bars, respectively.

An example can be found [here](src/graphs/trade/trade_deviation.R).

#### `plot_bar_ranking()`

```r
plot_bar_ranking(
  dat, caption,
  x_axis = "",
  decimal_mark = ".", big_mark = ",", color = blue
)
```

Creates a horizontal ranking bar chart.

Required fields for the data tibble:

- `geo`: Character or factor geographic labels displayed on the y-axis.
- `value`: Numeric observations determining bar lengths.

The standard `date`, `series`, and `unit` fields are not used by this helper.

Parameters:

- `dat`: Standard data tibble containing `geo` and `value`, ordered as the bars should appear in the ranking.
- `caption`: Source caption.
- `x_axis`: Numeric-axis title.
- `decimal_mark`: Decimal separator used in value labels.
- `big_mark`: Thousands separator used in value labels.
- `color`: Bar color.

An example can be found [here](src/graphs/gdp/ger_nominal_gdp_state_growth.R).

#### `plot_dual_axis()`

```r
plot_dual_axis(
  dat, caption,
  y_axis_left, y_axis_right, series_left, series_right,
  decimal_mark = ".", big_mark = ",",
  colors = c(blue, rubin), x_breaks = "5 years",
  y_max_right = NULL, y_min_at_zero = TRUE
)
```

Creates two line series with different units on aligned left and right axes.

Required fields for the data tibble:

- `date`: `Date` values used on the x-axis.
- `value`: Numeric observations to be mapped to the two y-axes.
- `series`: Character or factor identifier. It must contain the values supplied through `series_left` and `series_right`.

The standard `unit` and `geo` fields are not required. Axis units are supplied through `y_axis_left` and `y_axis_right`, not read from `unit`.

Parameters:

- `dat`: Data frame containing `date`, `value`, and `series`.
- `caption`: Source caption.
- `y_axis_left`: Left-axis title.
- `y_axis_right`: Right-axis title.
- `series_left`: Value in `series` assigned to the left axis.
- `series_right`: Value in `series` assigned to the right axis.
- `decimal_mark`: Decimal separator used on both axes.
- `big_mark`: Thousands separator used on both axes.
- `colors`: Colors for the left and right series, respectively.
- `x_breaks`: Date-break interval.
- `y_max_right`: Optional fixed maximum for the right axis.
- `y_min_at_zero`: Whether both axes should start at zero.

An example can be found [here](src/graphs/employment/ger_employed_unemployed.R).

#### `plot_pie()`

```r
plot_pie(
  dat, caption = "", big_mark = ".", decimal_mark = ",", colors = NULL,
  n_inside = 1, inside_x = 1.8, text_size = 3.1,
  start_angle = pi / 5, x_limit = 5.2,
  plot_margin = ggplot2::margin(-70, 200, -20, -20)
)
```

Creates a polar composition chart with value and percentage labels.

Required fields for the data tibble:

- `series`: Character or factor slice labels.
- `value`: Numeric slice sizes. Values should be non-negative and their sum must be greater than zero.

The standard `date`, `unit`, and `geo` fields are not used by this helper.

Parameters:

- `dat`: Standard data tibble containing `series` and `value`.
- `caption`: Source caption.
- `big_mark`: Thousands separator used in value labels.
- `decimal_mark`: Decimal separator used in percentage labels.
- `colors`: Optional vector of slice colors; the HWWI palette is generated when omitted.
- `n_inside`: Number of largest slices whose labels are placed inside the chart.
- `inside_x`: Radial position of inside labels.
- `text_size`: Label-text size.
- `start_angle`: Rotation in radians.
- `x_limit`: Radial plotting limit, including space for outside labels.
- `plot_margin`: ggplot2 margin around the chart.

An example can be found [here](src/graphs/trade/trade_state_pies.R).

#### `plot_choropleth_world()`

```r
plot_choropleth_world(
  dat, fill_col = "value", legend_title = "", caption = "",
  low = "white", high = blue,
  xlim = c(-179, 179), ylim = c(-56, 85)
)
```

Creates a world choropleth with a sequential square-root color scale.

Required fields for the data tibble:

- `geo`: Character ISO3C country codes used to join observations to the world geometry.
- The column named by `fill_col`: Non-negative numeric values used for the map fill; `value` by default.

The standard `date`, `series`, and `unit` fields are not required. Filter time-dependent data to one observation per geography before plotting.

Parameters:

- `dat`: Data frame whose `geo` column contains ISO3C country codes.
- `fill_col`: Name of the numeric fill column.
- `legend_title`: Fill-legend title.
- `caption`: Source caption.
- `low`: Color used at the low end of the scale.
- `high`: Color used at the high end of the scale.
- `xlim`: Longitude limits.
- `ylim`: Latitude limits.

Examples can be found [here](src/graphs/trade/trade_country_choropleths.R).

#### `plot_choropleth_world_div()`

```r
plot_choropleth_world_div(
  dat, fill_col = "value", legend_title = "", caption = "",
  xlim = c(-179, 179), ylim = c(-56, 85)
)
```

Creates a world choropleth with a zero-centered diverging color scale.

Required fields for the data tibble:

- `geo`: Character ISO3C country codes used to join observations to the world geometry.
- The column named by `fill_col`: Numeric values, including negative or positive deviations, used for the map fill; `value` by default.

The standard `date`, `series`, and `unit` fields are not required. Filter time-dependent data to one observation per geography before plotting.

Parameters:

- `dat`: Data frame whose `geo` column contains ISO3C country codes.
- `fill_col`: Name of the numeric fill column.
- `legend_title`: Fill-legend title.
- `caption`: Source caption.
- `xlim`: Longitude limits.
- `ylim`: Latitude limits.

An example can be found [here](src/graphs/trade/trade_deviation.R).

#### `plot_choropleth_ger()`

```r
plot_choropleth_ger(
  dat, fill_col = "value", legend_title = "", caption = "",
  low = rubin, high = dark_rubin
)
```

Creates a choropleth of the German states.

Required fields for the data tibble:

- `geo`: Character German-state names matching the Natural Earth `name` field.
- The column named by `fill_col`: Numeric values used for the map fill; `value` by default.

The standard `date`, `series`, and `unit` fields are not required. Filter time-dependent data to one observation per state before plotting.

Parameters:

- `dat`: Data frame whose `geo` column contains state names matching the map data.
- `fill_col`: Name of the numeric fill column.
- `legend_title`: Fill-legend title.
- `caption`: Source caption.
- `low`: Color used at the low end of the scale.
- `high`: Color used at the high end of the scale.

Brand colors (`blue`, `rubin`, `dark_blue`, `dark_rubin`, `light_blue`, `grey`, `dark_grey`, and the `hwwi_palette`/`hwwi_palette_rb` vectors) are defined in [src/theme.R](src/theme.R) — reuse them rather than hardcoding new colors.

An example can be found [here](src/graphs/gdp/ger_nominal_gdp_state_per_capita.R).

## 6. Write the graph spec function

The final graph is written as a function. 
Add a function under `src/graphs/<category>/` (`gdp/`, `employment/`, `prices/`, or `trade/` — reuse an existing file if your graph is a close relative of what's already there, e.g. shares a cached raw fetch). The function should take `y_axis`/`caption` (or whatever labels the plot needs) plus `decimal_mark`/`big_mark` as arguments, defaulting to German formatting (`decimal_mark = ","`, `big_mark = "."`) since that's the primary audience — the English call overrides them:

```r
# src/graphs/gdp/my_new_graph.R
my_new_graph <- function(y_axis, caption, decimal_mark = ",", big_mark = ".") {
  dat <- with_cache(paste0("genesis_XXXXX-XXXX_", DATA_START_YEAR),
                    genesis_fetch("XXXXX-XXXX")) |>
    parse_genesis(value_var = "...", series_name = "my_series", geo = "DEU") |>
    dplyr::filter(date >= as.Date(paste0(DATA_START_YEAR, "-01-01")))
  plot_timeseries(dat, y_axis = y_axis, caption = caption,
                  decimal_mark = decimal_mark, big_mark = big_mark)
}
```

If a chart needs multiple raw fetches or several closely-related variants (e.g. level/growth/volume from the same table), follow the pattern in [src/graphs/gdp/ger_bip_annual.R](src/graphs/gdp/ger_bip_annual.R): a shared private `.helper()` that both fetches and filters, called by several thin public wrapper functions.

## 7. Add the graph module metadata

At the bottom of the graph file, add an entry to `.graph_specs`. Its `render()` calls your function twice—German first and English second—and writes into the category's two output folders:

```r
.graph_specs <- list(list(
  id = "my_new_graph", category = "GDP",
  label = "My New Graph — short human-readable label for the menu",
  render = function() {
    GER <- file.path(OUT_DIR, "GDP graphs/German labeling")
    EN  <- file.path(OUT_DIR, "GDP graphs/English labeling")
    render_graph(
      my_new_graph("Y-Achsen-Beschriftung", "Datenquelle: Statistisches Bundesamt (Destatis)"),
      "My New Graph title_ger", GER)
    render_graph(
      my_new_graph("Y-axis label", "Data source: Federal statistical office (Destatis)",
                    decimal_mark = ".", big_mark = ","),
      "My New Graph title_en", EN)
  }
))

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/gdp/my_new_graph.R", .graph_specs)
```

Furthermore, at the bottom is boilerplate code to allow standalone execution and debugging.

Conventions to match the existing entries:
- `id`: unique, snake_case, stable (used for logging and error messages — don't rename once graphs are in production use)
- `category`: one of `"GDP"`, `"Employment"`, `"Prices"`, `"Trade"` (drives the menu grouping and the `run_*.R` batch filters)
- In render: 
  - `GER`: output path of the German labeling version
  - `EN`: output path of the English labeling version

## 8. Test it

The file is directly executable, so the fastest end-to-end check is:

```bash
Rscript src/graphs/gdp/my_new_graph.R
```

To inspect intermediate values while iterating, source it without triggering rendering:

```r
source("src/bootstrap.R")
source("src/graphs/gdp/my_new_graph.R")
p <- my_new_graph("Test axis", "Test caption")
render_graph(p, "test_my_new_graph", "out/test")
```

or just `print(p)` in an interactive R session / RStudio viewer to inspect the plot without writing a file.
