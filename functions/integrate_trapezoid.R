integrate_trapezoid <- function(values, interval_breaks) {
    stopifnot(length(values) == length(interval_breaks))
    # Add zeroes to start and end of sequences
    values <- c(0, values, 0)
    interval_breaks <- c(
        interval_breaks[1] - 1,
        interval_breaks,
        interval_breaks[length(interval_breaks)] + 1)
    # Calculate intervals themselves
    intervals <-
        interval_breaks[2:length(interval_breaks)] -
        interval_breaks[1:(length(interval_breaks) - 1)]
    # Average value in each interval
    interval_values <-
        (values[1:(length(values) - 1)] +
        values[2:length(values)]) /
        2
    # Calculate integral proper
    weighted_interval_values <-
        intervals *
        interval_values
    integral <- sum(interval_values)
    return(integral)
}

# Tests
integrate_trapezoid(rep(1, 11), 1:11)
integrate_trapezoid(rep(1, 11), seq(1, 22, 2))
# > integrate_trapezoid(0:10, 0:11)
