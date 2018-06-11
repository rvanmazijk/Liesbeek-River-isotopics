insert_cumul_rain_type <- function(x) {
    x$type %<>% as.character()
    for (i in 1:nrow(x)) {
        x$type[i] <-
            if (x$source_type[i] == "cum_rain") {
                "cum_rain"
            } else {
                x$type[i]
            }
    }
    x$type %<>% as.factor()
    return(x)
}
