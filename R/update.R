#' Update Shiny Inputs
#'
#' Change the value of a basecoat input from the server of a Shiny app.
#' The page needs [bc_shiny_deps()] for these to have any effect.
#'
#' @param id String. The ID of the input to update.
#' @param value The new value. A string for [bc_radio_group()], a number for
#'   [bc_slider()], and a character vector for [bc_select()] and
#'   [bc_combobox()].
#' @param open Character vector. The IDs, or titles, of the items to open.
#'   Every other item is closed. Use `character(0)` to close them all.
#' @param session The Shiny session. Defaults to the current session.
#' @return `NULL`, invisibly.
#' @export
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'
#'   ui <- bc_page_sidebar(
#'     bc_shiny_deps(),
#'     sidebar = bc_sidebar(id = "sidebar"),
#'     bc_switch("annual", "Pay annually"),
#'     bc_radio_group(
#'       name = "plan",
#'       bc_radio("monthly", "Monthly", checked = TRUE),
#'       bc_radio("yearly", "Yearly")
#'     )
#'   )
#'
#'   server <- function(input, output, session) {
#'     observeEvent(input$annual, {
#'       bc_update_radio_group("plan", if (input$annual) "yearly" else "monthly")
#'     })
#'   }
#'
#'   shinyApp(ui, server)
#' }
bc_update_radio_group <- function(
  id,
  value,
  session = shiny::getDefaultReactiveDomain()
) {
  check_string(value)
  bc_send_input_message(id, list(value = value), session)
}

#' @rdname bc_update_radio_group
#' @export
bc_update_slider <- function(
  id,
  value,
  session = shiny::getDefaultReactiveDomain()
) {
  check_number_decimal(value)
  bc_send_input_message(id, list(value = value), session)
}

#' @rdname bc_update_radio_group
#' @export
bc_update_select <- function(
  id,
  value,
  session = shiny::getDefaultReactiveDomain()
) {
  check_character(value)
  bc_send_input_message(id, list(value = value), session)
}

#' @rdname bc_update_radio_group
#' @export
bc_update_combobox <- function(
  id,
  value,
  session = shiny::getDefaultReactiveDomain()
) {
  check_character(value)
  bc_send_input_message(id, list(value = value), session)
}

#' @rdname bc_update_radio_group
#' @export
bc_update_accordion <- function(
  id,
  open,
  session = shiny::getDefaultReactiveDomain()
) {
  check_character(open)
  bc_send_input_message(id, list(open = open), session)
}

#' @rdname bc_update_radio_group
#' @param mode String. `"light"` or `"dark"`.
#' @export
bc_update_theme_switcher <- function(
  id,
  mode,
  session = shiny::getDefaultReactiveDomain()
) {
  mode <- arg_match(mode, c("light", "dark"))
  bc_send_input_message(id, list(value = mode), session)
}

bc_send_input_message <- function(id, message, session) {
  check_string(id, allow_empty = FALSE)

  if (is.null(session)) {
    cli::cli_abort("Call this from inside a Shiny {.arg session}.")
  }

  session$sendInputMessage(id, message)
  invisible(NULL)
}
