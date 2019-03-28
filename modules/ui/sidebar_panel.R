#' sidebar_panel
#' 
#' Sidebar panel for Shiny application.
#' 
#' @return HTML

sidebar_panel = function() {
    wellPanel(id = 'controls',
        # origin #######################################################################################################
        input_ui(input_id = 'origin',
                 input_element = textInput('origin', label = 'Origin:',
                                           placeholder = 'Origin (e.g., 47.5887, -122.2327)', width = '100%'),
                 help = paste0('Center of the isoline request. Isoline will cover all roads which can be reached from ',
                               'this point within given range. Click on the map to select an origin or type a ',
                               'latitude/longitude separated by a comma.')),
        # departure date ###############################################################################################
        input_ui(input_id = 'departure',
                 input_element = airDatepickerInput('departure', label = 'Departure date:', width = '100%',
                                                    value = Sys.Date()),
                 help = paste0('Time when travel is expected to start. Traffic speed and incidents are taken into ',
                               'account when calculating the route. Departure time can be past, present or future.')),
        # departure time ###############################################################################################
        input_ui(input_id = 'time',
                 input_element = sliderInput('time', 'Time range: ', min = 0, max = 23, post = ':00', step = 1,
                                             value = 17),
                 help = paste0('Time when travel is expected to start. Traffic speed and incidents are taken into ',
                               'account when calculating the route. Departure time can be past, present or future.')),
        # mode #########################################################################################################
        input_ui(input_id = 'mode',
                 # TODO: fix car and pedestiran icons
                 input_element = radioGroupButtons('mode', label = 'Mode:',
                                                   choices = c(`<img src="car.png", height = 14px>` = 'Car',
                                                               `<img src="ped.png", height = 16px, style = "margin-top: -2px;">` = 'Pedestrian'),
                                                   selected = 'Car', justified = TRUE),
                 help = paste0('This option controls the mode type. Possible values are car (driving) or pedestrian ',
                               '(walking).')),
        # range type ###################################################################################################
        input_ui(input_id = 'range_type',
                 input_element = radioGroupButtons('range_type', label = 'Range type:',
                                                   choices = c('Time (minutes)', 'Distance (miles)'),
                                                   selected = 'Time (minutes)', justified = TRUE),
                 help = paste0('Specifies type of range. Possible values are distance or time. For distance the unit ',
                               'is miles. For time the unit is minutes.')),
        # range ########################################################################################################
        div(style = inline_block_css(),
            column(5, style = 'padding-left: 0',
                numericInput('min', label = 'Minimum range:', min = 1, step = 1, value = 5)
            ),
            column(5, style = 'padding-left: 0; margin-left: 12px;',
                numericInput('max', label = 'Maximum range:', min = 1, step = 1, value = 30)
            ),
            column(1, style = 'margin-top: 4px; margin-left: 12px;',
                br(),
                actionButton('range_help', NULL, icon = icon('question', lib = 'font-awesome')),
                bsPopover('range_help', placement = 'right', trigger = 'focus', title = NULL,
                          content = 'Range of isoline. For distance the unit is miles. For time the unit is minutes.')
            )
        ),
        # step #########################################################################################################
        input_ui(input_id = 'step',
                 input_element = numericInput('step', label = 'Gap size:', min = 1, step = 1, value = 5),
                 help = paste0('Gap size between each isoline. For distance the unit is miles. For time the unit is ',
                               'minutes.')),
        actionButton('request', label = 'Request isolines', width = '100%'),
        downloadButton('download', label = 'Download results', class = list(width = '100%')) %>% hidden()
    )
}
