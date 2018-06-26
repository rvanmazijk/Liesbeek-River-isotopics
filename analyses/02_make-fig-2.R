# Fig. 2. Stream vs rain
# R. van Mazijk

source(here::here("setup.R"))

# Tidy data further for this figure --------------------------------------------

# Panel a
rain_river_spread <- LRD_tidy %>%
    select(source, amnt, date_time) %>%
    spread(key = source, value = amnt)
rain_river_spread$Rain[is.na(rain_river_spread$Rain)] <- 0

# Panel b
d18O_source_spread <- LRD_tidy %>%
    select(source, d18O, date_time) %>%
    spread(key = source, value = d18O) %>%
    as_tibble()

# Panel c
d2H_source_spread <- LRD_tidy %>%
    select(source, d2H, date_time) %>%
    spread(key = source, value = d2H) %>%
    as_tibble()

# Linear fits used in plots ----------------------------------------------------

fit_stream_vs_rain <- lm(River ~ Rain, rain_river_spread)
fit_d2H <- lm(River ~ Rain, d2H_source_spread)
fit_d18O <- lm(River ~ Rain, d18O_source_spread)

# Stream-flow vs rain-fall -----------------------------------------------------

make_panel_a <- function() {

    base_plot <- ggplot(rain_river_spread) +
        geom_smooth(aes(Rain, River),
                    method = lm,
                    alpha = 0.25,
                    col = "#000000",
                    size = 0.7) +
        geom_point(aes(Rain, River), col = "#000000") +
        xlab(expression(paste("Rainfall (m"^{3}, "h"^{-1}, ")"))) +
        ylab(expression(paste("Streamflow (m"^{3}, "h"^{-1}, ")"))) +
        xlim(c(0, 12.5))

    # Summary stats
    annotated_plot <- base_plot +
        annotate(geom = "text",
                 parse = TRUE,
                 label = paste0("italic(R)^{2} == ",
                                format(summary(fit_stream_vs_rain)$r.squared,
                                       digits = 3)),
                 x = 12, y = 1500,
                 hjust = 1,
                 col = "#000000",
                 size = 4) +
        annotate(geom = "text",
                 parse = TRUE,
                 label = paste0("italic(P)[slope] < 0.001"),
                 x = 12, y = 500,
                 hjust = 1,
                 col = "#000000",
                 size = 4)

    # TODO: beta needed?
    #annotate(
    #  geom = "text", parse = T,
    #  label = paste0(
    #    "italic(beta)[1] == ",
    #    format(summary(fit_stream_vs_rain)$coefficients[2], digits = 4)
    #  ),
    #  x = 10, y = 1000, size = 4, col = "#0f4969"
    #) +

    themed_plot <- annotated_plot +
        theme_bw() +
        theme(panel.grid = element_blank())

    panel_a <- themed_plot
    return(panel_a)

}

# Stream-water iso vs rain-water iso -------------------------------------------

make_panel_bc <- function(isotope = c("d2H", "d18O")) {

    base_plot <-
        ggplot(data = switch(isotope,
            "d2H" = d2H_source_spread,
            "d18O" = d18O_source_spread)) +
        geom_point(aes(x = Rain, y = River),
                   col = switch(isotope,
                       "d2H" = "#599f37",
                       "d18O" = "#b73f41")) +
        geom_smooth(aes(x = Rain, y = River),
                    method = lm,
                    alpha = 0.25,
                    col = switch(isotope,
                        "d2H" = "#599f37",
                        "d18O" = "#b73f41"),
                    size = 0.7) +
        xlab(switch(isotope,
            "d2H" = expression(paste(delta^{2}, "H"["Rain" ], "(‰)")),
            "d18O" = expression(paste(delta^{18}, "O"["Rain" ], "(‰)")))) +
        ylab(switch(isotope,
            "d2H" = expression(paste(delta^{2}, "H"["Stream" ], "(‰)")),
            "d18O" = expression(paste(delta^{18}, "O"["Stream" ], "(‰)")))) +
        xlim(switch(isotope,
            "d2H" = c(-40, -5),
            "d18O" = c(-8, -2))) +
        ylim(switch(isotope,
            "d2H" = c(-40, -5),
            "d18O" = c(-8, -2)))

    annotated_plot <- base_plot +
        annotate(geom = "text",
                 label = switch(isotope,
                     "d2H" = paste0("italic(R)^{2} == ",
                                    format(summary(fit_d2H)$r.squared,
                                           digits = 3)),
                     "d18O" = paste0("italic(R)^{2} == ",
                                     format(summary(fit_d18O)$r.squared,
                                            digits = 3))),
                 parse = TRUE,
                 hjust = 1,
                 x = switch(isotope,
                     "d2H" = -5,
                     "d18O" = -2),
                 y = switch(isotope,
                     "d2H" = -30,
                     "d18O" = -6.5),
                 col = switch(isotope,
                     "d2H" = "#599f37",
                     "d18O" = "#b73f41"),
                 size = 4) +
        annotate(geom = "text",
                 label = switch(isotope,
                     "d2H" = paste0("Slope == ",
                                    format(summary(fit_d2H)$coefficients[2],
                                           digits = 3)),
                     "d18O" = paste0("Slope == ",
                                     format(summary(fit_d18O)$coefficients[2],
                                            digits = 3))),
                 parse = TRUE,
                 hjust = 1,
                 x = switch(isotope,
                     "d2H" = -5,
                     "d18O" = -2),
                 y = switch(isotope,
                     "d2H" = -35,
                     "d18O" = -7.25),
                 col = switch(isotope,
                     "d2H" = "#599f37",
                     "d18O" = "#b73f41"),
                 size = 4) +
        annotate(geom = "text",
                 label = switch(isotope,
                     "d2H" = paste0("italic(P)[slope] < 0.001"),
                     "d18O" = paste0("italic(P)[slope] == 0.001")),
                 parse = TRUE,
                 hjust = 1,
                 x = switch(isotope,
                     "d2H" = -5,
                     "d18O" = -2),
                 y = switch(isotope,
                     "d2H" = -40,
                     "d18O" = -8),
                 col = switch(isotope,
                     "d2H" = "#599f37",
                     "d18O" = "#b73f41"),
                 size = 4)

    themed_plot <- annotated_plot +
        theme_bw() +
        theme(panel.grid      = element_blank(),
              legend.position = "none",
              legend.title    = element_blank())

    panel_bc <- themed_plot
    return(panel_bc)

}

# Arrange panels a, b, and c
stream_vs_rain <- make_panel_a()
d18O_stream_vs_rain <- make_panel_bc(isotope = "d18O")
d2H_stream_vs_rain <- make_panel_bc(isotope = "d2H")
arranged_panels <- cowplot::plot_grid(
    plotlist = list(
        stream_vs_rain,
        d18O_stream_vs_rain,
        d2H_stream_vs_rain
    ),
    labels = c("A)", "B)", "C)"),
    ncol = 1,
    align = "v")

fig_2 <- arranged_panels

tiff(here::here("figures/fig-2.tiff"), width = 10, height = 20, units = "cm", res = 300)
fig_2
dev.off()
