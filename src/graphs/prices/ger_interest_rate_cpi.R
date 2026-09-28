# ECB deposit facility rate and German CPI inflation rate on one shared percentage axis.
# ECB rate fetched from FRED public CSV (ECBDFR series, daily → monthly average).
# Inflation from Destatis GENESIS table 61111-0002 (monthly YoY CPI change).

.fetch_ecb_deposit_rate <- function() {
  r <- tryCatch(
    httr2::request("https://fred.stlouisfed.org/graph/fredgraph.csv") |>
      httr2::req_url_query(id = "ECBDFR") |>
      httr2::req_perform() |>
      httr2::resp_body_string(),
    error = function(e) NULL
  )
  if (is.null(r)) stop("Could not fetch ECB deposit rate from FRED")
  raw <- utils::read.csv(textConnection(r), stringsAsFactors = FALSE)
  raw$date   <- as.Date(raw$observation_date)
  raw$value  <- suppressWarnings(as.numeric(raw$ECBDFR))
  raw <- raw[!is.na(raw$value), ]
  # Compute monthly average from daily data
  raw$month <- format(raw$date, "%Y-%m")
  monthly <- tapply(raw$value, raw$month, mean, na.rm = TRUE)
  tibble::tibble(
    date   = as.Date(paste0(names(monthly), "-01")),
    value  = as.numeric(monthly),
    series = "ecb_deposit_rate",
    unit   = "%",
    geo    = "EA"
  )
}

ger_interest_rate_cpi <- function(source,
                                   label_rate       = "EZB-Einlagenzins",
                                   label_inflation  = "Inflationsrate",
                                   y_axis           = "Zins- und Inflationsrate (in %)",
                                   decimal_mark     = ",",
                                   big_mark         = ".") {
  ecb <- .fetch_ecb_deposit_rate() |>
    dplyr::filter(date >= as.Date(paste0(DATA_START_MONTH, "-01"))) |>
    dplyr::mutate(series = label_rate)

  inflation <- fetch_ger_cpi_yoy(series_name = label_inflation)

  dat <- dplyr::bind_rows(ecb, inflation)
  plot_timeseries_multi(
    dat,
    y_axis = y_axis,
    source = source,
    colors = c(blue, rubin),
    decimal_mark = decimal_mark,
    big_mark = big_mark,
    x_breaks = "2 years"
  )
}

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "ger_interest_rate_cpi", category = "Prices", label = "Germany: ECB Deposit Rate and Inflation Rate",
    render = function() {
        GER <- file.path(OUT_DIR, "prices graphs/German labeling")
        EN <- file.path(OUT_DIR, "prices graphs/English labeling")
        render_graph(ger_interest_rate_cpi(source = "Datenquelle: EZB / FRED, Statistisches Bundesamt (Destatis)",
            label_rate = "EZB-Einlagenzins", label_inflation = "Inflationsrate",
            y_axis = "Zins- und Inflationsrate (in %)", decimal_mark = ","), "GER ECB rate and inflation_ger",
            GER)
        render_graph(ger_interest_rate_cpi(source = "Data source: ECB / FRED, Federal statistical office (Destatis)",
            label_rate = "ECB deposit rate", label_inflation = "Inflation rate",
            y_axis = "Interest and inflation rate (in %)", decimal_mark = ".", big_mark = ","), "GER ECB rate and inflation_en",
            EN)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/prices/ger_interest_rate_cpi.R", .graph_specs)
