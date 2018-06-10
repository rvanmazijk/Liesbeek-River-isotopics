# Calculate total streamflow
# R. van Mazijk

source(here::here("setup.R"))
source(here::here("functions/integrate_trapezoid.R"))

LRD_tidy %>%
    filter(source == "River") %$%
    integrate_trapezoid(amnt, date_time, "integrate")
