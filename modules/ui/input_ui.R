#' input_ui
#' 
#' UI wrapper for input elements.
#' 
#' @param input_id Shiny input id of the input element
#' @param input_element input element
#' @param help text to display in help popup
#' 
#' @return HTML

input_ui = function(input_id, input_element, help) {
    div(style = inline_block_css(),
        column(11, style = 'padding-left: 0',
            input_element
        ),
        column(1, style = 'margin-top: 4px; margin-left: -14px;',
               br(),
               actionButton(paste0(input_id, '_help'), NULL, icon = icon('question', lib = 'font-awesome')),
               bsPopover(paste0(input_id, '_help'), placement = 'right', trigger = 'focus', title = NULL,
                         content = help)
        )
    )
}