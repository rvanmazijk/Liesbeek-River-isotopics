# Bayesian mixing model of Liesbeek stormwater data"
# R. van Mazijk

source(here::here("Analyses-v2/04_amnt-weighted-iso-and-p_v2.R"))

# Prepare the data -------------------------------------------------------------

baseflow_means <- tibble(
    d18O = d18O_baseflow,
    d2H = d2H_baseflow
)
baseflow_sds <- LRD_tidy %>%
    filter(source == "River") %>%
    select(d18O, d2H) %>%
    slice(1:3) %>%
    summarise_all(sd)
rainfall_means <- tibble(
    d18O = LRD_new$d18O_rain_t[23],
    d2H = LRD_new$d2H_rain_t[23])
rainfall_sds <- LRD_tidy %>%
    filter(source == "Rain") %>%
    select(d18O, d2H) %>%
    slice(1:3) %>%
    summarise_all(sd)

# Load data into simmr format --------------------------------------------------

simmr_in <- simmr_load(
    mixtures = LRD_tidy %>%
        filter(source == "River") %>%
        select(d18O, d2H) %>%
        slice(-c(1:3)) %>%  # Exclude baseflow
        as.matrix(),
    source_names = c("baseflow", "rainfall"),
    source_means = rbind(baseflow_means, rainfall_means),
    source_sds = rbind(baseflow_sds, rainfall_sds)
)

# Visualise
plot(simmr_in)

# Run the BMCMC ----------------------------------------------------------------

simmr_out <- simmr_mcmc(simmr_in)

# Explore results
summary(simmr_out, type = "diagnostics")
summary(simmr_out, type = "statistics")

# Visualise
plot(simmr_out, type = "density")
plot(simmr_out, type = "matrix")
compare_sources(simmr_out, source_names = c("rainfall", "baseflow"))
