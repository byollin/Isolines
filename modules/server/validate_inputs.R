#' validate_inputs
#' 
#' Validate inputs before sending requests to the Isolines API and alert the client of invalid input parameters.
#' 
#' @param session Shiny session
#' @param origin origin coordinates
#' @param departure departure date/time
#' @param min minimum range
#' @param max maximum range
#' @param step step size in sequence
#' 
#' @return TRUE or FALSE

validate_inputs = function(session, origin, departure, min, max, step) {
    is_valid = FALSE
    if(!all(is.null(keys$app_id) & is.null(keys$app_code))) {
        if(validate_coords(origin)) {
            if(!is.null(departure)) {
                isoline_sequence = try(seq(seq(min, max, step)), silent = TRUE)
                if(!'try-error' %in% class(isoline_sequence)) {
                    if(all(isoline_sequence >= 0)) {
                        if(length(isoline_sequence) <= 20) {
                            is_valid = TRUE
                        } else {
                            error_message(session, 'Isoline requests exceeds maximum allowed (20). Reduce the number \
                                                   of requests by adujusting minimum range, maximum range or step \
                                                   size.')
                        }
                    } else {
                        error_message(session, 'Isoline range must be a positive number.')
                    }
                } else {
                    error_message(session, 'Invalid range provided. Adjust minimum range, maximum range or step size.')
                }
            } else {
                error_message(session, 'Provide a departure time.')
            }
        } else {
            error_message(session, tags$span('Invalid origin coordinates. Provide coordinates in the following \
                                             format: ', tags$code('latitude, longitude'), '.'))
        }
    } else {
        error_message(session, tags$span('An API key was not provided. To get your free API key visit: ',
                                         tags$a('https://developer.here.com/develop/rest-apis',
                                                href = 'https://developer.here.com/develop/rest-apis',
                                                target = '_blank'),tags$span('.')))
    }
    return(is_valid)
}
