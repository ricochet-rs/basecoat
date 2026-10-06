# A button group joins related controls, typically buttons, into one shell
# while the child controls keep their own Button styles. Separators divide
# items.

bc_button_group_orientations <- c("default", "vertical")

#' Button Group
#'
#' Create a group of related buttons joined into one control.
#'
#' @param ... Buttons and other controls, with [bc_button_group_separator()]
#'   between them for a divider.
#' @param orientation String. `"default"` for a row or `"vertical"` for a
#'   column.
#' @param aria_label String. Accessible name for the group.
#' @param class String. Extra CSS classes.
#' @return An htmltools tag.
#' @details
#' Wrap plain text in [htmltools::span()] to show it as a static segment.
#' @export
#' @examples
#' bc_button_group(
#'   bc_button("Archive", variant = "outline"),
#'   bc_button("Report", variant = "outline"),
#'   aria_label = "Message actions"
#' )
#'
#' bc_button_group(
#'   bc_button("Copy", variant = "secondary", size = "sm"),
#'   bc_button_group_separator(),
#'   bc_button("Paste", variant = "secondary", size = "sm")
#' )
bc_button_group <- function(
  ...,
  orientation = "default",
  aria_label = NULL,
  class = NULL
) {
  orientation <- arg_match(orientation, bc_button_group_orientations)
  check_string(aria_label, allow_null = TRUE, allow_empty = FALSE)
  check_string(class, allow_null = TRUE, allow_empty = TRUE)

  bc_tag(div(
    role = "group",
    class = paste(c("button-group", class), collapse = " "),
    `aria-label` = aria_label,
    `data-orientation` = if (orientation != "default") orientation,
    ...
  ))
}

#' @rdname bc_button_group
#' @export
bc_button_group_separator <- function() {
  bc_tag(tags$hr(role = "separator"))
}
