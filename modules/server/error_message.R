#' error_message
#' 
#' Sends an error message to the client.
#' 
#' @param session Shiny session
#' @param content content of the error message
#' 
#' @return HTML

error_message = function(session, content) {
    sendSweetAlert(session, title = '', text = tags$span(content), type = 'error', btn_labels = 'OK', html = TRUE)
}