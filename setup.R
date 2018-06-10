# Liesbeeck River Data water isotope & hydrology data analyses
# Ruan. van Mazijk

# Install/load packages --------------------------------------------------------

if (!require(pacman)) install.packages("pacman")
library(pacman)
p_load(tidyverse, here, magrittr, readxl, stringr, lubridate, cowplot)

# Get citations for all packages -----------------------------------------------

p_load(bibtex)
my_pkgs <- c("bibtex", "pacman", tidyverse_packages(), "here", "cowplot")
bibtex::write.bib(entry = my_pkgs, file = "pkgs.bib")

# Import data ------------------------------------------------------------------

LRD_tidy <- read_csv(here::here("liesbeeck-data-tidy.csv"))[, -1]
colnames(LRD_tidy)[4] <- "source"

harris_uct <- read_csv(here::here("harris-uct.csv"))

extra_sites <- read_csv(here::here("johndaybldg-skeletongorge.csv")) %>%
    mutate(
        date_time_start = ymd_hm(date_time_start),
        date_time_end   = ymd_hm(date_time_end))
