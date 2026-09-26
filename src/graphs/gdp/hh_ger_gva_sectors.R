
.hh_ger_gva_sectors_yoy_growth <- function(caption,
                        label_ger = "Deutschland",
                        label_hh = "Hamburg",
                        y_axis = "Bruttowertschöpfung",
                        decimal_mark = ",",
                        big_mark = "."
                      ) {
  source("src/bootstrap.R")

  ger_raw <- with_cache(paste0("genesis_82111-0002_", DATA_START_YEAR),
                        genesis_fetch("82111-0002"))
  
  hh_raw <- with_cache(paste0("genesis_82111-0011_", DATA_START_YEAR),
                        genesis_fetch("82111-0011"))

  sectors_list <- c("WZ08-A", "WZ08-B-E", "WZ08-F","WZ08-G-T") 
  
  ger_dat <- ger_raw %>%
    dplyr::filter(`2_variable_attribute_code` %in% sectors_list) %>%
    dplyr::filter(!is.na(`2_variable_attribute_code`)) %>%
    dplyr::select(5,9,12,13,14) %>%
    rename(
      date = 1,
      geo = 2,
      series = 3
    ) %>%
    arrange(date)
  
  hh_dat <- hh_raw %>%
    dplyr::filter(`1_variable_attribute_code` == "02") %>%
    dplyr::filter(`2_variable_attribute_code` %in% sectors_list) %>%
    dplyr::filter(!is.na(`2_variable_attribute_code`)) %>%
    dplyr::select(5,9,12,13,14) %>%
    rename(
      date = 1,
      geo = 2,
      series = 3
    ) %>%
    arrange(date) 
  
  dat <- dplyr::bind_rows(hh_dat, ger_dat) %>%
    mutate(date = as.Date(paste0(date, "-12-31"), format = "%Y-%m-%d")) %>%
    mutate(value = as.numeric(value)) %>%
    arrange(date) %>%
    group_by(geo, series) %>%
    mutate(growth = (value - lag(value)) / lag(value) * 100) %>%
    ungroup() %>%
    filter(date == max(date))

    

  ggplot2::ggplot(dat, aes(x=series, y=growth, fill=geo)) +
    geom_col(position = position_dodge(width=0.8), width=0.7) +
    
    geom_text(
      aes(
        label = scales::number(growth, decimal.mark = ",", accuracy = 0.1),
        vjust = ifelse(growth<0, 1.5, -0.5)
      ),
      position = position_dodge(width = 0.8),
      size = 3.5,
      fontface = "bold",
      color = "grey20"
    ) +
    scale_fill_manual(
      name=NULL,
      values = c(
        "Hamburg" = hwwi_rubin,
        "Deutschland" = hwwi_blue
      )
    ) +
    scale_y_continuous(
      labels = function(x) paste0(x, "%"),
      expand = expansion(mult = c(0.15,0.15))
    ) +
    labs(
      title = NULL,
      subtitle = NULL,
      x=NULL,
      y=NULL,
      caption = caption
    ) +
    hwwi_theme() +
    theme(
      axis.title.x = element_text(size = 16),
      axis.title.y = element_text(size = 16),
      axis.text.x = element_text(size = 16, angle = 0, hjust = 0.5, vjust = 1),
      axis.text.y = element_text(size = 16), 
      plot.caption = element_text(size = 12, hjust = 1),
      legend.position = "bottom",
      legend.justification = "center",
      legend.text = element_text(size = 14)
    )
    

}

  .graph_specs <- list(
    list(
      id = "hh_ger_gva_by_sectors_yearonyear_growth",
      category = "GDP",
      label = "Hamburg and Germany Gross value added by sectors (year on year growth)",
      render = function() {
        GER <- file.path(OUT_DIR, "GDP graphs/German labeling")
        EN <- file.path(OUT_DIR, "GDP graphs/English labeling")
        render_graph(.hh_ger_gva_sectors_yoy_growth(caption = "| A: Land- u. Forstwirtschaft, Fischerei \n, 
                                                               | B-E: Prod. Gewerbe (ohne Bau) \n,
                                                               | F: Baugewerbe \n,
                                                               | G-T: Dienstleistungsbereiche,
                                                               \n\n Datenquelle: Statistisches Bundesamt", 
                                                                label_ger = "Deutschland", label_hh = "Hamburg",
                                                              decimal_mark = ",", big_mark = "."),
                                      "HH GER gross value added by sectors (year on year growth)", GER)
        render_graph(.hh_ger_gva_sectors_yoy_growth(caption = "| A: Agriculture, forestry, fishing \n, 
                                                               | B-E: Manufacturing (excl. construction) \n,
                                                               | F: Construction \n,
                                                               | G-T: Service sectors,
                                                               \n\n Data source: Federa statistical office (Destatis)",
                                                              label_ger = "Germany", label_hh = "Hamburg",
                                                            decimal_mark = ".", big_mark = ","),
                                        "HH GER gross value added by sectors (year on year growth)", EN)
      }
    )
  )

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("src/graphs/gdp/hh_ger_gva_sectors.R", .graph_specs)
