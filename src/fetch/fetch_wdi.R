fetch_wdi <- function(indicator, country, start = 1960,
                      end = as.integer(format(Sys.Date(), "%Y"))) {
  raw <- WDI::WDI(indicator = indicator, country = country,
                   start = start_month_year(start), end = end, extra = TRUE)
  tibble::tibble(
    date   = as.Date(paste0(raw$year, "-01-01")),
    value  = raw[[indicator]],
    series = raw$country,
    unit   = NA_character_,
    geo    = raw$iso3c
  )
}
