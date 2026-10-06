# A label is `class="label"` on a native `<label>`. It can name another
# control through `for`, or wrap a small control directly.

#' Label
#'
#' Create a label for a form control.
#'
#' @param ... Tag attributes and content. Set `` `for` `` to the ID of the
#'   control the label names.
#' @return An htmltools tag.
#' @details
#' [bc_checkbox()] and [bc_switch()] already include a label.
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
