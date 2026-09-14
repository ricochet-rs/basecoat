# An alert is structural, like a card: only the root carries a class, and
# Basecoat finds the icon, title, body and action by element name. The named
# arguments write those elements, and `...` stays open for anything else.

#' Alert
#'
#' A short message with an optional icon, title, body and action.
#'
#' @param ... Tag attributes and any further children, placed after the parts
#'   written by the named arguments.
#' @param title String or tag. The alert's heading, as an `<h2>`.
#' @param description String or tag. The body, as a `<section>`.
#' @param icon Tag or `NULL`. An icon before the title, such as one from the
#'   phosphoricons package.
#' @param action Tag or `NULL`. A button or link, placed in a `<footer>` that
#'   Basecoat aligns to the inline end.
#' @param variant String. `"destructive"` for an error alert, or `"default"`.
#' @return A `<div>` tag.
#' @export
#' @examples
#' bc_alert(title = "Account updated", description = "Your changes are live.")
#'
#' bc_alert(
#'   title = "Payment failed",
#'   description = "Check your card and try again.",
#'   action = bc_button("Retry", variant = "outline", size = "sm"),
#'   variant = "destructive"
#' )
bc_alert <- function(
  ...,
  title = NULL,
  description = NULL,
  icon = NULL,
  action = NULL,
  variant = "default"
) {
  variant <- arg_match(variant, c("default", "destructive"))

  bc_tag(div(
    class = "alert",
    `data-variant` = if (variant != "default") "destructive",
    icon,
    if (!is.null(title)) tags$h2(title),
    if (!is.null(description)) tags$section(description),
    if (!is.null(action)) tags$footer(action),
    ...
  ))
}
