p_iso <- function(stream_value, baseflow, rain_value) {
    return(
        (stream_value - baseflow) /
        (rain_value - baseflow)
    )
}
