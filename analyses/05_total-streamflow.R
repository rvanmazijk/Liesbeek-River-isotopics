# Calculate total streamflow
# R. van Mazijk

source(here::here("setup.R"))

LRD_tidy %>%
    filter(source == "River") %$%
    integrate_trapezoid(amnt, date_time, "integrate")
