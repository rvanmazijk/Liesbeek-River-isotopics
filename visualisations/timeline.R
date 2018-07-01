# Liesbeek River storm timeline
# Ruan van Mazijk

source(here::here("analyses/setup.R"))

# ...

LRD_tidy %<>% mutate(hours_of_storm = difftime(date_time,
                                               date_time[source == "River"][4],
                                               units = "hours") %>%
                                      as.numeric())

ggplot(LRD_tidy, aes(hours_of_storm, d18O)) +
  geom_line(aes(group = source, col = source)) +
  xlab("Hours of storm")

# ...

# Tidy data further for this figure --------------------------------------------

# Make a new `type` column, replacing the old, that = "flow" when
# source = river & type = amnt (aot d18O or d2H).
LRD_tidy_fig_1 <- LRD_tidy %>%
  gather("type", "amnt", c(d18O, d2H, amnt)) %>%
  mutate(type = as.factor(replace(type,
                                  (source == "River" & type == "amnt"),
                                  "flow"))) %>%
  mutate(source_type = as.factor(paste0(source, "_", type)),
         hours_of_storm = difftime(date_time,
                                   date_time[source == "River"][4],
                                   units = "hours") %>%
                          as.numeric())

# Reorder some factors:
LRD_tidy_fig_1$source_type %<>% factor(c(
  "Rain_amnt", "River_flow",
  "Rain_d18O", "River_d18O",
  "Rain_d2H",  "River_d2H"
))
LRD_tidy_fig_1$type %<>% factor(c(
  "amnt", "flow",
  "d18O", "d2H"
))
LRD_tidy_fig_1$amnt %<>% as.numeric()

# Get time information when no rain
rain_times <- LRD_tidy_fig_1 %>%
  filter(source_type == "Rain_amnt") %>%
  select(date_time) %>%
  as.data.frame()
river_times <- LRD_tidy_fig_1 %>%
  filter(source_type == "River_flow") %>%
  select(date_time) %>%
  as.data.frame()
no_rain <- data.frame(
  code = rep("NO_RAIN", 10),
  source = rep("Rain", 10),
  date_time = anti_join(river_times, rain_times),
  type = rep("amnt", 10),
  amnt = rep(0, 10),
  source_type = rep("Rain_amnt", 10)
)
LRD_tidy_fig_1 %<>% rbind(no_rain)

# Reorder the factors in `$type`
LRD_tidy_fig_1$type %<>% factor(levels = c(
  "amnt",
  "flow",
  "d18O",
  "d2H"
))

# Create the timeline plot -----------------------------------------------------

# Define colour palette
# With help from <http://www.colourco.de>
my_palette <- c(
  "#55a0c7",  # light blue
  "#000000",  # black
  "#cd6c64",  # light red
  "#983b33",  # dark red
  "#8dcf6d",  # light green
  "#44782b"   # dark green
)

# Plot!
base_plot <- ggplot(LRD_tidy_fig_1) +
  geom_line(aes(hours_of_storm, amnt,
                col = source_type)) +
  # Changing the date axis tickmarks and name:
  xlab("Hours of storm")

styled_plot <- base_plot +
  # Plot the different types (cum_rain, rain, river, d18O, d2H) as panels:
  # (with my custom facet labels!)
  facet_grid(scales = "free", type ~ .) +
  # Apply my colour palette, and rename the legend labels:
  guides(col = guide_legend(ncol = 1, label.position = "right")) +
  scale_color_manual(
    values = my_palette,
    labels = c(expression(paste("Rainfall (", {m}^{3}, {h}^{-1}, ")")),
               expression(paste("Streamflow (", {m}^{3}, {h}^{-1}, ")")),
               expression(paste(delta^{18}, "O rain (‰)")),
               expression(paste(delta^{18}, "O stream (‰)")),
               expression(paste(delta^{2}, "H rain (‰)")),
               expression(paste(delta^{2}, "H stream (‰)"))),
    breaks = levels(factor(LRD_tidy_fig_1$source_type,
			               levels = c("Rain_amnt",
                                "River_flow",
                                "Rain_d18O",
                                "River_d18O",
                                "Rain_d2H",
                                "River_d2H"))))

themed_plot <- styled_plot +
  theme_bw() +
  theme(legend.position = "left",
        legend.title = element_blank(),
        strip.background = element_rect(fill = NA, colour = NA),
        strip.text.y = element_blank(),
        panel.grid = element_blank(),
        panel.border = element_blank(),
        axis.line.x = element_line(),
        axis.line.y = element_line(),
        axis.text.x = element_text(angle = 0),
        axis.title.y = element_blank())

fig_1 <- themed_plot

tiff(
  here::here("fig-1.tiff"),
  width = 25, height = 15,
  units = "cm",
  res = 300
)
fig_1
dev.off()
