# Fig. 4. (Running isotope values' averages)
# and Fig. 5. (Running proportion of streamflow made up by rain water)
# R. van Mazijk

source(here::here("setup.R"))

# Define baseflow isotope values -----------------------------------------------

d18O_baseflow <- LRD_tidy %>%
    filter(source == "River") %>%
    slice(1:3) %$% {
        sum(d18O[1:3] * amnt[1:3]) %>%
            divide_by(sum(amnt[1:3]))
    }
d2H_baseflow <- LRD_tidy %>%
    filter(source == "River") %>%
    slice(1:3) %$% {
        sum(d2H[1:3] * amnt[1:3]) %>%
            divide_by(sum(amnt[1:3]))
    }

# Separate rain and stream data ------------------------------------------------

LRD_stream <- LRD_tidy %>%
    filter(source == "River") %>%
    slice(-c(1:3))
LRD_rain <- LRD_tidy %>%
    filter(source == "Rain") %>%
    right_join(select(LRD_stream, date_time)) %>%
    replace_na(list(code = "RAIN no code",
                    d18O = 0,
                    d2H = 0,
                    source = "Rain",
                    amnt = 0))

# Initialise empty columns in data-frame ---------------------------------------

LRD_stream$d18O_stream_t <- NA
LRD_stream$d2H_stream_t <- NA
LRD_stream$d18O_rain_t <- NA
LRD_stream$d2H_rain_t <- NA
LRD_stream$d18O_p_t <- NA
LRD_stream$d2H_p_t <- NA

# Run loop ---------------------------------------------------------------------

for (t in 1:nrow(LRD_stream)) {
    dE_stream_t <- dE_cum_amnt_weighted(LRD_stream[1:t, ])
    dE_rain_t <- dE_cum_amnt_weighted(LRD_rain[1:t, ])
    p_d18O_t <- p_iso(
        dE_stream_t$weighted_d18O,
        d18O_baseflow,
        dE_rain_t$weighted_d18O
    )
    p_d2H_t <- p_iso(
        dE_stream_t$weighted_d2H,
        d2H_baseflow,
        dE_rain_t$weighted_d2H
    )
    LRD_stream$d18O_stream_t[t] <- dE_stream_t$weighted_d18O
    LRD_stream$d2H_stream_t[t] <- dE_stream_t$weighted_d2H
    LRD_stream$d18O_rain_t[t] <- dE_rain_t$weighted_d18O
    LRD_stream$d2H_rain_t[t] <- dE_rain_t$weighted_d2H
    LRD_stream$d18O_p_t[t] <- p_d18O_t
    LRD_stream$d2H_p_t[t] <- p_d2H_t
}
LRD_new <- LRD_stream

# Look at results --------------------------------------------------------------

# Look at final cumulative numbers:
select(LRD_new[23, ], date_time:d2H_p_t)
# Use this in Table 1.

# Visualise results ------------------------------------------------------------

# Heavy data wrangling
LRD_new_for_plot <- LRD_new %>%
    select(date_time:d2H_p_t) %>%
    gather(key = isotope_dE_stream_t, value = dE_stream_t,
           d18O_stream_t:d2H_stream_t) %>%
    mutate(dE_stream_isotope = as_vector(map(str_split(isotope_dE_stream_t, "_"),
                                             `[[`,
                                             1))) %>%
    select(-isotope_dE_stream_t) %>%
    gather(key = isotope_dE_rain_t, value = dE_rain_t,
           d18O_rain_t:d2H_rain_t) %>%
    mutate(
        dE_rain_isotope = as_vector(map(str_split(isotope_dE_rain_t, "_"),
                                        `[[`,
                                        1))) %>%
    select(-isotope_dE_rain_t) %>%
    gather(key = source, value = dE_t,
           dE_stream_t, dE_rain_t) %>%
    mutate(source = ifelse(str_detect(source, "stream"),
                           "stream",
                           "rain")) %>%
    mutate(isotope = ifelse(source == "stream",
                            dE_stream_isotope,
                            dE_rain_isotope)) %>%
    select(-dE_stream_isotope, -dE_rain_isotope) %>%
    gather(key = p_isotope, value = p_t,
           d18O_p_t, d2H_p_t) %>%
    mutate(p_isotope = as_vector(map(str_split(p_isotope, "_"),
                                     `[[`,
                                     1))) %>%
    filter(p_isotope == isotope) %>%
    select(-p_isotope)

# Fig. 4. Cumulative amount-weighted isotope values' averages through the storm
my_palette <- c(
    "#cd6c64",  # light red
    "#8dcf6d",  # light green
    "#983b33",  # dark red
    "#44782b"   # dark green
)
fig_4 <- ggplot(LRD_new_for_plot,
                aes(date_time, dE_t,
                    col = paste(source, isotope))) +
    geom_point(aes(shape = source)) +
    geom_line(aes(group = source)) +
    ylab(expression(paste(delta^{2}, "H (‰)",
                          "                                        ",
                          delta^{18}, "O (‰)"))) +
    scale_color_manual(values = my_palette) +
    scale_shape_manual(values = c(17, 19), labels = c("Rain", "River")) +
    scale_x_datetime(name = "Date & time", date_labels = "%Y-%m-%d %H:%M") +
    facet_grid(isotope ~ ., scales = "free_y") +
    theme_bw() +
    theme(legend.position    = "left",
          legend.title       = element_blank(),
          legend.background  = element_rect(fill = NA, colour = NA),
          strip.background   = element_rect(fill = NA, colour = NA),
          strip.text.y       = element_blank(),
          panel.grid         = element_blank(),
          panel.grid.major.x = element_line(colour = "grey50", linetype = "dashed"),
          panel.grid.minor.x = element_line(colour = "grey75", linetype = "dashed"),
          axis.text.x        = element_text(angle = 0))

# Fig. 5. Proportion of streamflow made up by rain water,
# according to both d2H and d18O, base on cumulative isotope values' averages
# through the storm
my_palette2 <- c(
    "#b73f41",  # red
    "#599f37"   # green
)
fig_5 <- ggplot(LRD_new_for_plot,
                aes(date_time, p_t * 100,
                    col = isotope)) +
    geom_point() +
    geom_line(aes(group = isotope)) +
    ylab("Percent rainfall (%)") +
    scale_color_manual(
        values = my_palette2,
        labels = c(expression(paste(delta^{18}, "O (‰)")),
                   expression(paste(delta^{2}, "H (‰)")))) +
    scale_x_datetime(name = "Date & time", date_labels = "%Y-%m-%d %H:%M") +
    theme_bw() +
    theme(legend.position    = c(0.9, 0.1),
          legend.title       = element_blank(),
          legend.background  = element_rect(fill = NA, colour = NA),
          strip.background   = element_rect(fill = NA, colour = NA),
          strip.text.y       = element_blank(),
          panel.grid         = element_blank(),
          panel.grid.major.x = element_line(colour = "grey50", linetype = "dashed"),
          panel.grid.minor.x = element_line(colour = "grey75", linetype = "dashed"),
          axis.text.x        = element_text(angle = 0))

tiff(here::here("figures/fig-4.tiff"), width = 15, height = 10, units = "cm", res = 500)
fig_4
dev.off()

tiff(here::here("figures/fig-5.tiff"), width = 15, height = 10, units = "cm", res = 500)
fig_5
dev.off()
