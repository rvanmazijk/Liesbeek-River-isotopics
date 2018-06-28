# Fig. 1. Storm timeline
# Ruan van Mazijk, Lucy K. Smyth

source(here::here("setup.R"))

# Tidy data further for this figure --------------------------------------------

# Make a new `type` column, replacing the old, that = "flow" when
# source = river & type = amnt (aot d18O or d2H).
LRD_tidy_fig_1 <- LRD_tidy %>%
    gather("type", "amnt", c(d18O, d2H, amnt)) %>%
    mutate(type = as.factor(replace(type,
                                    (source == "River" & type == "amnt"),
                                    "flow"))) %>%
    mutate(source_type = as.factor(paste0(source, "_", type)))

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

# Calculate cumulative rainfall ------------------------------------------------

LRD_cumul_rain <- LRD_tidy_fig_1 %>%
    arrange(date_time) %>%
    filter(source_type == "Rain_amnt") %>%
    mutate(cum_amnt = cumsum(amnt))

LRD_tidy_gather_with_cumul_rain <- LRD_cumul_rain %>%
    transmute(code = code,
              source = source,
              date_time = date_time,
              type = type,
              amnt = cum_amnt,
              source_type = rep("cum_rain", times = nrow(LRD_cumul_rain))) %>%
    rbind(LRD_tidy_fig_1) %>%
    insert_cumul_rain_type()

# Reorder the factors in `$type`
LRD_tidy_gather_with_cumul_rain$type %<>% factor(levels = c(
    "cum_rain",
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
    "#55a0c7",  # light blue
    "#cd6c64",  # light red
    "#8dcf6d",  # light green
    "#983b33",  # dark red
    "#44782b",  # dark green
    "#000000"   # black
)

# Create panel labels
my_facet_labels <- c(
    cum_rain = "A)",
    amnt     = "B)",
    flow     = "C)",
    d18O     = "D)",
    d2H      = "E)"
)

# Plot!
base_plot <- ggplot(LRD_tidy_gather_with_cumul_rain) +
    geom_point(aes(x = date_time, y = amnt, col = source_type, shape = source)) +
    scale_shape_manual(values = c(17, 19)) +
    geom_line(aes(x = date_time, y = amnt, col = source_type)) +
    # Changing the date axis tickmarks and name:
    scale_x_datetime(name = "Date & time", date_labels = "%Y-%m-%d %H:%M")

styled_plot <- base_plot +
    # Plot the different types (cum_rain, rain, river, d18O, d2H) as panels:
    # (with my custom facet labels!)
    facet_grid(scales = "free",
               labeller = as_labeller(my_facet_labels),
               type ~ .) +
    # Apply my colour palette, and rename the legend labels:
    guides(col = guide_legend(ncol = 1, label.position = "right")) +
    scale_color_manual(
        values = my_palette,
        labels = c(expression(paste("Cumulative rainfall (", {m}^{3}, ")")),
                   expression(paste("Rainfall (", {m}^{3}, {h}^{-1}, ")")),
                   expression(paste("Streamflow (", {m}^{3}, {h}^{-1}, ")")),
                   expression(paste(delta^{18}, "O rain (‰)")),
                   expression(paste(delta^{18}, "O stream (‰)")),
                   expression(paste(delta^{2}, "H rain (‰)")),
                   expression(paste(delta^{2}, "H stream (‰)"))),
        breaks = levels(factor(LRD_tidy_gather_with_cumul_rain$source_type,
			       levels = c("cum_rain",
                                          "Rain_amnt",
                                          "River_flow",
                                          "Rain_d18O",
                                          "River_d18O",
                                          "Rain_d2H",
                                          "River_d2H"))))

themed_plot <- styled_plot +
    theme_bw() +
    theme(legend.position    = "left",
          legend.title       = element_blank(),
          strip.background   = element_rect(fill = NA, colour = NA),
          strip.text.y       = element_text(angle = 0),
          panel.grid         = element_blank(),
          panel.grid.major.x = element_line(colour = "grey50", linetype = "dashed"),
          panel.grid.minor.x = element_line(colour = "grey75", linetype = "dashed"),
          axis.text.x        = element_text(angle = 0),
          axis.title.y       = element_blank())

fig_1 <- themed_plot

tiff(here::here("figures/fig-1.tiff"), width = 25, height = 15, units = "cm", res = 300)
fig_1
dev.off()
