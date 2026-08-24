# Fetch any GENESIS table via restatis → long/tidy tibble (ffcsv format).
# Accepts the same filter params as gen_table: classifyingvariable1/key1, regionalvariable/key, etc.
genesis_fetch <- function(table_key, start_year = DATA_START_YEAR, end_year = 2100, ...) {
  restatis::gen_table(
    name      = table_key,
    database  = "genesis",
    startyear = as.integer(start_year),
    endyear   = as.integer(end_year),
    language  = "de",
    all_character = TRUE,
    ...
  )
}

# Fetch a GENESIS table with optional pre-roll data for lagged calculations.
# When `pre_roll = TRUE`, the fetch starts one year earlier than `start_year`
# so functions like yoy_growth() can compute the first visible change without
# special casing in the graph module.
genesis_fetch_window <- function(table_key, start_year = DATA_START_YEAR,
                                 end_year = 2100, pre_roll = FALSE, ...) {
  fetch_start <- if (pre_roll) as.integer(start_year) - 1L else as.integer(start_year)
  genesis_fetch(table_key, start_year = fetch_start, end_year = end_year, ...)
}

# Trim a standard tibble to the requested display window.
trim_start_year <- function(dat, start_year = DATA_START_YEAR) {
  dplyr::filter(dat, date >= as.Date(paste0(start_year, "-01-01")))
}

# Parse a genesis_fetch() tibble into normalized tibble(date, value, series, unit, geo).
#
# value_var     : value_variable_code to keep (e.g. "BIP005", "ERW112", "WERTA")
# unit_filter   : optional value_unit to keep (e.g. "2020=100", "Tsd. EUR")
# class_filters : named list of column → value for additional row filters
#                 (e.g. list("2_variable_attribute_code" = "VGRPKM"))
# scale         : numeric multiplier applied to value (e.g. 1/1e6 to convert Tsd.EUR → Mrd.EUR)
parse_genesis <- function(raw, value_var, series_name = "value",
                          unit = NA_character_, geo = "DEU",
                          class_filters = NULL, unit_filter = NULL,
                          scale = 1, dropmissing = TRUE,
                          na_values = c("-", "/", ".", "", "..."),
                          zero_values = character()) {
  
  dat <- raw
  
  dat <- dat[
    !is.na(dat$value_variable_code) &
      dat$value_variable_code == value_var,
    ,
    drop = FALSE
  ]
  
  if (!is.null(unit_filter)) {
    dat <- dat[
      dat$value_unit == unit_filter,
      ,
      drop = FALSE
    ]
  }
  
  if (!is.null(class_filters)) {
    
    for (nm in names(class_filters)) {
      
      fval <- class_filters[[nm]]
      
      if (is.na(fval)) {
        
        dat <- dat[
          is.na(dat[[nm]]),
          ,
          drop = FALSE
        ]
        
      } else {
        
        dat <- dat[
          !is.na(dat[[nm]]) & dat[[nm]] == fval,
          ,
          drop = FALSE]}}}
  
  if (length(zero_values) > 0) {
    dat$value[dat$value %in% zero_values] <- "0"}
  
  if (length(na_values) > 0) {
    dat$value[dat$value %in% na_values] <- NA_character_}
  
  
  if (dropmissing) {
    dat <- dat[
      !is.na(dat$value),
      ,
      drop = FALSE]}
  
  if (nrow(dat) == 0) {
    stop("parse_genesis: no rows after filtering")
  }
  
  tibble::tibble(
    date   = .genesis_date(dat),
    value  = as.numeric(gsub(",", ".", dat$value)) * scale,
    series = series_name,
    unit   = if (is.na(unit)) dat$value_unit[1] else unit,
    geo    = geo
  )
}

# Date parser: handles monthly (MONAT), quarterly (QUART*), and annual time dimensions.
.genesis_date <- function(dat) {
  var1_col <- "1_variable_code"
  if (var1_col %in% names(dat)) {
    codes <- dat[[var1_col]]
    if (any(codes == "MONAT", na.rm = TRUE)) {
      month_num <- as.integer(sub("MONAT", "", dat[["1_variable_attribute_code"]]))
      return(as.Date(paste(dat$time, formatC(month_num, width = 2, flag = "0"), "01", sep = "-")))
    }
    if (any(grepl("^QUART", codes, ignore.case = TRUE), na.rm = TRUE)) {
      q_attr <- dat[["1_variable_attribute_code"]]
      q_num  <- suppressWarnings(as.integer(regmatches(q_attr, regexpr("[0-9]+$", q_attr))))
      month_num <- (q_num - 1L) * 3L + 1L
      return(as.Date(paste(dat$time, formatC(month_num, width = 2, flag = "0"), "01", sep = "-")))
    }
  }
  as.Date(paste0(dat$time, "-01-01"))
}

# Convert Destatis German country names to ISO3C.
# Strips parenthetical qualifiers and applies a custom lookup for DESTATIS naming variants.
de_country_to_iso3c <- function(names_de) {
  custom <- c(
    "Korea, Republik"                                     = "KOR",
    "Korea, Demokratische Volksrepublik"                  = "PRK",
    "Iran, Islamische Republik"                           = "IRN",
    "Syrien, Arabische Republik"                          = "SYR",
    "Bolivien, Plurinationaler Staat"                     = "BOL",
    "Venezuela, Bolivarische Republik"                    = "VEN",
    "Moldova, Republik"                                   = "MDA",
    "Hongkong, Sonderverwaltungsregion der VR China"      = "HKG",
    "Macao, Sonderverwaltungsregion der VR China"         = "MAC",
    "Taiwan, Provinz Chinas"                              = "TWN",
    "Palästina, Staat"                                    = "PSE",
    "Tansania, Vereinigte Republik"                       = "TZA",
    "Kongo, Demokratische Republik"                       = "COD",
    "Kongo, Republik"                                     = "COG",
    "Libyen, Staat"                                       = "LBY",
    "Laos, Demokratische Volksrepublik"                   = "LAO",
    "Brunei Darussalam"                                   = "BRN",
    "Vereinigte Arabische Emirate"                        = "ARE",
    "Gambia"                                              = "GMB",
    "Turkiye"                                             = "TUR",
    "Türkei"                                              = "TUR"
  )
  clean <- gsub("\\s+\\(.*?\\)", "", trimws(names_de))
  iso <- custom[clean]
  fallback <- countrycode::countrycode(clean, origin = "country.name.de",
                                        destination = "iso3c", warn = FALSE)
  dplyr::coalesce(iso, fallback)
}

# ── Domain fetchers ────────────────────────────────────────────────────────────

# Shared helper: extracts total trade and trade excluding GP division 30
# ("other transport equipment") from the state tables. Destatis retired the
# former EGW3 aircraft dimension in March 2026, so the narrower EGW883 series
# can no longer be refreshed from these tables.
.state_trade_long <- function(trade_raw, transport_raw, state_key, geo) {
  cf  <- list("1_variable_attribute_code" = state_key)
  cft <- list("1_variable_attribute_code" = state_key, "2_variable_attribute_code" = "GP19-30")

  ex  <- parse_genesis(trade_raw, "WERTA", series_name = "Export",    unit = "Mrd. EUR", geo = geo, class_filters = cf,  scale = 1 / 1e6)
  im  <- parse_genesis(trade_raw, "WERTE", series_name = "Import",    unit = "Mrd. EUR", geo = geo, class_filters = cf,  scale = 1 / 1e6)
  tex <- parse_genesis(transport_raw, "WERTA", series_name = "TransportExport", unit = "Mrd. EUR", geo = geo, class_filters = cft, scale = 1 / 1e6)
  tim <- parse_genesis(transport_raw, "WERTE", series_name = "TransportImport", unit = "Mrd. EUR", geo = geo, class_filters = cft, scale = 1 / 1e6)

  ex_j <- dplyr::left_join(dplyr::rename(ex, Export = value), dplyr::rename(tex, TransportExport = value), by = "date") |>
    dplyr::mutate(ExportExclTransport = Export - dplyr::coalesce(TransportExport, 0))
  im_j <- dplyr::left_join(dplyr::rename(im, Import = value), dplyr::rename(tim, TransportImport = value), by = "date") |>
    dplyr::mutate(ImportExclTransport = Import - dplyr::coalesce(TransportImport, 0))

  dplyr::bind_rows(
    dplyr::transmute(ex_j, date, value = Export, series = "Export", unit = "Mrd. EUR", geo = geo),
    dplyr::transmute(ex_j, date, value = ExportExclTransport, series = "ExportExclTransport", unit = "Mrd. EUR", geo = geo),
    dplyr::transmute(im_j, date, value = Import, series = "Import", unit = "Mrd. EUR", geo = geo),
    dplyr::transmute(im_j, date, value = ImportExclTransport, series = "ImportExclTransport", unit = "Mrd. EUR", geo = geo)
  )
}

# Hamburg total trade and totals excluding other transport equipment.
fetch_hh_trade <- function(start_year = DATA_START_YEAR) {
  trade_raw <- genesis_fetch("51000-0030", start_year, regionalvariable = "DLANDX", regionalkey = "02")
  transport_raw <- genesis_fetch("51000-0034", start_year,
                                 classifyingvariable1 = "GP19B2", classifyingkey1 = "GP19-30",
                                 regionalvariable = "DLANDX", regionalkey = "02")
  .state_trade_long(trade_raw, transport_raw, state_key = "02", geo = "HH")
}

# Hamburg monthly trade (51000-0031/0035), including the historical variants
# that exclude aircraft (EGW883).
# In 51000-0031: month in variable 1, state in variable 2 (code "02").
# In 51000-0035: month in variable 1, state in variable 2, commodity in variable 3.
# Values are in Tsd. EUR; scale = 1/1e6 converts to Mrd. EUR.
fetch_hh_trade_monthly <- function(start_year = DATA_START_YEAR) {
  trade_raw <- genesis_fetch("51000-0031", start_year,
                              regionalvariable = "DLANDX", regionalkey = "02")
  air_raw <- genesis_fetch("51000-0035", start_year,
                           classifyingvariable1 = "EGW3", classifyingkey1 = "EGW883",
                           regionalvariable = "DLANDX", regionalkey = "02")
  cf  <- list("2_variable_attribute_code" = "02")
  cfa <- list("2_variable_attribute_code" = "02", "3_variable_attribute_code" = "EGW883")
  .parse_or_empty <- function(...) tryCatch(parse_genesis(...),
                                            error = function(e) tibble::tibble(date = as.Date(character()), value = numeric()))
  ex  <- parse_genesis(trade_raw, "WERTA", series_name = "Export",    unit = "Mrd. EUR", geo = "HH", class_filters = cf,  scale = 1 / 1e6)
  im  <- parse_genesis(trade_raw, "WERTE", series_name = "Import",    unit = "Mrd. EUR", geo = "HH", class_filters = cf,  scale = 1 / 1e6)
  aex <- .parse_or_empty(air_raw, "WERTA", series_name = "AirExport", unit = "Mrd. EUR", geo = "HH", class_filters = cfa, scale = 1 / 1e6)
  aim <- .parse_or_empty(air_raw, "WERTE", series_name = "AirImport", unit = "Mrd. EUR", geo = "HH", class_filters = cfa, scale = 1 / 1e6)
  ex_j <- dplyr::left_join(dplyr::rename(ex, Export = value),
                            dplyr::rename(aex, AirExport = value), by = "date") |>
    dplyr::mutate(ExportNoAir = Export - AirExport)
  im_j <- dplyr::left_join(dplyr::rename(im, Import = value),
                            dplyr::rename(aim, AirImport = value), by = "date") |>
    dplyr::mutate(ImportNoAir = Import - AirImport)
  dplyr::bind_rows(
    dplyr::transmute(ex_j, date, value = Export, series = "Export", unit = "Mrd. EUR", geo = "HH"),
    dplyr::transmute(ex_j, date, value = ExportNoAir, series = "ExportNoAir", unit = "Mrd. EUR", geo = "HH"),
    dplyr::transmute(im_j, date, value = Import, series = "Import", unit = "Mrd. EUR", geo = "HH"),
    dplyr::transmute(im_j, date, value = ImportNoAir, series = "ImportNoAir", unit = "Mrd. EUR", geo = "HH")
  )
}

# Lower Saxony total trade and totals excluding other transport equipment.
fetch_ls_trade <- function(start_year = DATA_START_YEAR) {
  trade_raw <- genesis_fetch("51000-0030", start_year, regionalvariable = "DLANDX", regionalkey = "03")
  transport_raw <- genesis_fetch("51000-0034", start_year,
                                 classifyingvariable1 = "GP19B2", classifyingkey1 = "GP19-30",
                                 regionalvariable = "DLANDX", regionalkey = "03")
  .state_trade_long(trade_raw, transport_raw, state_key = "03", geo = "LS")
}

# Hamburg (or other state) exports by country for choropleth maps.
# Returns tibble with ISO3C geo codes, values in Mio. EUR.
fetch_trade_by_country <- function(year, regional_key = "02") {
  raw <- genesis_fetch("51000-0032", year, year,
                        regionalvariable = "DLANDX", regionalkey = regional_key)
  dat <- raw[raw$value_variable_code == "WERTA" &
               !is.na(raw$value) & raw$value != "-", , drop = FALSE]
  tibble::tibble(
    date   = as.Date(paste0(dat$time, "-01-01")),
    value  = as.numeric(gsub(",", ".", dat$value)) / 1e3,
    series = "export",
    unit   = "Mio. EUR",
    geo    = de_country_to_iso3c(dat[["2_variable_attribute_label"]])
  ) |> dplyr::filter(!is.na(geo))
}

# Germany commodity exports/imports for pie charts.
# Returns data frame with Group label, export and import value in Mrd. EUR.
.TRADE_WAM2_CODES <- paste0("WA", sprintf("%02d", 1:99))
.TRADE_GP19_CODES <- paste0(
  "GP19-",
  c("01", "02", "03", "05", "06", "07", "08",
    as.character(10:17), "19", as.character(20:32), "35", "38")
)

.genesis_dimension_columns <- function(dat, variable_code) {
  variable_cols <- grep("^[0-9]+_variable_code$", names(dat), value = TRUE)
  hit <- variable_cols[vapply(variable_cols, function(nm) {
    any(dat[[nm]] == variable_code, na.rm = TRUE)
  }, logical(1))]
  if (length(hit) != 1L)
    stop("Could not identify GENESIS dimension ", variable_code)
  prefix <- sub("_variable_code$", "", hit[[1]])
  c(
    code = paste0(prefix, "_variable_attribute_code"),
    label = paste0(prefix, "_variable_attribute_label")
  )
}

fetch_ger_trade_commodity <- function(year) {
  raw <- genesis_fetch("51000-0005", year, year,
                        classifyingvariable1 = "WAM2",
                        classifyingkey1 = .TRADE_WAM2_CODES)
  commodity_cols <- .genesis_dimension_columns(raw, "WAM2")
  dat <- raw[!is.na(raw$value) & raw$value != "-" &
               !is.na(raw[[commodity_cols[["code"]]]]), , drop = FALSE]
  ex <- dat[dat$value_variable_code == "WERTA", ]
  im <- dat[dat$value_variable_code == "WERTE", ]
  merged <- merge(
    data.frame(Code  = ex[[commodity_cols[["code"]]]],
               Group = ex[[commodity_cols[["label"]]]],
               GerExport = as.numeric(gsub(",", ".", ex$value)) / 1e6,
               stringsAsFactors = FALSE),
    data.frame(Code  = im[[commodity_cols[["code"]]]],
               GerImport = as.numeric(gsub(",", ".", im$value)) / 1e6,
               stringsAsFactors = FALSE),
    by = "Code", all.x = TRUE
  )
  merged[order(-merged$GerExport), ]
}

# State (Bundesland) commodity exports/imports for pie charts (51000-0034).
# Returns data frame: Code, Group, Export, Import in Mrd. EUR.
# state_key: "02" = Hamburg, "03" = Lower Saxony, etc.
fetch_state_trade_commodity <- function(year, state_key = "02") {
  raw <- genesis_fetch("51000-0034", year, year,
                        classifyingvariable1 = "GP19B2",
                        classifyingkey1 = .TRADE_GP19_CODES,
                        regionalvariable = "DLANDX", regionalkey = state_key)
  commodity_cols <- .genesis_dimension_columns(raw, "GP19B2")
  dat <- raw[!is.na(raw$value) & raw$value != "-" &
               !is.na(raw[["1_variable_attribute_code"]]) &
               raw[["1_variable_attribute_code"]] == state_key, , drop = FALSE]
  ex <- dat[dat$value_variable_code == "WERTA", ]
  im <- dat[dat$value_variable_code == "WERTE", ]
  merged <- merge(
    data.frame(Code   = ex[[commodity_cols[["code"]]]],
               Group  = ex[[commodity_cols[["label"]]]],
               Export = as.numeric(gsub(",", ".", ex$value)) / 1e6,
               stringsAsFactors = FALSE),
    data.frame(Code   = im[[commodity_cols[["code"]]]],
               Import = as.numeric(gsub(",", ".", im$value)) / 1e6,
               stringsAsFactors = FALSE),
    by = "Code", all.x = TRUE
  )
  merged[order(-merged$Export), ]
}

# Germany-equivalent GP2019 structure obtained by summing the 16 state rows.
# This uses the same classification as fetch_state_trade_commodity(), which is
# required for state-vs-Germany deviation calculations.
fetch_ger_trade_commodity_gp19 <- function(year) {
  raw <- genesis_fetch("51000-0034", year, year,
                       classifyingvariable1 = "GP19B2",
                       classifyingkey1 = .TRADE_GP19_CODES,
                       regionalvariable = "DLANDX",
                       regionalkey = sprintf("%02d", 1:16))
  commodity_cols <- .genesis_dimension_columns(raw, "GP19B2")
  state_codes <- sprintf("%02d", 1:16)
  dat <- raw[
    !is.na(raw$value) & !raw$value %in% c("-", "/", ".", "", "...") &
      raw[["1_variable_attribute_code"]] %in% state_codes,
    , drop = FALSE
  ]
  dat$amount <- as.numeric(gsub(",", ".", dat$value)) / 1e6
  dat$Code <- dat[[commodity_cols[["code"]]]]
  dat$Group <- dat[[commodity_cols[["label"]]]]
  ex <- stats::aggregate(amount ~ Code + Group,
                         data = dat[dat$value_variable_code == "WERTA", ], sum)
  im <- stats::aggregate(amount ~ Code,
                         data = dat[dat$value_variable_code == "WERTE", ], sum)
  names(ex)[names(ex) == "amount"] <- "GerExport"
  names(im)[names(im) == "amount"] <- "GerImport"
  merge(ex, im, by = "Code", all.x = TRUE)
}

# State imports by country of origin (choropleth maps).
# Uses WERTE from 51000-0032; if missing, try table 51000-0033.
fetch_trade_by_country_import <- function(year, regional_key = "02") {
  raw <- genesis_fetch("51000-0032", year, year,
                        regionalvariable = "DLANDX", regionalkey = regional_key)
  dat <- raw[raw$value_variable_code == "WERTE" &
               !is.na(raw$value) & raw$value != "-", , drop = FALSE]
  tibble::tibble(
    date   = as.Date(paste0(dat$time, "-01-01")),
    value  = as.numeric(gsub(",", ".", dat$value)) / 1e3,
    series = "import",
    unit   = "Mio. EUR",
    geo    = de_country_to_iso3c(dat[["2_variable_attribute_label"]])
  ) |> dplyr::filter(!is.na(geo))
}

# Germany exports or imports by country for choropleth maps (51000-0003).
# Country is the primary classifying dimension of this table — no classifyingvariable needed.
# direction: "export" (WERTA) or "import" (WERTE)
fetch_ger_trade_by_country <- function(year, direction = "export") {
  value_var <- if (direction == "export") "WERTA" else "WERTE"
  raw <- genesis_fetch("51000-0003", year, year)
  dat <- raw[!is.na(raw$value_variable_code) &
               raw$value_variable_code == value_var &
               !is.na(raw$value) & raw$value != "-", , drop = FALSE]
  tibble::tibble(
    date   = as.Date(paste0(dat$time, "-01-01")),
    value  = as.numeric(gsub(",", ".", dat$value)) / 1e3,
    series = direction,
    unit   = "Mio. EUR",
    geo    = de_country_to_iso3c(dat[["2_variable_attribute_label"]])
  ) |> dplyr::filter(!is.na(geo))
}

# State vs Germany trade share deviation by country.
# Returns tibble(geo = ISO3C, value = state_share - ger_share in pp).
# Reuses the same cache keys as the state/Germany country choropleth specs.
fetch_trade_share_deviation_by_country <- function(year, regional_key = "02", direction = "export") {
  cache_tag <- switch(regional_key, "02" = "hh", "03" = "ls", tolower(regional_key))

  if (direction == "export") {
    state_raw <- with_cache(paste0("genesis_", cache_tag, "_exports_by_country_", year),
                             fetch_trade_by_country(year, regional_key = regional_key))
  } else {
    state_raw <- with_cache(paste0("genesis_", cache_tag, "_imports_by_country_", year),
                             fetch_trade_by_country_import(year, regional_key = regional_key))
  }
  ger_raw <- with_cache(paste0("genesis_ger_", direction, "s_by_country_", year),
                         fetch_ger_trade_by_country(year, direction = direction))

  if (nrow(state_raw) == 0 || nrow(ger_raw) == 0)
    stop("fetch_trade_share_deviation_by_country: empty data for year ", year)

  state_agg <- aggregate(value ~ geo, data = state_raw[!is.na(state_raw$geo), ], FUN = sum, na.rm = TRUE)
  ger_agg   <- aggregate(value ~ geo, data = ger_raw[!is.na(ger_raw$geo), ],     FUN = sum, na.rm = TRUE)

  state_agg$share <- state_agg$value / sum(state_agg$value, na.rm = TRUE) * 100
  ger_agg$share   <- ger_agg$value   / sum(ger_agg$value,   na.rm = TRUE) * 100

  merged <- merge(
    data.frame(geo = state_agg$geo, state_share = state_agg$share, stringsAsFactors = FALSE),
    data.frame(geo = ger_agg$geo,   ger_share   = ger_agg$share,   stringsAsFactors = FALSE),
    by = "geo"
  )
  tibble::tibble(geo = merged$geo, value = merged$state_share - merged$ger_share)
}

# Shared data prep for state-vs-Germany commodity structure deviation charts.
# Returns data frame with columns: Code, Group, diff (in percentage points).
# state_key: "02" = Hamburg, "03" = Lower Saxony
# direction: "export" or "import"
fetch_state_deviation <- function(yr, state_key, direction = "export") {
  state_col <- if (direction == "export") "Export"    else "Import"
  ger_col   <- if (direction == "export") "GerExport" else "GerImport"
  cache_tag <- switch(state_key, "02" = "HH", "03" = "LS", state_key)

  state_dat <- with_cache(paste0("genesis_51000-0034_gp19_explicit_", cache_tag, "_", yr),
                           fetch_state_trade_commodity(yr, state_key = state_key))
  ger_dat   <- with_cache(paste0("genesis_51000-0034_all_states_gp19_explicit_", yr),
                          fetch_ger_trade_commodity_gp19(yr))

  comp <- merge(
    data.frame(Code = state_dat$Code, state_val = state_dat[[state_col]], stringsAsFactors = FALSE),
    data.frame(Code = ger_dat$Code, Group = ger_dat$Group, ger_val = ger_dat[[ger_col]], stringsAsFactors = FALSE),
    by = "Code"
  )
  comp <- comp[!is.na(comp$state_val) & !is.na(comp$ger_val) & comp$state_val > 0 & comp$ger_val > 0, ]
  comp$state_share <- comp$state_val / sum(comp$state_val) * 100
  comp$ger_share   <- comp$ger_val   / sum(comp$ger_val)   * 100
  comp$diff        <- comp$state_share - comp$ger_share
  comp$Group       <- substr(comp$Group, 1, 55)
  comp
}