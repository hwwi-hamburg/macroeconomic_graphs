.ger_states_tourism_intensity <- function(caption,
                                          label_states = "Bundesländer",
                                          label_ger = "Deutschland",
                                          y_axis = "Tourismusintensität",
                                          decimal_mark = ",",
                                          big_mark = "."
                                          ) {
  source("src/bootstrap.R")
  
  states_raw <- with_cache(paste0("genesis_45412-0020_", DATA_START_YEAR),
                           genesis_fetch("45412-0020"))
  
  ger_raw <- with_cache(paste0("genesis_45412-0001_", DATA_START_YEAR),
                        genesis_fetch("45412-0001"))
  
  states_pop_raw <- with_cache(paste0("genesis_12411-0010", DATA_START_YEAR),
                                      genesis_fetch("12411-0010"))
  
  ger_pop_raw <- with_cache(paste0("genesis_12411-0001", DATA_START_YEAR),
                            genesis_fetch("12411-0001"))
  
  
  
  states_dat <- states_raw %>%
    dplyr::filter(value_variable_label == "Übernachtungen") %>%
    rename(
      date = 5,
      geo = 9,
      übernachtungen = 10
    ) %>%
    select(5,9,10) %>%
    mutate(date = as.numeric(date)) %>%
    mutate(date = as.Date(paste0(date, "-12-31"), format = "%Y-%m-%d")) %>%
    mutate(übernachtungen = as.numeric(übernachtungen))
  
  states_pop_dat <- states_pop_raw %>%
    rename(
      date = 5,
      geo = 9,
      population = 10
    ) %>%
    select(5,9,10) %>%
    mutate(date = as.Date(date)) %>%
    mutate(population = as.numeric(population))
  
  
  
  ger_dat <- ger_raw %>%
    dplyr::filter(value_variable_label == "Übernachtungen") %>%
    rename(
      date = 5,
      geo = 9,
      übernachtungen = 10
    ) %>%
    select(5,9,10) %>%
    mutate(date = as.numeric(date)) %>%
    mutate(date = as.Date(paste0(date, "-12-31"), format = "%Y-%m-%d")) %>%
    mutate(übernachtungen = as.numeric(übernachtungen))
  
  ger_pop_dat <- ger_pop_raw %>%
    rename(
      date = 5,
      geo = 9,
      population = 10
    ) %>%
    select(5,9,10) %>%
    mutate(date = as.Date(date)) %>%
    mutate(population = as.numeric(population))
  
  tourism_intensity_states <- states_dat %>%
    inner_join(states_pop_dat, by = c("date", "geo")) %>%
    mutate(value = übernachtungen / population * 1000) %>%
    select(1,2,5)
  
  tourism_intensity_ger <- ger_dat %>%
    inner_join(ger_pop_dat, by = c("date", "geo")) %>%
    mutate(value = übernachtungen / population *1000)
  
  
  
  dat <- dplyr::bind_rows(tourism_intensity_states, tourism_intensity_ger) %>%
    filter(date == as.Date("2025-12-31")) %>%
    select(1,2,3) %>%
    arrange(desc(value))
  
  
  plot_bar_ranking(
    dat,
    caption,
    x_axis = "",
    decimal_mark = ",",
    big_mark = ".",
    color = if_else(dat$geo == "Deutschland" , hwwi_rubin, hwwi_blue)
  )
  
}


  .graph_specs <- list(
    list(
      id = "ger_states_tourism_intensity",
      category = "Tourism",
      label = "Germany and States Tourism intensity (nights per 1000 inhabitants)",
      render = function() {
        GER <- file.path(OUT_DIR, "tourism graphs/German labeling")
        EN <- file.path(OUT_DIR, "tourism graphs/English labeling")
        render_graph(.ger_states_tourism_intensity(caption = "Datenquelle: Statistisches Bundesamt",
                                                   label_ger = "Deutschland", label_states = "Bundesländer",
                                                   decimal_mark = ",", big_mark = "."),
                     "GER and States tourism intensity (nights per 1,000 inhabitants)", GER)
        render_graph(.ger_states_tourism_intensity(caption = "Data source: Federal statistical office (Destatis)",
                                                   label_ger = "Germany", label_states = "States",
                                                   decimal_mark = ".", big_mark = ","),
                     "GER and States tourism intensity (nights per 1,000 inhabitants)", EN)
      }
    )
  )
  
if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/tourism/ger_states_tourism_intensity.R", .graph_specs)