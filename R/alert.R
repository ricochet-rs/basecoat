# An alert is structural, like a card: only the root carries a class, and
# Basecoat finds the icon, title, body and action by element name. So the parts
# are written as htmltools tags in order, not passed as arguments.

#' Alert
#'
#' A short message with an optional icon, title, body and action.
#'
#' @param ... Tag attributes and children. Children are a `<svg>` icon, an
#'   `<h2>` title, a `<section>` body and a `<footer>` action, in that order.
#'   Only the title is required.
#' @param variant String. `"destructive"` for an error alert, or `"default"`.
#' @return A `<div>` tag.
#' @details
#' The `<footer>` holds the action element, a button or a link, and Basecoat
#' aligns it to the inline end.
#' @export
#' @examples
#' bc_alert(
#'   htmltools::h2("Account updated"),
#'   htmltools::tags$section("Your changes are live.")
#' )
#'
#' bc_alert(
#'   htmltools::h2("Payment failed"),
#'   htmltools::tags$section("Check your card and try again."),
#'   variant = "destructive"
#' )
bc_alert <- function(..., variant = "default") {
  variant <- arg_match(variant, c("default", "destructive"))

  bc_tag(div(
    class = "alert",
    `data-variant` = if (variant != "default") "destructive",
    ...
  ))
}
