isoline = function(origin, departure, range_type, range, mode, tz = 'America/Los_Angeles', app_id = '', app_code = '') {
    
    format_time = function(x) {
        x %>% strftime(format = '%Y-%m-%dT%H:%M:%S%z') %>% str_replace('.{2}$', '')
    }
    
    formatted_mode      = paste0('fastest;', mode, ';traffic:enabled')
    formatted_departure = format_time(ymd_hms(departure, tz = tz))
    
    url = paste0('https://isoline.route.api.here.com/routing/7.2/calculateisoline.xml?',
                 '&app_id=', app_id,
                 '&app_code=', app_code,
                 '&start=geo!', origin,
                 '&departure=', formatted_departure,
                 '&rangeType=', range_type,
                 '&range=', range,
                 '&mode=', formatted_mode,
                 '&resolution=', 1)
    
    xml_response = read_xml(getURL(url, .mapUnicode = F))
    if('subtype' %in% names(xml_attrs(xml_response))) {
        error_node = xml_attrs(xml_response)[['subtype']] 
    } else {
        error_node = NULL
    }
    
    if (!is.null(error_node)) {
        data = error_node
    } else {
        component = xml_response %>% xml_find_all("//Component//Shape") %>% xml_text()
        poly = sapply(1:length(component), function(x) {
            coords = str_split(component[x], ' ') %>% unlist()
            lat    = sapply(coords, function(x) { str_split(x, ',')[[1]][1] }) %>% as.numeric()
            lng    = sapply(coords, function(x) { str_split(x, ',')[[1]][2] }) %>% as.numeric()
            list(Polygon(as.matrix(data.frame(lng, lat)))) %>% Polygons(ID = x)
        })
        data = SpatialPolygons(poly, proj = CRS('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')) %>% 
            smooth(method = 'ksmooth', smoothness = 3)
    }
    
    return(data)
    
}
