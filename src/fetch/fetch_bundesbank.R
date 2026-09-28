fetch_bundesbank_series <- function(dataset, key, series = key,
                                     unit = NA_character_, geo = NA_character_) {
  url <- sprintf(
    "https://api.statistiken.bundesbank.de/rest/data/%s/%s?detail=dataonly",
    dataset, key
  )
  r <- tryCatch(
    httr2::request(url) |>
      httr2::req_timeout(30) |>
      httr2::req_perform() |>
      httr2::resp_body_string(),
    error = function(e) NULL
  )
  if (is.null(r)) stop("Could not fetch Bundesbank series: ", key)
  doc    <- xml2::read_xml(r)
  dates  <- xml2::xml_attr(xml2::xml_find_all(doc, ".//*[local-name()='ObsDimension']"), "value")
  values <- suppressWarnings(
    as.numeric(xml2::xml_attr(xml2::xml_find_all(doc, ".//*[local-name()='ObsValue']"), "value"))
  )
  tibble::tibble(month = dates, value = values) |>
    dplyr::filter(!is.na(value)) |>
    dplyr::mutate(date = as.Date(paste0(month, "-01")),
                  series = series, unit = unit, geo = geo) |>
    dplyr::select(date, value, series, unit, geo)
}
