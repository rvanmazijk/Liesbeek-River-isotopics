# Fig. 3. Meteoric water plot (d2H vs d18O)
# R. van Mazijk

source(here::here("00_setup.R"))

# Find LMWL --------------------------------------------------------------------

fit_harris <- lm(dD ~ d18O, data = harris_uct)

# Find MWLs for river- and rainwater -------------------------------------------

fit_rain  <- lm(d2H ~ d18O, LRD_tidy %>% filter(source == "Rain"))
fit_river <- lm(d2H ~ d18O, LRD_tidy %>% filter(source == "River"))

# Amount-weighted iso values ---------------------------------------------------

# For rain near Liesbeek
LR_site <- LRD_tidy %>%
    filter(source == "Rain") %>%
    # Calculate amount weighted isotope scores from near-Liesbeeck site
    mutate(
        d18O_x_amnt = d18O * amnt,
        d2H_x_amnt  = d2H * amnt) %>%
    summarise(
        weighted_d18O = sum(d18O_x_amnt) / sum(amnt),
        weighted_d2H = sum(d2H_x_amnt) / sum(amnt))

# UCT & Skeleton Gorge
extra_sites
# Note:
# JDB = John Day Bldg, UCT Upper Campus,
# SKG = Skeleton Gorge, Table Mountain

# For MAP from Harris data set, w/ SD for error bars
harris_MAP <- harris_uct %>%
    select(Year, dD, d18O, amount) %>%
    rename(year = Year, d2H = dD, amnt = amount) %>%
    group_by(year) %>%
    mutate(
        d2H_x_amnt = d2H * amnt,
        d18O_x_amnt = d18O * amnt) %>%
    summarise(
        weighted_d18O = sum(d18O_x_amnt) / sum(amnt),
        weighted_d2H = sum(d2H_x_amnt) / sum(amnt)) %>%
    summarise(
        mean(weighted_d18O),
        sd(weighted_d18O),
        mean(weighted_d2H),
        sd(weighted_d2H))

# Prestorm streamwater isotope values w/ SD for error bars
prestorm <- LRD_tidy %>%
    filter(source == "River") %>%
    arrange(date_time) %>%
    slice(1:3) %>%
    summarise(
        mean(d18O),
        sd(d18O),
        mean(d2H),
        sd(d2H))

# Compile
amnt_weighted_iso <- tibble(
    point = c(
        "PRE",
        "MAP",
        "MOW", "SKG", "UCT"),
    d2H_avg = c(
        prestorm$`mean(d2H)`,
        harris_MAP$`mean(weighted_d2H)`,
        LR_site$weighted_d2H, extra_sites$d2H[2], extra_sites$d2H[1]),
    d2H_sd = c(
        prestorm$`sd(d2H)`,
        harris_MAP$`sd(weighted_d2H)`,
        NA, NA, NA),
    d18O_avg = c(
        prestorm$`mean(d18O)`,
        harris_MAP$`mean(weighted_d18O)`,
        LR_site$weighted_d18O, extra_sites$d18O[2], extra_sites$d18O[1]),
    d18O_sd = c(
        prestorm$`sd(d18O)`,
        harris_MAP$`sd(weighted_d18O)`,
        NA, NA, NA)) %>%
    mutate(
        d2H_lower = d2H_avg - d2H_sd,
        d2H_upper = d2H_avg + d2H_sd,
        d18O_lower = d18O_avg - d18O_sd,
        d18O_upper = d18O_avg + d18O_sd)
amnt_weighted_iso$point %<>%
    as.factor() %>%
    relevel("PRE")

# Make plot --------------------------------------------------------------------

base_plot <- LRD_tidy %>%
    filter(source == "Rain") %>%
    ggplot() +
    # LMWL
    # TODO: add LMWL slope etc. in caption
    geom_abline(
        intercept = fit_harris$coefficients[1],
        slope = fit_harris$coefficients[2],
        linetype = "dashed",
        col = "grey50",
        size = 0.7) +
    geom_smooth(
        method = lm,
        aes(x = d18O, y = d2H),
        alpha = 0.25,
        col = "#55a0c7",
        size = 0.7) +
    geom_point(aes(d18O, d2H, size = amnt), col = "#55a0c7") +
    scale_size_continuous(name = "Rainfall (mm)", range = c(1, 7)) +
    ylab(expression(paste(delta^{2},  "H (‰)"))) +
    xlab(expression(paste(delta^{18}, "O (‰)"))) +
    ylim(-41, 0) +
    xlim(-8, 0) +
    annotate(
        geom =  "text",
        label = "LMWL",
        x = -1.5,
        y = -15,
        col = "grey50",
        size = 5)
    # TODO: put "rain-water" and "river-water" panel labels back

annotated_plot <- base_plot +
    geom_point(
        data = amnt_weighted_iso,
        aes(d18O_avg, d2H_avg, shape = point),
        size = 4, fill = "#55a0c7") +
    scale_shape_manual(values = c(21, 22, 15, 17, 19), name = "") +
    geom_errorbar(
        data = amnt_weighted_iso,
        aes(d18O_avg, ymin = d2H_lower, ymax = d2H_upper),
        width = 0) +
    geom_errorbarh(
        data = amnt_weighted_iso,
        aes(d18O_avg, d2H_avg, xmin = d18O_lower, xmax = d18O_upper),
        height = 0) +
    # Text annotations of regression line
    annotate(
        geom = "text",
        parse = TRUE,
        label = paste0(
            "italic(R)^{2} == ",
            format(
                summary(fit_rain)$r.squared,
                digits = 3)),
        x = 0, y = -30,
        hjust = 1,
        size = 4,
        col = "#0f4969") +
    annotate(
        geom = "text",
        parse = TRUE,
        label = paste0(
             "Slope == ",
             format(
                 summary(fit_rain)$coefficients[2],
                 digits = 4)),
        x = 0, y = -35,
        hjust = 1,
        size = 4,
        col = "#0f4969") +
    annotate(
        geom = "text",
        parse = TRUE,
        label = paste0(
            "italic(P)[slope] < 0.001"),
        x = 0, y = -40,
        hjust = 1,
        size = 4,
        col = "#0f4969")

themed_plot <- annotated_plot +
    theme_bw() +
    theme(
        panel.grid       = element_blank(),
        strip.background = element_rect(fill = NA, colour = NA),
        strip.text.x     = element_blank())

fig_3 <- themed_plot

tiff("fig-3.tiff", width = 15, height = 10, units = "cm", res = 300)
fig_3
dev.off()

