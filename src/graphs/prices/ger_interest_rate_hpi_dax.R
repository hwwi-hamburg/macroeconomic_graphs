# ECB interest rate band (deposit/lending ribbon) + ECB main rate +
# German House Price Index (GENESIS 61262-0001, annual) +
# DAX index (Yahoo Finance ^GDAXI, monthly).
# HPI and DAX are rebased to 100 at DATA_START_MONTH and scaled to the left (rate) axis.

.fetch_dax_monthly <- function() {
  r <- tryCatch(
    httr2::request("https://query1.finance.yahoo.com/v8/finance/chart/%5EGDAXI") |>
      httr2::req_url_query(interval = "1mo", range = "25y") |>
      httr2::req_headers("User-Agent" = "Mozilla/5.0") |>
      httr2::req_timeout(30) |>
      httr2::req_perform() |>
      httr2::resp_body_string(),
    error = function(e) NULL
  )
  if (is.null(r)) stop("Could not fetch DAX from Yahoo Finance")
  parsed <- jsonlite::fromJSON(r)
  times  <- as.POSIXct(parsed$chart$result$timestamp[[1]], origin = "1970-01-01", tz = "UTC")
  closes <- parsed$chart$result$indicators$quote[[1]]$close[[1]]
  tibble::tibble(
    date  = as.Date(format(times, "%Y-%m-01")),
    value = as.numeric(closes)
  ) |>
    dplyr::filter(!is.na(value)) |>
    dplyr::arrange(date)
}

ger_interest_rate_hpi_dax <- function(source,
                                       label_band   = "Zinsband",
                                       label_ecb    = "Hauptrefinanzierungssatz der EZB",
                                       label_hpi    = "Häuserpreisindex",
                                       label_dax    = "DAX",
                                       y_axis_left  = "Zinssatz in %",
                                       y_axis_right = "Indexwert (Start = 100)",
                                       decimal_mark = ",") {
  start <- as.Date(paste0(DATA_START_MONTH, "-01"))

  ecb_deposit <- fetch_bundesbank_series("BBIN1", "M.D0.ECB.ECBFAC.EUR.ME") |>
    dplyr::filter(date >= start)
  ecb_lending <- fetch_bundesbank_series("BBIN1", "M.D0.ECB.ECBREF.EUR.ME") |>
    dplyr::filter(date >= start)
  ecb_main    <- fetch_bundesbank_series("BBIN1", "M.D0.ECB.ECBMIN.EUR.ME") |>
    dplyr::filter(date >= start)

  raw_hpi <- with_cache("genesis_61262-0001",
                         genesis_fetch("61262-0001"))
  hpi <- parse_genesis(raw_hpi,
                        value_var     = "PRE026",
                        class_filters = list("1_variable_attribute_code" = "DG"),
                        series_name   = label_hpi,
                        geo           = "DEU") |>
    dplyr::filter(date >= start) |>
    dplyr::arrange(date)

  dax <- with_cache("dax_monthly", .fetch_dax_monthly()) |>
    dplyr::filter(date >= start)

  # Rebase both indices to 100 at the first available observation >= start
  hpi_ref <- hpi$value[1]
  dax_ref <- dax$value[which.min(abs(dax$date - start))]
  hpi <- dplyr::mutate(hpi, value = value / hpi_ref * 100)
  dax <- dplyr::mutate(dax, value = value / dax_ref * 100)

  max_idx      <- max(c(hpi$value, dax$value), na.rm = TRUE)
  max_ecb      <- max(ecb_main$value, na.rm = TRUE)
  scale_factor <- max_idx / max_ecb

  ecb_ribbon <- dplyr::inner_join(
    dplyr::rename(ecb_deposit, ymin = value),
    dplyr::rename(ecb_lending, ymax = value),
    by = "date"
  )

  ggplot2::ggplot() +
    ggplot2::geom_ribbon(data = ecb_ribbon,
      ggplot2::aes(x = date, ymin = ymin, ymax = ymax, fill = label_band), alpha = 0.5) +
    ggplot2::scale_fill_manual("", values = setNames("gray70", label_band)) +
    ggplot2::geom_line(data = ecb_main,
      ggplot2::aes(x = date, y = value, color = label_ecb), linewidth = 1.4) +
    ggplot2::geom_line(data = hpi,
      ggplot2::aes(x = date, y = value / scale_factor, color = label_hpi), linewidth = 1.4) +
    ggplot2::geom_line(data = dax,
      ggplot2::aes(x = date, y = value / scale_factor, color = label_dax), linewidth = 1.4) +
    ggplot2::scale_color_manual("",
      values = setNames(c(hwwi_dark_grey, hwwi_rubin, hwwi_blue),
                        c(label_ecb, label_hpi, label_dax))) +
    ggplot2::scale_x_date(date_breaks = "2 years", date_labels = "%Y",
                          limits = c(start, max(dax$date, na.rm = TRUE)),
                          expand = c(0, 0)) +
    ggplot2::scale_y_continuous(
      name     = wrap_axis_label(y_axis_left),
      labels   = function(x) format(x, decimal.mark = decimal_mark, scientific = FALSE),
      sec.axis = ggplot2::sec_axis(~ . * scale_factor, name = wrap_axis_label(y_axis_right),
                                    labels = function(x) format(x, decimal.mark = decimal_mark,
                                                                 scientific = FALSE))
    ) +
    ggplot2::labs(x = "", caption = source) +
    theme_hwwi() +
    ggplot2::theme(legend.position = "bottom") +
    ggplot2::guides(
      color = ggplot2::guide_legend(nrow = 2, order = 1),
      fill  = ggplot2::guide_legend(order = 2)
    )
}

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "ger_interest_rate_hpi_dax", category = "Prices", label = "Development of Interest Rates, House Price Index and DAX",
    notes = "House price index (annual) and DAX (monthly) rebased to 100 at the start of the period, own calculation. ECB band: deposit facility rate to marginal lending rate. Sources: Bundesbank, GENESIS 61262-0001, Yahoo Finance.",
    render = function() {
        DE <- file.path(OUT_DIR, "prices graphs/German labeling")
        EN <- file.path(OUT_DIR, "prices graphs/English labeling")
        render_graph(ger_interest_rate_hpi_dax(source = "Datenquelle: Destatis, Deutsche Bundesbank, Yahoo Finance",
            label_band = "Zinsband", label_ecb = "Hauptrefinanzierungssatz der EZB", label_hpi = "Häuserpreisindex",
            label_dax = "DAX", y_axis_left = "Zinssatz in %", y_axis_right = "Indexwert (Start = 100)",
            decimal_mark = ","), "Development of interest rates, german house-price-index and dax index_de",
            DE)
        render_graph(ger_interest_rate_hpi_dax(source = "Data source: Destatis, German Federal Bank, Yahoo Finance",
            label_band = "Interest rate band", label_ecb = "ECB interest rate for main refinancing operations",
            label_hpi = "House price index", label_dax = "DAX", y_axis_left = "Interest rate in %", y_axis_right = "Index value (Start = 100)",
            decimal_mark = "."), "Development of interest rates, german house-price-index and dax index_en",
            EN)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/prices/ger_interest_rate_hpi_dax.R", .graph_specs)
