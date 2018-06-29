# Liesbeeck River water isotope & hydrograph data analyses
# Ruan van Mazijk

# Install/load packages --------------------------------------------------------

if (!require(pacman)) install.packages("pacman")
library(pacman)
p_load(tidyverse, here, magrittr, readxl, stringr, lubridate, cowplot)

# Import data ------------------------------------------------------------------

LRD_tidy <- read_csv(here::here("data/liesbeek-data-tidy.csv"))
colnames(LRD_tidy)[4] <- "source"
harris_uct <- read_csv(here::here("data/harris-uct.csv"))
extra_sites <- read_csv(here::here("data/extra-sites.csv"))

# Define functions -------------------------------------------------------------

insert_cumul_rain_type <- function(x) {
  x$type %<>% as.character()
  for (i in 1:nrow(x)) {
    x$type[i] <- if (x$source_type[i] == "cum_rain") "cum_rain" else next
  }
  x$type %<>% as.factor()
  x
}

total_discharge_steps <- function(Q, t) {
  # Q = streamflow discharge rate (exclude times w/ no Q value!)
  # t = time
  stopifnot(length(Q) == length(t))
  t <- c(0, t) # To get final Q * (t_{i+1} - t_{i}) vectors to same length
  sum(
    Q *
    (t[2:length(t)] - t[1:(length(t) - 1)])
  )
}
