# Long-term government bond yields: top 5 (highest) and bottom 5 (lowest) EU countries.
# Data: Eurostat ei_mfir_m, indicator MF-LTGBY-RT (10-year benchmark bonds), monthly.

.parse_estat_json <- function(r) {
  parsed  <- jsonlite::fromJSON(r, simplifyVector = FALSE)
  dim_ids <- unlist(parsed$id)
  sizes   <- as.integer(unlist(parsed$size))
  n_dims  <- length(sizes)

  # Row-major strides
  strides         <- integer(n_dims)
  strides[n_dims] <- 1L
  if (n_dims > 1)
    for (i in (n_dims - 1L):1L) strides[i] <- strides[i + 1L] * sizes[i + 1L]

  # Position → code for each dimension
  pos_to_code <- lapply(dim_ids, function(d) {
    idx <- unlist(parsed$dimension[[d]]$category$index)
    setNames(names(idx), as.character(as.integer(idx)))
  })

  vals <- parsed$value
  rows <- lapply(names(vals), function(pos_str) {
    pos  <- as.integer(pos_str)
    rem  <- pos
    codes <- character(n_dims)
    for (i in seq_len(n_dims)) {
      dim_pos  <- rem %/% strides[i]
      rem      <- rem %%  strides[i]
      codes[i] <- pos_to_code[[i]][as.character(dim_pos)]
    }
    names(codes) <- dim_ids
    c(as.list(codes), list(value = vals[[pos_str]]))
  })

  rows_flat <- lapply(rows, function(x) lapply(x, function(v) if (is.list(v)) v[[1]] else v))
  col_names <- names(rows_flat[[1]])
  cols <- setNames(
    lapply(col_names, function(nm) sapply(rows_flat, function(r) r[[nm]])),
    col_names
  )
  as.data.frame(cols, stringsAsFactors = FALSE)
}

ger_govt_bond_yields <- function(y_axis, source, decimal_mark = ",",
                                  country_names = NULL) {
  start <- as.Date(paste0(DATA_START_MONTH, "-01"))

  url <- paste0(
    "https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/ei_mfir_m",
    "?format=JSON&indic=MF-LTGBY-RT&lang=EN"
  )
  raw_json <- tryCatch(
    httr2::request(url) |> httr2::req_timeout(60) |> httr2::req_perform() |>
      httr2::resp_body_string(),
    error = function(e) NULL
  )
  if (is.null(raw_json)) stop("Could not fetch Eurostat government bond yields")

  dat <- .parse_estat_json(raw_json)
  dat$date  <- as.Date(paste0(dat$time, "-01"))
  dat$value <- as.numeric(dat$value)
  dat <- dat[!is.na(dat$value) & dat$date >= start, ]

  # Select top 5 and bottom 5 countries by most recent month
  latest  <- max(dat$date, na.rm = TRUE)
  recent  <- dat[dat$date == latest, ]
  recent  <- recent[order(recent$value), ]
  sel_geo <- unique(c(head(recent$geo, 5), tail(recent$geo, 5)))

  plot_dat <- dat[dat$geo %in% sel_geo, ]

  if (!is.null(country_names)) {
    plot_dat$series <- dplyr::coalesce(country_names[plot_dat$geo], plot_dat$geo)
  } else {
    plot_dat$series <- plot_dat$geo
  }

  palette <- c(light_blue, blue, dark_blue, grey, dark_rubin,
               dark_grey, rubin, light_blue, blue, dark_rubin)

  ggplot2::ggplot(plot_dat,
    ggplot2::aes(x = date, y = value, color = series)) +
    ggplot2::geom_line(linewidth = 1.4) +
    ggplot2::scale_colour_manual("", values = palette[seq_along(sel_geo)]) +
    ggplot2::scale_x_date(date_breaks = "2 years", date_labels = "%Y",
                           limits = c(start, latest), expand = c(0, 0)) +
    ggplot2::scale_y_continuous(
      labels = function(x) format(x, decimal.mark = decimal_mark, scientific = FALSE)
    ) +
    ggplot2::labs(x = "", y = wrap_axis_label(y_axis), caption = source) +
    theme_hwwi() +
    ggplot2::theme(legend.position = "bottom") +
    ggplot2::guides(color = ggplot2::guide_legend(nrow = 3))
}

# ── Graph module ─────────────────────────────────────────────────────────────────────────────
# Metadata and rendering live with the implementation so discovery needs no central registry.
.graph_specs <- list(
list(id = "ger_govt_bond_yields", category = "Prices", label = "Long-Term Government Bond Yields: Top/Bottom 5 EU Countries (Eurostat)",
    notes = "10-year benchmark government bond yields, monthly; top and bottom 5 EU countries. Eurostat ei_mfir_m (MF-LTGBY-RT).",
    render = function() {
        DE <- file.path(OUT_DIR, "prices graphs/German labeling")
        EN <- file.path(OUT_DIR, "prices graphs/English labeling")
        cn_ger <- c(AT = "Österreich", BE = "Belgien", BG = "Bulgarien", CY = "Zypern", CZ = "Tschechien",
            DE = "Deutschland", DK = "Dänemark", EA = "EU", EE = "Estland", EL = "Griechenland", ES = "Spanien",
            FI = "Finnland", FR = "Frankreich", HR = "Kroatien", HU = "Ungarn", IE = "Irland", IT = "Italien",
            LT = "Litauen", LU = "Luxemburg", LV = "Lettland", MT = "Malta", NL = "Niederlande", PL = "Polen",
            PT = "Portugal", RO = "Rumänien", SE = "Schweden", SI = "Slowenien", SK = "Slowakei", UK = "Vereinigtes Königreich")
        cn_en <- c(AT = "Austria", BE = "Belgium", BG = "Bulgaria", CY = "Cyprus", CZ = "Czechia", DE = "Germany",
            DK = "Denmark", EA = "EU", EE = "Estonia", EL = "Greece", ES = "Spain", FI = "Finland", FR = "France",
            HR = "Croatia", HU = "Hungary", IE = "Ireland", IT = "Italy", LT = "Lithuania", LU = "Luxembourg",
            LV = "Latvia", MT = "Malta", NL = "Netherlands", PL = "Poland", PT = "Portugal", RO = "Romania",
            SE = "Sweden", SI = "Slovenia", SK = "Slovakia", UK = "United Kingdom")
        render_graph(ger_govt_bond_yields(y_axis = "Rendite (%)", source = "Datenquelle: Eurostat",
            decimal_mark = ",", country_names = cn_ger), "Long term returns of top bottom 5 government bonds_de",
            DE)
        render_graph(ger_govt_bond_yields(y_axis = "Yield (%)", source = "Data source: Eurostat", decimal_mark = ".",
            country_names = cn_en), "Long term returns of top bottom 5 government bonds_en", EN)
    })
)

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/prices/ger_govt_bond_yields.R", .graph_specs)
