# An input group is a plain `div` shell that makes native controls borderless
# and spaces addons around them. Addons carry a `data-align` for logical
# placement; a vertical group uses `header` and `footer` rows.

bc_input_group_aligns <- c(
  "start", "end",
  "inline-start", "inline-end",
  "block-start", "block-end"
)

#' Input Group
#'
#' A group shell for a native control with inline or block addons.
#'
#' @param ... The native control and addon children.
#' @param align String. Addon placement, written to `data-align`. One of
#'   `r toString(bc_input_group_aligns)`.
#' @param orientation String. `default` for inline controls, `vertical` for
#'   `header` and `footer` addon rows.
#' @param aria_label String. Accessible name, added only when the group itself
#'   is named.
#' @param aria_hidden Bool. Whether to mark the addon `aria-hidden="true"`.
#' @param class String. Extra classes for the shell.
#' @return A `<div>` tag.
#' @details
#' `header` and `footer` rows need `orientation = "vertical"`.
#' @export
#' @examples
#' bc_input_group(
#'   bc_input(type = "search", placeholder = "Search...", aria_label = "Search"),
#'   bc_input_group_addon(bc_kbd("⌘K"), align = "end")
#' )
#'
#' bc_input_group(
#'   htmltools::tags$textarea(placeholder = "Enter your message"),
#'   htmltools::tags$footer(
#'     `data-align` = "end",
#'     htmltools::span("120 characters left")
#'   ),
#'   orientation = "vertical"
#' )
bc_input_group <- function(...,
                           orientation = "default",
                           aria_label = NULL,
                           class = NULL) {
  orientation <- arg_match(orientation, c("default", "vertical"))
  check_string(aria_label, allow_null = TRUE, allow_empty = FALSE)
  check_string(class, allow_null = TRUE, allow_empty = TRUE)

  bc_tag(div(
    class = paste(c("input-group", class), collapse = " "),
    `data-orientation` = if (orientation != "default") orientation,
    role = if (!is.null(aria_label)) "group",
    `aria-label` = aria_label,
    ...
  ))
}

#' @rdname bc_input_group
#' @export
bc_input_group_addon <- function(..., align = "start", aria_hidden = FALSE) {
  align <- arg_match(align, bc_input_group_aligns)
  check_bool(aria_hidden)

  bc_tag(span(
    `data-align` = align,
    `aria-hidden` = if (aria_hidden) "true",
    ...
  ))
}