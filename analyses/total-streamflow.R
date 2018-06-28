# Calculate total streamflow
# Ruan van Mazijk

source(here::here("setup.R"))

LRD_tidy %>%
  filter(source == "River") %>%
  slice(-c(1:3)) %>%  # Ignore baseflow
  mutate(date_time_diff = difftime(date_time,
                                   .$date_time[1],
                                   units = "hours")) %$%
  total_discharge_steps(amnt, date_time_diff)
