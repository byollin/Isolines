#' validate_coords
#' 
#' Validate latitude and longitude coordinates.
#' 
#' @param coords coordinates to validate
#' 
#' @return TRUE or FALSE

# https://stackoverflow.com/questions/3518504/regular-expression-for-matching-latitude-longitude-coordinates
validate_coords = function(coords) {
    str_detect(coords, paste0('^[-+]?([1-8]?\\d(\\.\\d+)?|90(\\.0+)?)\\s*,\\s*[-+]?(180(\\.0+)?|((1[0-7]\\d)',
                              '|([1-9]?\\d))(\\.\\d+)?)$'))
}
