tagList(useShinyjs(), navbarPage(theme = shinytheme('yeti'), title = div(id = 'isolines', 'Isolines'), id = 'navbar',
                                 windowTitle = 'Isolines',
tabPanel(title = ' ',
    # map panel ########################################################################################################
    div(class = 'outer',
        # additional css
        tags$head(tags$link(rel = 'stylesheet', type = 'text/css', href = 'styles.css')),
        tags$head(tags$link(rel = 'stylesheet', type = 'text/css', href = 'ion.rangeSlider.skinSquare.css')),
        # coordinate panel
        absolutePanel(id = 'coord_panel', top = 30, right = 8, width = 'auto',
            pre(id = 'coords', '47.613085, -122.333729')),
        # clear map button (start hidden)
        absolutePanel(id = 'clear_panel', top = 30, left = 510, width = 'auto',
            actionButton('clear_map', label = 'Clear map', width = '100%')) %>% hidden(),
        # app help and information
        popup_boxes(),
        # map
        leafletOutput('map', width = '100%', height = '100%'),
        # spinner
        div(id = 'spinner',
            div() %>% withSpinner(type = 8, proxy.height = '400px', color = '#333d47')
        )
    ),
    # sidebar panel ####################################################################################################
    fixedPanel(top = 0, left = 0, width = 500, height = '100%',
        sidebar_panel()
    )
)))
