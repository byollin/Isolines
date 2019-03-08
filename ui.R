inline_block_css = 'display: inline-block; vertical-align: bottom; min-width: 100%;'

tagList(useShinyjs(), navbarPage(theme = shinytheme('yeti'), title = div(id = 'isolines', 'Isolines'), id = 'navbar',
                                 windowTitle = 'Isolines',
                   
tabPanel(title = ' ',
    
    # map ##############################################################################################################
    div(class = 'outer',
        tags$head(tags$link(rel = 'stylesheet', type = 'text/css', href = 'styles.css')),
        absolutePanel(id = 'coord_panel', top = 30, right = 8, width = 'auto',
                      pre(id = 'coords', '47.613085, -122.333729')),
        absolutePanel(id = 'clear_panel', top = 30, left = 510, width = 'auto',
                      actionButton('clear_map', label = 'Clear map', width = '100%')) %>% hidden(),
        absolutePanel(id = 'clear_panel', bottom = 6, left = 510,
            dropdownButton(icon = icon('question'), size = 'sm', up = TRUE, width = '700px', inputId = 'help',
                h2('Map isolines for anywhere in the world!'),
                hr(),
                div(style = 'display: inline-block; vertical-align: bottom; min-width: 100%;',
                    column(6, style = 'padding-left: 0',
                        h4('What is an isoline?', style = 'margin-top: 0;'),
                        p('The prefix "iso", draws its meaning from Ancient Greek meaning "same" or "equal". Each line \
                          on an isoline map shares the same value. An isochrone is a special type of isoline that \
                          visualizes travel time. This application shows lines of equal travel time or equal network \
                          distance for mode choices of driving or walking. Click anywhere on the map and see \
                          isochrones!', style = 'font-size: 14px;')
                               ),
                   column(6,
                        img(src = 'example.png', style = 'height: 250px; display: block; margin-bottom: 20px; \
                            margin-right: auto; margin-left: auto;')
                   )
                )               
            )
        ),
        absolutePanel(id = 'clear_panel', bottom = 6, left = 560,
            dropdownButton(icon = icon('info'), size = 'sm', up = TRUE, width = '700px',
                h2('About this application'),
                hr(),
                div(style = 'display: inline-block; vertical-align: bottom; min-width: 100%;',
                    column(6, style = 'padding-left: 0',
                        h4('Data source', style = 'margin-top: 0;'),
                        tags$span('This application sends requests to the ',
                                  tags$a('HERE Isolines API.', href = paste0('https://developer.here.com/',
                                                                             'documentation/routing/topics/resource-',
                                                                             'calculate-isoline.html'),
                                         target = '_blank'), 'Responses are then post-processed before displaying \
                                                             on the map.', style = 'font-size: 14px;'),
                        h4('Application author', style = 'margin-top: 10px;'),
                        tags$span('Hi, I\'m ', tags$a('Bethany Yollin!',
                                                      href = 'https://www.linkedin.com/in/bethanyyollin/',
                                                      target = '_blank'), 'I am a data scientist working in the \
                                                                          transportation industry. With a background \
                                                                          in geography and applied mathematics, I \
                                                                          enjoy developing fun and informative \
                                                                          interactive web mapping applications.',
                                  style = 'font-size: 14px;')
                    ),
                    column(6,
                        img(src = 'here.png', style = 'height: 250px; display: block; margin-bottom: 20px; \
                            margin-right: auto; margin-left: auto;')
                    )
                )
            )
        ),
        leafletOutput('map', width = '100%', height = '100%'),
        hidden(div(id = 'spinner',
            div() %>% withSpinner(type = 8, proxy.height = '400px', color = '#333d47')
        ))
    ),
    # sidebar ##########################################################################################################
    fixedPanel(top = 0, left = 0, width = 500, height = '100%',
        wellPanel(id = 'controls',
            # > origin #########################################################################################
            div(style = inline_block_css,
                column(11, style = 'padding-left: 0',
                    textInput('origin', label = 'Origin:', placeholder = 'Origin (e.g., 47.5887, -122.2327)',
                              width = '100%')
                ),
                column(1, style = 'margin-top: 4px; margin-left: -14px;',
                    br(),
                    actionButton('origin_help', NULL, icon = icon('question', lib = 'font-awesome')),
                    bsPopover('origin_help', placement = 'right', trigger = 'focus', title = NULL,
                              content = paste0('Center of the isoline request. Isoline will cover all roads ',
                              'which can be reached from this point within given range. Click on the map to ',
                              'select an origin or type a latitude/longitude separated by a comma.'))
                )
            ),
            # > departure time #################################################################################
            div(style = inline_block_css,
                column(11, style = 'padding-left: 0',
                       airDatepickerInput('departure', label = 'Departure time:', timepicker = TRUE,
                                          timepickerOpts = timepickerOptions(minutesStep = 5,
                                                                             timeFormat = 'hh:ii AA'),
                                          width = '100%', value = Sys.Date())
                ),
                column(1, style = 'margin-top: 4px; margin-left: -14px;',
                       br(),
                       actionButton('departure_help', NULL, icon = icon('question', lib = 'font-awesome')),
                       bsPopover('departure_help', placement = 'right', trigger = 'focus', title = NULL,
                                 content = paste0('Time when travel is expected to start. Traffic speed and ',
                                 'incidents are taken into account when calculating the route. Departure time ',
                                 'can be past, present or future.'))
                )
            ),
            # > mode ###########################################################################################
            div(style = inline_block_css,
                column(11, style = 'padding-left: 0',
                       radioGroupButtons('mode', label = 'Mode:',
                                         choices = c(`<img src='car.png', height = 14px>` = 'Car',
                                                     `<img src='ped.png', height = 16px, style = 'margin-top: -2px;'>` = 'Pedestrian'),
                                         selected = 'Car', justified = TRUE)
                ),
                column(1, style = 'margin-top: 8px; margin-left: -14px;',
                       br(),
                       actionButton('mode_help', NULL, icon = icon('question', lib = 'font-awesome')),
                       bsPopover('mode_help', placement = 'right', trigger = 'focus', title = NULL,
                                 content = paste0('This option controls the mode type. Possible values are ',
                                                  'car (driving) or pedestrian (walking).'))
                )
            ),
            # > range type #####################################################################################
            div(style = inline_block_css,
                column(11, style = 'padding-left: 0',
                       radioGroupButtons('range_type', label = 'Range type:',
                                         choices = c('Time (minutes)', 'Distance (miles)'),
                                         selected = 'Time (minutes)', justified = TRUE)
                ),
                column(1, style = 'margin-top: 8px; margin-left: -14px;',
                    br(),
                    actionButton('range_type_help', NULL, icon = icon('question', lib = 'font-awesome')),
                    bsPopover('range_type_help', placement = 'right', trigger = 'focus', title = NULL,
                              content = paste0('Specifies type of range. Possible values are distance or ',
                              'time. For distance the unit is miles. For time the unit is minutes.'))
                )
            ),
            # > range ##########################################################################################
            div(style = inline_block_css,
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
            # > step ###########################################################################################
            div(style = inline_block_css,
                column(11, style = 'padding-left: 0',
                    numericInput('step', label = 'Step size:', min = 1, step = 1, value = 5)
                ),
                column(1, style = 'margin-top: 4px; margin-left: -14px;',
                       br(),
                       actionButton('step_help', NULL, icon = icon('question', lib = 'font-awesome')),
                       bsPopover('step_help', placement = 'right', trigger = 'focus', title = NULL,
                                 content = 'Difference between each isoline.')
                )
            ),
            actionButton('request', label = 'Request isolines', width = '100%')
        ))

)))
