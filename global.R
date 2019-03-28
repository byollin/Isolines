suppressWarnings(suppressMessages({
    library(shiny)
    library(shinyBS)
    library(shinycssloaders)
    library(shinyWidgets)
    library(shinythemes)
    library(shinyjs)
    library(htmlwidgets)
    library(leaflet)
    library(rgdal)
    library(lutz)
    library(smoothr)
    library(viridis)
    library(dplyr)
    library(lubridate)
    library(stringr)
    library(RCurl)
    library(xml2)
    library(jsonlite)
}))

# ui modules
source('modules/ui/inline_block_css.R')
source('modules/ui/input_ui.R')
source('modules/ui/popup_boxes.R')
source('modules/ui/sidebar_panel.R')

# server modules
source('modules/server/error_message.R')
source('modules/server/isoline.R')
source('modules/server/validate_coords.R')
source('modules/server/validate_inputs.R')

# read api keys
keys = if(file.exists('api_keys.json')) {
    fromJSON('api_keys.json')   
} else {
    list('app_id' = NULL, 'app_code' = NULL)
}
