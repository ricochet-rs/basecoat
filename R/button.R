# Basecoat 1.0 dropped the `btn-primary` style classes. A button is `class="btn"`
# plus a `data-variant` and `data-size`, and the primary and default values are
# the absence of the attribute.

bc_button_variants <- c(
  "primary",
  "secondary",
  "outline",
  "ghost",
  "link",
  "destructive"
)

bc_button_sizes <- c(
  "default",
  "xs",
  "sm",
  "lg",
  "icon",
  "icon-xs",
  "icon-sm",
  "icon-lg"
)

#' Button
#'
#' A `<button>` carrying the Basecoat `btn` class.
#'
#' @param ... Tag attributes and children for the `<button>`. The label is a
#'   child.
#' @param variant String. One of `r toString(bc_button_variants)`. `primary`
#'   writes no attribute.
#' @param size String. One of `r toString(bc_button_sizes)`. `default` writes no
#'   attribute.
#' @param type String. The `type` attribute, `"button"` unless the button
#'   submits a form.
#' @param aria_label String. Accessible name, needed when the button has no
#'   visible text such as an icon-only button.
#' @return A `<button>` tag.
#' @details
#' An icon beside text takes `data-icon = "inline-start"` or `"inline-end"`.
#' @export
#' @examples
#' bc_button("Save")
#'
#' bc_button("Delete", variant = "destructive")
#'
#' bc_button("Snooze", variant = "outline", size = "sm")
bc_button <- function(...,
                      variant = "primary",
                      size = "default",
                      type = "button",
                      aria_label = NULL) {
  variant <- arg_match(variant, bc_button_variants)
  size <- arg_match(size, bc_button_sizes)
  check_string(type, allow_empty = FALSE)
  check_string(aria_label, allow_null = TRUE, allow_empty = FALSE)

  bc_tag(tags$button(
    type = type,
    class = "btn",
    `data-variant` = if (variant != "primary") variant,
    `data-size` = if (size != "default") size,
    `aria-label` = aria_label,
    ...
  ))
}
