total_discharge_steps <- function(Q, t) {
    # Q = streamflow discharge rate (exclude times w/ no Q value!)
    # t = time
    stopifnot(length(Q) == length(t))
    t <- c(0, t) # To get final Q * (t_{i+1} - t_{i}) vectors to same length
    return(sum(
        Q *
        (t[2:length(t)] - t[1:(length(t) - 1)])
    ))
}

# Tests
if (FALSE) {
    Q <- c(4, 2, 1, 2, 3, 1)
    t <- c(2, 3, 4, 5, 6, 9)
    total_discharge_steps(Q, t)
}
