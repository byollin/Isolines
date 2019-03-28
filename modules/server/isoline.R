#' isoline
#' 
#' Sends an isoline request to the HERE Isolines API.
#' See https://developer.here.com/documentation/routing/topics/resource-calculate-isoline.html. The response is 
#' post-processed with a smoothing algorithm.
#' 
#' @param origin origin coordinates
#' @param departure departure time
#' @param range_type range type, either time or distance
#' @param range range, for `range_type` distance provide units in meters, for `range_type` time provide units in seconds
#' @param mode transportation mode, either car or pedestrian
#' @param app_id app_id provided by HERE
#' @param app_code app_code provided by HERE
#' 
#' @return SpatialPolygonsDataFrame

isoline = function(origin, departure, range_type, range, mode, app_id = '', app_code = '') {
    format_time = function(x, origin) {
        tz = tz_lookup_coords(str_split(origin, ',', simplify = TRUE)[1] %>% as.numeric(),
                              str_split(origin, ',', simplify = TRUE)[2] %>% as.numeric(), warn = FALSE)
        ymd_hms(x, tz = tz) %>% format('%Y-%m-%dT%H:%M:%S', tz = tz)
    }
    formatted_mode = paste0('fastest;', mode, ';traffic:enabled')
    formatted_departure = format_time(departure, origin)
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
        if(length(component) == 0) {
            data = 'Unknown error occured. Please try again.'
        } else {
            poly = sapply(1:length(component), function(x) {
                coords = str_split(component[x], ' ') %>% unlist()
                lat = sapply(coords, function(x) { str_split(x, ',')[[1]][1] }) %>% as.numeric()
                lng = sapply(coords, function(x) { str_split(x, ',')[[1]][2] }) %>% as.numeric()
                list(Polygon(as.matrix(data.frame(lng, lat)))) %>% Polygons(ID = x)
            })
            df = data.frame('origin' = rep(origin, length(data)), 'departure' = rep(departure, length(data)),
                            'range_type' = rep(range_type, length(data)), 'range' = rep(range, length(data)))
            data = SpatialPolygons(poly, proj = CRS('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')) %>%
                   smooth(method = 'ksmooth', smoothness = 3)
            data = SpatialPolygonsDataFrame(data, data = df, match.ID = FALSE)   
        }
    }
    return(data)
}
