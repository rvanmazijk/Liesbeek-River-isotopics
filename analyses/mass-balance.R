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

# Uncertainty (u_q) propagation rules
#   1. Constants
#       q = bx
#       u_q / q = u_x / x
#   2. Sums
#       q = x + y + z
#       u_q = sqrt(u_x^2 + u_y^2 + u_z^2)
#   3. Products/quotients
#       q = xyz
#       u_q / abs(q) = sqrt((u_x / x)^2 + (u_y / y)^2 + (u_z / z)^2)

# And using "Ruan's propagation" from uncertainty-propagation.html

p <- list(d18O = NULL, d2H = NULL)
u_p <- list(d18O = NULL, d2H = NULL)

p$d18O <- (streamflow$d18O - baseflow$d18O) / (rain$d18O - baseflow$d18O)
u_p$d18O <- abs(p$d18O) * sqrt(
  (sqrt(u$d18O^2 + u$d18O^2) / (streamflow$d18O - baseflow$d18O)) ^ 2 +
  (sqrt(u$d18O^2 + u$d18O^2) / (rain$d18O - baseflow$d18O)) ^ 2
)

p$d2H <- (streamflow$d2H - baseflow$d2H) / (rain$d2H - baseflow$d2H)
u_p$d2H <- abs(p$d2H) * sqrt(
  (sqrt(u$d2H^2 + u$d2H^2) / (streamflow$d2H - baseflow$d2H)) ^ 2 +
  (sqrt(u$d2H^2 + u$d2H^2) / (rain$d2H - baseflow$d2H)) ^ 2
)

p_rain <- (p$d18O + p$d2H) / 2
u_p_rain <- abs(p_rain) * (sqrt(u_p$d18O^2 + u_p$d2H^2) / (p$d18O + p$d2H))

# Done
p_rain
u_p_rain

# Calculations--Genereux 1998 method -------------------------------------------

u_p_E <- function(baseflow, rain, streamflow, u) {
  return(sqrt(
    (u * ((rain - streamflow) / (rain - baseflow)^2))^2 +
    (u * ((streamflow - baseflow) / (rain - baseflow)^2))^2 +
    (u * (-1 / (rain - baseflow))^2)
  ))
}
u_p_E_Ruan <- function(baseflow, rain, u) {
  return(u * (2 / (rain - baseflow)))
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
u_p_d18O_Genereux
u_p_d2H_Genereux
p_rain_Genereux
u_p_rain_Genereux
