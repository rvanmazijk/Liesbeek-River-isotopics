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

my_functions <- list.files(here::here("functions"), full.names = TRUE)
map(my_functions, source)
