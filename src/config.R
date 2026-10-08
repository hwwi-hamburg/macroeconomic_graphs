# ── Data ──────────────────────────────────────────────────────────────────────
DATA_START_MONTH <- "2000-01"   # earliest year-month ("YYYY-MM") to fetch for all time series
HH_AIRCRAFT_ARCHIVE_START_MONTH <- "2000-01"  # stable cache key for retired EGW883 history

# GENESIS/WDI start/end params are year-only. DATA_START_MONTH (and any
# start_month passed around) is always "YYYY-MM" or a bare year — this pulls
# the year back out for APIs that only understand years.
start_month_year <- function(start_month) as.integer(substr(as.character(start_month), 1, 4))

# World Bank aggregate regions used by both regional GDP graph modules. Keep
# these in shared configuration because graph discovery sources each module in
# an isolated environment.
REGION_CODES <- c("Z4", "Z7", "ZJ", "ZQ", "XU", "8S", "ZG")
REGION_ISO3C <- c("EAS", "ECS", "LCN", "MEA", "NAC", "SAS", "SSF")

# ── Paths ─────────────────────────────────────────────────────────────────────
OUT_DIR   <- "out"
CACHE_DIR <- "cache"

# ── Graph lists ───────────────────────────────────────────────────────────────
# Contact shown in "List of available graphs.html" (e.g. "Jane Doe, doe@example.org").
# Set it in the git-ignored src/local_config.R so it is not published.
GRAPH_LIST_CONTACT <- NULL

# ── Render defaults ───────────────────────────────────────────────────────────
OUT_FORMAT <- "jpeg"
OUT_WIDTH  <- 11    # inches
OUT_HEIGHT <- 6     # inches
OUT_DPI    <- 300
