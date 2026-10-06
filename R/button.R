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
#' Create a button.
#'
#' @param ... Tag attributes and content, such as the label.
#' @param variant String. One of `r toString(bc_button_variants)`.
#' @param size String. One of `r toString(bc_button_sizes)`.
#' @param type String. The button type. Defaults to `"button"`. Use
#'   `"submit"` for a button that submits a form.
#' @param aria_label String. Accessible name for the button. Set it when the
#'   button has no visible text, such as an icon-only button.
#' @return An htmltools tag.
#' @details
#' To place an icon beside the label, give the icon
#' `data-icon = "inline-start"` or `"inline-end"`.
#' @export
#' @examples
#' bc_button("Save")
#'
#' bc_button("Delete", variant = "destructive")
#'
#' bc_button("Snooze", variant = "outline", size = "sm")
bc_button <- function(
  ...,
  variant = "primary",
  size = "default",
  type = "button",
  aria_label = NULL
) {
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
