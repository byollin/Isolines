shinyServer(function(input, output, session) {
    
    results  = reactiveValues(data = list())
    progress = reactiveValues(status = NULL)
    
    # display lat/lng on map load
    js_code = 'function(el, x) {
                    this.addEventListener("mousemove", function(e) {
                        document.getElementById("coords").innerHTML = e.latlng.lat.toFixed(6) + ", " + e.latlng.lng.toFixed(6);
                    })
                }'
    
    toggleDropdownButton('help')
    
    shinyjs::show('spinner')
    
    output$map = renderLeaflet({
        leaflet::leaflet(options = leafletOptions(minZoom = 4, maxZoom = 18, zoomControl = FALSE)) %>%
            addTiles(urlTemplate = paste0('https://api.mapbox.com/styles/v1/mapbox/light-v9/tiles/256/{z}/{x}/{y}@2x?',
                                          'access_token=pk.eyJ1IjoiYnlvbGxpbiIsImEiOiJjanNleDR0enAxOXZ5NDRvYXMzYWFzejA',
                                          '2In0.GGB4yI6z0leM1_BwGEYfiQ'),
                     attribution = '<a href="https://www.mapbox.com/about/maps/" title="Mapbox" target="_blank">Mapbox ©</a> | \
                                    Map data provided by <a href="https://www.openstreetmap.org/copyright" \
                                    title="OpenStreetMap Contributors" target="_blank">OpenStreetMap © Contributors</a>') %>%
            setView(lng = -122.33372926712038, lat = 47.61308516731669, zoom = 12) %>% onRender(js_code)
    })
    
    delay(ms = 200, {
        shinyjs::hide('spinner')
    })
    
    observeEvent(input$map_click, {
        lat = round(input$map_click$lat, 6)
        lng = round(input$map_click$lng, 6)
        updateTextInput(session, 'origin', value = paste0(lat, ', ', lng))
    })
    
    observeEvent(input$origin, ignoreInit = TRUE, {
        if(validate_coords(input$origin)) {
            lat = str_replace(input$origin, ' ', '') %>% str_split(',')
            lat = lat[[1]][1] %>% as.numeric()
            lng = str_replace(input$origin, ' ', '') %>% str_split(',')
            lng = lng[[1]][2] %>% as.numeric()
            leafletProxy('map') %>% addAwesomeMarkers(lng = lng, lat = lat, layerId = 'origin',
                                                      icon = makeAwesomeIcon(icon = 'circle', markerColor = 'black',
                                                                             library = 'fa', iconColor = '#fff'),
                                                      popup = paste0(lat,', ', lng),
                                                      popupOptions = popupOptions(closeButton = FALSE))
        } else {
            leafletProxy('map') %>% removeMarker('origin')
        }
    })

    observeEvent(input$request, {
        
        shinyjs::show('spinner')
        
        progress$status = Progress$new(session)
        progress$status$set(message = 'Validating inputs...')
        Sys.sleep(1)
        
        is_valid = validate_inputs(session, input$origin, input$departure, input$min, input$max, input$step)
        
        if(is_valid) {
            
            progress$status$set(message = 'Requesting...')
            
            departure = strftime(input$departure, '%Y-%m-%d %H:%M:%S')
            range_type = switch(input$range_type, 'Time (minutes)' = 'time', 'Distance (miles)' = 'distance')
            unit       = switch(input$range_type, 'Time (minutes)' = ' minutes', 'Distance (miles)' = ' miles')
            isoline_sequence = if(input$range_type == 'Time (minutes)') {
                seq(input$min, input$max, input$step) * 60
            } else {
                round(seq(input$min, input$max, input$step) * 1609.34, digits = 0)
            }
            isoline_sequence = isoline_sequence %>% sort()
            mode = switch(input$mode, 'Car' = 'car', 'Pedestrian' = 'pedestrian')
            
            layers = sapply(isoline_sequence, function(x) {
                progress$status$inc(amount = 1/length(isoline_sequence))
                isoline(str_remove(input$origin, ' '), departure = departure, range_type = range_type, range = x,
                        mode = mode, app_id = keys$app_id, app_code = keys$app_code)
            })
            
            if(all(sapply(layers, class) == 'SpatialPolygons')) {
                colors = magma(length(layers), end = 0.8) %>% str_trunc(width = 7, side = 'right', ellipsis = '')
                sapply(length(layers):1, function(x) {
                    leafletProxy('map') %>% addPolygons(data = layers[[x]], weight = 2, color = colors[x], opacity = 0.6,
                                                        fillOpacity = 0.3, fillColor = colors[x], smoothFactor = 0,
                                                        highlightOptions = highlightOptions(weight = 3),
                                                        popup = paste0(seq(input$min, input$max, input$step)[x],
                                                                       unit),
                                                        popupOptions = popupOptions(closeButton = FALSE,
                                                                                    closeOnClick = TRUE))
                })
                leafletProxy('map') %>% addLegend('bottomright', pal = colorNumeric(colors, domain = 1:2),
                                                  values = 1:2, title = tools::toTitleCase(unit), opacity = 1,
                                                  layerId = 'legend', group = 'legend',
                                                  labFormat = function(type, cuts, p) {
                                                      n = length(cuts)
                                                      cuts[n] = 'Longer'
                                                      for(i in 2:(n - 1)) {
                                                          cuts[i] = ""
                                                      }
                                                      cuts[1] = 'Shorter'
                                                      paste0(cuts[-n], cuts[-1])
                                                  }
                                        )
                results$data[[length(results$data) + 1]] = layers
                shinyjs::show('clear_panel')
            } else {
                request_error = layers[sapply(layers, class) != 'SpatialPolygons'] %>% unlist() %>% unique()
                error_message(session, tags$span('Isoline API failed with the following error: ', request_error))
            }
            
        } else {
            progress$status$set(message = 'Invalid input parameters!')
            Sys.sleep(1)
        }
        delay(ms = 200, {
            shinyjs::hide('spinner')
        })
        progress$status$close()
    })
    
    observeEvent(input$clear_map, {
        results$data = list()
        updateTextInput(session, 'origin', value = '')
        leafletProxy('map') %>% clearShapes() %>% clearControls()
        shinyjs::hide('clear_panel')
    })
    
    # add crosshair cursor to map
    shinyjs::runjs('document.getElementById("map").style.cursor = "crosshair"')
    
})
