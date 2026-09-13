# Kbd is the singleton root class on a `<kbd>`: the key label is the child, and
# everything else is an attribute in `...`. Grouping keys is a wrapper's job, and
# a page usually does that with a flex layout, either Tailwind's `inline-flex`
# utilities or inline styles. Keyboard labels are direction-neutral.

#' Keyboard Key
#'
#' A single key label in an inline `<kbd>`.
#'
#' @param label String. Text on the key, such as `"⌘K"`.
#' @param ... Tag attributes for the `<kbd>`.
#' @return A `<kbd>` tag.
#' @details
#' Group keys in a flex wrapper with a gap between them. Give a shortcut beside
#' button text `data-icon = "inline-end"` for spacing.
#' @export
#' @examples
#' bc_kbd("⌘K")
#'
#' bc_kbd("⏎", `data-icon` = "inline-end")
bc_kbd <- function(label, ...) {
  check_string(label, allow_empty = FALSE)
  bc_tag(tags$kbd(class = "kbd", ..., label))
}