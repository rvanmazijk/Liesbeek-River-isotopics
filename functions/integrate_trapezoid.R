integrate_trapezoid <- function(values, interval_breaks,
                                method = c("integrate", "average")) {
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
    # Weighted average of those
    if (method == "average") {
        interval_weights <-
            intervals /
            interval_breaks[length(interval_breaks)]
        weighted_interval_values <-
            interval_weights *
            interval_values
        average <- sum(weighted_interval_values)
        return(average)
    # Or integral...
    } else if (method == "integrate") {
        weighted_interval_values <-
            intervals *
            interval_values
        integral <- sum(interval_values)
        return(integral)
    }
}

# Tests
integrate_trapezoid(rep(1, 11), 1:11, "integrate")
integrate_trapezoid(rep(1, 11), seq(1, 22, 2), "integrate")
# > integrate_trapezoid(0:10, 0:11)
