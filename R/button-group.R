# A button group joins related controls, typically buttons, into one shell
# while the child controls keep their own Button styles. Separators divide
# items.

bc_button_group_orientations <- c("default", "vertical")

#' Button Group
#'
#' Joins related controls into a single `button-group` shell.
#'
#' @param ... The group's children: controls and [bc_button_group_separator()].
#' @param orientation String. One of `default` or `vertical`. `default` writes
#'   no attribute.
#' @param aria_label String. Accessible name for the group.
#' @param class String. Extra classes for the shell.
#' @return A `<div>` tag.
#' @details
#' Wrap controls in [bc_button()] or another styled control. A `<span>`,
#' `<label>` or `<output>` child is a non-interactive segment, an `<hr>` is a
#' divider, and a `<div>` is left unstyled for custom layouts.
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
bc_button_group <- function(...,
                            orientation = "default",
                            aria_label = NULL,
                            class = NULL) {
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