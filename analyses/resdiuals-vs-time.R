# Regressing Fig. 2. residuals against time
# Ruan van Mazijk

source(here::here("analyses/setup.R"))

# Import data ------------------------------------------------------------------

rain_river_spread <- LRD_tidy %>%
  select(source, amnt, date_time) %>%
  spread(key = source, value = amnt)
rain_river_spread$Rain[is.na(rain_river_spread$Rain)] <- 0
d18O_source_spread <- LRD_tidy %>%
  select(source, d18O, date_time) %>%
  spread(key = source, value = d18O) %>%
  as_tibble()
d2H_source_spread <- LRD_tidy %>%
  select(source, d2H, date_time) %>%
  spread(key = source, value = d2H) %>%
  as_tibble()
fit_stream_vs_rain <- lm(River ~ Rain, rain_river_spread)
fit_d2H <- lm(River ~ Rain, d2H_source_spread)
fit_d18O <- lm(River ~ Rain, d18O_source_spread)

# Check if residuals depend on time --------------------------------------------

# .... Streamflow vs rainfall amount -------------------------------------------

broom::tidy(lm(
  fit_stream_vs_rain$residuals ~
  na.exclude(rain_river_spread)$date_time
))

broom::glance(lm(
  fit_stream_vs_rain$residuals ~
  na.exclude(rain_river_spread)$date_time
))

# .... Stream vs rain d2H ------------------------------------------------------

broom::tidy(lm(
  fit_d2H$residuals ~
  na.exclude(d2H_source_spread)$date_time
))

broom::glance(lm(
  fit_d2H$residuals ~
  na.exclude(d2H_source_spread)$date_time
))

# .... Stream vs rain d18O -----------------------------------------------------

broom::tidy(lm(
  fit_d18O$residuals ~
  na.exclude(d18O_source_spread)$date_time
))

broom::glance(lm(
  fit_d18O$residuals ~
  na.exclude(d18O_source_spread)$date_time
))

# None do!
