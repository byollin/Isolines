suppressWarnings(suppressMessages({
    library(shiny)
    library(shinyBS)
    library(shinycssloaders)
    library(shinyWidgets)
    library(shinythemes)
    library(shinyjs)
    library(htmlwidgets)
    library(rgdal)
    library(lutz)
    library(smoothr)
    library(leaflet)
    library(viridis)
    library(dplyr)
    library(lubridate)
    library(stringr)
    library(RCurl)
    library(xml2)
    library(jsonlite)
}))

source('isoline.R')

keys = if(file.exists('api_keys.json')) {
    fromJSON('api_keys.json')   
} else {
    list('app_id' = NULL, 'app_code' = NULL)
}

# https://stackoverflow.com/questions/3518504/regular-expression-for-matching-latitude-longitude-coordinates
validate_coords = function(coords) {
    str_detect(coords, paste0('^[-+]?([1-8]?\\d(\\.\\d+)?|90(\\.0+)?)\\s*,\\s*[-+]?(180(\\.0+)?|((1[0-7]\\d)',
                              '|([1-9]?\\d))(\\.\\d+)?)$'))
}

error_message = function(session, content) {
    sendSweetAlert(session, title = '', text = tags$span(content), type = 'error', btn_labels = 'OK', html = TRUE)
}

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
                             href = 'https://developer.here.com/develop/rest-apis', target = '_blank'), tags$span('.')))
    }
    return(is_valid)
}
