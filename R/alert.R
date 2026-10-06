# An alert is structural, like a card: only the root has a class, and
# Basecoat finds the icon, title, body, and action by element name. The named
# arguments write those elements, and `...` stays open for anything else.

#' Alert
#'
#' Create a short message with an optional icon, title, body, and action.
#'
#' @param ... Tag attributes and extra content, placed after the other parts.
#' @param title String or tag. The title.
#' @param description String or tag. The body text.
#' @param icon Tag or `NULL`. An icon before the title, such as one from the
#'   phosphoricons package.
#' @param action Tag or `NULL`. A button or link, aligned to the end of the
#'   alert.
#' @param variant String. `"default"` or `"destructive"` for an error alert.
#' @return An htmltools tag.
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
