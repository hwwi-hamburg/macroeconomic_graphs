library(restatis)
library(httr2)
source("src/config.R")
if (file.exists("src/local_config.R")) source("src/local_config.R")
source("src/graph_modules.R")
source("src/theme.R")
source("src/render.R")

# Source all helper functions
folders <- c(
  "src/fetch",
  "src/transform",
  "src/plot"
)

for (folder in folders) {
  files <- list.files(
    path = folder,
    pattern = "\\.R$",
    full.names = TRUE
  )
  
  sapply(files, source)
}
