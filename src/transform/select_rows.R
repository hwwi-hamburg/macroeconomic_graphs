select_monthly_value <- function(dat, row_indicator = 1) {
  dat |>
    dplyr::group_by(date) |>
    dplyr::mutate(kennzahl = dplyr::row_number()) |>
    dplyr::filter(kennzahl == row_indicator) |>
    dplyr::ungroup() |>
    dplyr::select(-kennzahl)
}