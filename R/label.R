# A label is `class="label"` on a native `<label>`. It can name another
# control through `for`, or wrap a small control directly.

#' Label
#'
#' A `<label>` carrying the Basecoat `label` class.
#'
#' @param ... Content and attributes. A backticked `for` attribute names
#'   another control.
#' @return A `<label>` tag.
#' @details
#' [bc_checkbox()] and [bc_switch()] write this pairing already.
#' @seealso [bc_checkbox()], [bc_switch()], [bc_field()]
#' @export
#' @examples
#' bc_label("Your email address", `for` = "email")
#'
#' bc_label(
#'   htmltools::tags$input(type = "checkbox", class = "input"),
#'   "Accept terms and conditions"
#' )
bc_label <- function(...) {
  bc_tag(tags$label(class = "label", ...))
}
