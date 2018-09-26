# Mass balance model of rainfall contribution to streamflow
# Ruan van Mazijk

source(here::here("analyses/setup.R"))

# Define baseflow, streamflow and rain isotope values --------------------------

baseflow <- LRD_tidy %>%
  filter(source == "River") %>%
  slice(1:3) %>%
  mutate(d18O_x_amnt = d18O * amnt,
         d2H_x_amnt = d2H * amnt) %>%
  summarise(weighted_d18O = sum(d18O_x_amnt) / sum(amnt),
            weighted_d2H = sum(d2H_x_amnt) / sum(amnt)) %$%
  list(d18O = weighted_d18O,
       d2H = weighted_d2H)
streamflow <- LRD_tidy %>%
  filter(source == "River") %>%
  slice(-c(1:3)) %>%
  mutate(d18O_x_amnt = d18O * amnt,
         d2H_x_amnt = d2H * amnt) %>%
  summarise(weighted_d18O = sum(d18O_x_amnt) / sum(amnt),
            weighted_d2H = sum(d2H_x_amnt) / sum(amnt)) %$%
  list(d18O = weighted_d18O,
       d2H = weighted_d2H)
rain <- LRD_tidy %>%
  filter(source == "Rain") %>%
  mutate(d18O_x_amnt = d18O * amnt,
         d2H_x_amnt = d2H * amnt) %>%
  summarise(weighted_d18O = sum(d18O_x_amnt) / sum(amnt),
            weighted_d2H = sum(d2H_x_amnt) / sum(amnt)) %$%
  list(d18O = weighted_d18O,
       d2H = weighted_d2H)

# Uncertainty (u)
precision <- list(
  d18O = 0.07,
  d2H = 0.2
)
accuracy <- list(
  d18O = 0.13,
  d2H = 1.5
)
u <- list(
  d18O = sqrt(precision$d18O ^ 2 + accuracy$d18O ^ 2),
  d2H = sqrt(precision$d2H ^ 2 + accuracy$d2H ^ 2)
)

# Calculations -----------------------------------------------------------------

# Find p_rain according to each isotope

p <- list(d18O = NULL, d2H = NULL)
p$d18O <- (streamflow$d18O - baseflow$d18O) / (rain$d18O - baseflow$d18O)
p$d2H <- (streamflow$d2H - baseflow$d2H) / (rain$d2H - baseflow$d2H)
p_rain <- (p$d18O + p$d2H) / 2

# Propagate uncertainties with Genereux 1998 method ----------------------------

u_p_E <- function(baseflow, rain, streamflow, u) {
  sqrt(
    (u * ((rain - streamflow) / (rain - baseflow)^2))^2 +
    (u * ((streamflow - baseflow) / (rain - baseflow)^2))^2 +
    (u * (-1 / (rain - baseflow))^2)
  )
}

u_p_d18O_Genereux <- u_p_E(
  baseflow$d18O,
  rain$d18O,
  streamflow$d18O,
  u$d18O
)
u_p_d2H_Genereux <- u_p_E(
  baseflow$d2H,
  rain$d2H,
  streamflow$d2H,
  u$d2H
)
p_rain_Genereux <- (p$d18O + p$d2H) / 2
u_p_rain_Genereux <-  abs(p_rain_Genereux) *
  (sqrt(u_p_d18O_Genereux^2 + u_p_d2H_Genereux^2) / (p$d18O + p$d2H))

# Done
message(paste(
  "The proportion of streamflow derived from rainfall is:",
  "\n    According to d18O:            ", p$d18O, "+-", u_p_d18O_Genereux,
  "\n    According to d2H:             ", p$d2H, "+-", u_p_d2H_Genereux,
  "\n    Therefore, average proportion:", p_rain_Genereux, "+-", u_p_rain_Genereux
))

