# Fig. 3. Meteoric water plot (d2H vs d18O)
# Ruan van Mazijk

source(here::here("analyses/setup.R"))

# Find LMWL --------------------------------------------------------------------

fit_harris <- lm(dD ~ d18O, data = harris_uct)

# Find MWLs for river- and rainwater -------------------------------------------

fit_rain <- lm(d2H ~ d18O, LRD_tidy %>% filter(source == "Rain"))
fit_river <- lm(d2H ~ d18O, LRD_tidy %>% filter(source == "River"))

# Amount-weighted iso values ---------------------------------------------------

# For rain near Liesbeek, UCT & Skeleton Gorge
extra_sites
# Note:
# MOW = Mowbray, Cape Town
# JDB = John Day Bldg, UCT Upper Campus
# SKG = Skeleton Gorge, Table Mountain

# For MAP from Harris data set, w/ SD for error bars
harris_MAP <- harris_uct %>%
  select(dD, d18O, amount) %>%
  rename(d2H = dD, amnt = amount) %>%
  mutate(d2H_x_amnt = d2H * amnt,
         d18O_x_amnt = d18O * amnt) %>%
  summarise(weighted_d2H = sum(d2H_x_amnt) / sum(amnt),
            weighted_d18O = sum(d18O_x_amnt) / sum(amnt))

# Prestorm streamwater isotope values w/ SD for error bars
baseflow <- LRD_tidy %>%
  filter(source == "River") %>%
  arrange(date_time) %>%
  slice(1:3) %>%
  mutate(d2H_x_amnt = d2H * amnt,
         d18O_x_amnt = d18O * amnt) %>%
  summarise(weighted_d2H = sum(d2H_x_amnt) / sum(amnt),
            weighted_d18O = sum(d18O_x_amnt) / sum(amnt))

# Compile
amnt_weighted_iso <- tibble(
  point = c(
    "Stream baseflow",
    "MAP",
    "Mowbray",
    "Skeleton Gorge",
    "UCT"
  ),
  d2H_avg = c(
    baseflow$weighted_d2H,
    harris_MAP$weighted_d2H,
    extra_sites$d2H
  ),
  d18O_avg = c(
    baseflow$weighted_d18O,
    harris_MAP$weighted_d18O,
    extra_sites$d18O
  )
)
amnt_weighted_iso$point %<>% factor(levels = c(
  "Stream baseflow",
  "MAP",
  "Mowbray",
  "Skeleton Gorge",
  "UCT"
))

# Make plot --------------------------------------------------------------------

base_plot <- LRD_tidy %>%
  filter(source == "Rain") %>%
  ggplot() +
  geom_abline(intercept = fit_harris$coefficients[1],
              slope = fit_harris$coefficients[2],
              linetype = "dashed",
              col = "grey50",
              size = 0.7) +
  geom_smooth(aes(x = d18O, y = d2H),
              method = lm,
              alpha = 0.25,
              col = "#55a0c7",
              size = 0.7) +
  geom_point(aes(d18O, d2H, size = amnt), col = "#55a0c7") +
  scale_size_continuous(name = "Rainfall (mm)", range = c(1, 7)) +
  ylab(expression(paste(delta^{2},  "H (‰)"))) +
  xlab(expression(paste(delta^{18}, "O (‰)"))) +
  ylim(-41, 0) +
  xlim(-8, 0) +
  annotate(geom = "text",
           label = "LMWL",
           x = -0.5,
           y = -5,
           col = "grey50",
           size = 5)

annotated_plot <- base_plot +
  geom_point(data = amnt_weighted_iso,
             aes(d18O_avg, d2H_avg,
             shape = point, col = point),
             size = 3) +
  scale_shape_manual(name = "", values = c(19, 15, 19, 17, 15)) +
  scale_color_manual(name = "", values = c("#000000",
                                           "grey50",
                                           "#205979",
                                           "#205979",
                                           "#205979")) +
  # Text annotations of regression line
  annotate(geom = "text",
       parse = TRUE,
       label = paste0("italic(R)^{2} == ",
                      format(summary(fit_rain)$r.squared,
                             digits = 3)),
       x = 0, y = -30,
       hjust = 1,
       size = 4,
       col = "#0f4969") +
  annotate(geom = "text",
       parse = TRUE,
       label = paste0("Slope == ",
                      format(summary(fit_rain)$coefficients[2],
                             digits = 4)),
       x = 0, y = -35,
       hjust = 1,
       size = 4,
       col = "#0f4969") +
  annotate(geom = "text",
       parse = TRUE,
       label = paste0("italic(P)[slope] < 0.001"),
       x = 0, y = -40,
       hjust = 1,
       size = 4,
       col = "#0f4969")

themed_plot <- annotated_plot +
  theme_bw() +
  theme(panel.grid = element_blank(),
        strip.background = element_rect(fill = NA, colour = NA),
        strip.text.x = element_blank())

fig_3 <- themed_plot

tiff(
  here::here("figures/fig-3.tiff"),
  width = 15, height = 10,
  units = "cm",
  res = 300
)
fig_3
dev.off()
