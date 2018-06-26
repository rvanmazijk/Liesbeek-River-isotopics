# Mass balance model of rainfall contribution to streamflow
# Ruan van Mazijk

source(here::here("setup.R"))

# Define baseflow isotope values -----------------------------------------------

baseflow <- list(d18O = NULL, d2H = NULL)

baseflow$d18O <- LRD_tidy %>%
    filter(source == "River") %>%
    slice(1:3) %$% {
        sum(d18O[1:3] * amnt[1:3]) %>%
            divide_by(sum(amnt[1:3]))
    }
baseflow$d2H <- LRD_tidy %>%
    filter(source == "River") %>%
    slice(1:3) %$% {
        sum(d2H[1:3] * amnt[1:3]) %>%
            divide_by(sum(amnt[1:3]))
    }

# Separate rain and stream data ------------------------------------------------

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
u <- list(
    d18O = NULL,  # TODO
    d2H = NULL
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
u_p_rain <-  abs(p_rain) * (sqrt(u_p$d18O^2 + u_p$d2H^2) / (p$d18O + p$d2H))

# Done
p_rain
u_p_rain
