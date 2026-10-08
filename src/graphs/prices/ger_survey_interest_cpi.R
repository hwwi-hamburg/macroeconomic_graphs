# Survey: ECB interest rate band (deposit/lending) + FED target rate band +
# ECB main rate + FED EFFR + German CPI YoY.
# ECB rates: Bundesbank SDMX XML API (BBIN1 dataset), monthly.
# FED EFFR + target band: FRED public CSV (DFF / DFEDTARU / DFEDTARL), daily → monthly avg.
# CPI YoY: GENESIS 61111-0002 (PREIS1).
# Both axes share the same % scale (dual labels only).

.fetch_fred_monthly_avg <- function(series_id) {
  r <- tryCatch(
    httr2::request("https://fred.stlouisfed.org/graph/fredgraph.csv") |>
      httr2::req_url_query(id = series_id) |>
      httr2::req_timeout(30) |>
      httr2::req_perform() |>
      httr2::resp_body_string(),
    error = function(e) NULL
  )
  if (is.null(r)) stop("Could not fetch FRED series: ", series_id)
  raw        <- utils::read.csv(textConnection(r), stringsAsFactors = FALSE)
  raw$date   <- as.Date(raw[[1]])
  raw$value  <- suppressWarnings(as.numeric(raw[[2]]))
  raw        <- raw[!is.na(raw$value), ]
  raw$month  <- format(raw$date, "%Y-%m")
  monthly    <- tapply(raw$value, raw$month, mean, na.rm = TRUE)
  tibble::tibble(
    date  = as.Date(paste0(names(monthly), "-01")),
    value = as.numeric(monthly)
  ) |> dplyr::arrange(date)
}

ger_survey_interest_cpi <- function(source,
                                     label_band     = "Interest rate band",
                                     label_effr     = "Effective Federal Funds rate",
                                     label_ecb_main = "ECB interest rate for main refinancing operations",
                                     label_cpi      = "Consumer price index",
                                     y_axis_left    = "Interest rate in %",
                                     y_axis_right   = "Change of consumer price index to previous year's month in %",
                                     decimal_mark   = ".") {
  start <- as.Date(paste0(DATA_START_MONTH, "-01"))

  ecb_deposit <- fetch_bundesbank_series("BBIN1", "M.D0.ECB.ECBFAC.EUR.ME") |>
    dplyr::filter(date >= start)
  ecb_lending <- fetch_bundesbank_series("BBIN1", "M.D0.ECB.ECBREF.EUR.ME") |>
    dplyr::filter(date >= start)
  ecb_main    <- fetch_bundesbank_series("BBIN1", "M.D0.ECB.ECBMIN.EUR.ME") |>
    dplyr::filter(date >= start)

  effr     <- .fetch_fred_monthly_avg("DFF") |>
    dplyr::filter(date >= start)
  fed_u    <- .fetch_fred_monthly_avg("DFEDTARU") |>
    dplyr::filter(date >= start)
  fed_l    <- .fetch_fred_monthly_avg("DFEDTARL") |>
    dplyr::filter(date >= start)

  cpi <- fetch_ger_cpi_yoy(series_name = label_cpi)

  # ECB deposit/lending band
  ecb_ribbon <- dplyr::inner_join(
    dplyr::rename(ecb_deposit, ymin = value),
    dplyr::rename(ecb_lending, ymax = value),
    by = "date"
  )

  # FED target rate band
  fed_ribbon <- dplyr::inner_join(
    dplyr::rename(fed_l, ymin = value),
    dplyr::rename(fed_u, ymax = value),
    by = "date"
  )

  line_dat <- dplyr::bind_rows(
    dplyr::transmute(effr,     date, value, series = label_effr),
    dplyr::transmute(ecb_main, date, value, series = label_ecb_main),
    dplyr::transmute(cpi,      date, value, series = label_cpi)
  )

  ggplot2::ggplot() +
    ggplot2::geom_ribbon(data = ecb_ribbon,
      ggplot2::aes(x = date, ymin = ymin, ymax = ymax, fill = label_band), alpha = 0.5) +
    ggplot2::geom_ribbon(data = fed_ribbon,
      ggplot2::aes(x = date, ymin = ymin, ymax = ymax, fill = label_band), alpha = 0.5) +
    ggplot2::scale_fill_manual("", values = setNames("gray70", label_band)) +
    ggplot2::geom_line(data = line_dat,
      ggplot2::aes(x = date, y = value, color = series), linewidth = 1.4) +
    ggplot2::scale_color_manual("",
      values = setNames(
        c(rubin, dark_grey, blue),
        c(label_cpi, label_ecb_main, label_effr)
      )
    ) +
    ggplot2::geom_hline(yintercept = 2, linetype = "dashed") +
    ggplot2::scale_x_date(date_breaks = "2 years", date_labels = "%Y",
                          limits = c(start, max(cpi$date, na.rm = TRUE)),
                          expand = c(0, 0)) +
    ggplot2::scale_y_continuous(
      name     = wrap_axis_label(y_axis_left),
      labels   = function(x) format(x, decimal.mark = decimal_mark, scientific = FALSE),
      sec.axis = ggplot2::sec_axis(~., name = wrap_axis_label(y_axis_right),
                                    labels = function(x) format(x, decimal.mark = decimal_mark,
                                                                 scientific = FALSE))
    ) +
    ggplot2::labs(x = "", caption = source) +
    theme_hwwi() +
    ggplot2::theme(legend.position = "bottom") +
    ggplot2::guides(
      color = ggplot2::guide_legend(nrow = 2, order = 2),
      fill  = ggplot2::guide_legend(order = 1)
    )
}

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "ger_survey_interest_cpi", category = "Prices", label = "Survey on Development of Interest Rates and German Consumer Price Index",
    notes = "Interest rates as monthly averages: ECB rates from the Bundesbank, Fed rates (effective federal funds rate and target range) from FRED. Consumer price index: change on the same month of the previous year, in % (GENESIS 61111-0002).",
    render = function() {
        DE <- file.path(OUT_DIR, "prices graphs/German labeling")
        EN <- file.path(OUT_DIR, "prices graphs/English labeling")
        render_graph(ger_survey_interest_cpi(source = "Datenquelle: Destatis, Deutsche Bundesbank, Federal Reserve System (US)",
            label_band = "Zinsbandbreite", label_effr = "Effektiver Tagesgeldsatz (USA)", label_ecb_main = "EZB-Hauptrefinanzierungssatz",
            label_cpi = "Verbraucherpreisindex", y_axis_left = "Zinssatz in %", y_axis_right = "Veränderung Verbraucherpreisindex zum Vorjahresmonat in %",
            decimal_mark = ","), "Survey on development of interest rate and german consumer-pric-index_de",
            DE)
        render_graph(ger_survey_interest_cpi(source = "Data source: Destatis, German Federal Bank, Board of Governors of the Federal Reserve System (US)",
            label_band = "Interest rate band", label_effr = "Effektive Federal Funds rate", label_ecb_main = "ECB interest rate for main refinancing operations",
            label_cpi = "Consumer price index", y_axis_left = "Interest rate in %", y_axis_right = "Change of consumer price index to previous year's month in %",
            decimal_mark = "."), "Survey on development of interest rate and german consumer-pric-index_en",
            EN)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/prices/ger_survey_interest_cpi.R", .graph_specs)
