dE_cum_amnt_weighted <- function(x) {
    out <- x %>%
        mutate(
            d18O_x_amnt = d18O * amnt,
            d2H_x_amnt = d2H * amnt) %>%
        summarise(
            weighted_d18O = sum(d18O_x_amnt) / sum(amnt),
            weighted_d2H = sum(d2H_x_amnt) / sum(amnt))
    return(out)
}
