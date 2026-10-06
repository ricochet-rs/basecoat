# An item is a semantic container, an `<article>` or `<a>`, with an optional
# figure, a section of heading and text, and an aside. It is for display
# content, actions, and navigation rows, not form controls.

bc_item_variants <- c("default", "outline", "muted")
bc_item_sizes <- c("default", "sm", "xs")

#' Item
#'
#' Create a row of content with an optional icon, text, and actions.
#'
#' @param ... Tag attributes and extra content, placed after the other parts.
#' @param title String or tag. The title.
#' @param description String or tag. Text under the title.
#' @param media Tag or `NULL`. An icon or image shown before the text.
#' @param actions Tag or `NULL`. A control or indicator shown at the end.
#' @param href String. A link URL. When set, the item is a link.
#' @param variant String. One of `r toString(bc_item_variants)`.
#' @param size String. One of `r toString(bc_item_sizes)`.
#' @param role String. The item's role. Use `"listitem"` inside
#'   [bc_item_group()].
#' @return An htmltools tag.
#' @details
#' Use [bc_field()] for form controls. `bc_item()` is for content and
#' navigation.
#' @export
#' @examples
#' bc_item(
#'   title = "Basic Item",
#'   description = "A simple item with title and description.",
#'   actions = bc_button("Action", variant = "outline", size = "sm"),
#'   variant = "outline"
#' )
#'
#' bc_item(
#'   title = "Visit our documentation",
#'   description = "Get started.",
#'   href = "#"
#' )
#'
#' bc_item_group(
#'   bc_item(title = "Playground", role = "listitem"),
#'   bc_item(title = "Models", role = "listitem")
#' )
bc_item <- function(
  ...,
  title = NULL,
  description = NULL,
  media = NULL,
  actions = NULL,
  href = NULL,
  variant = "default",
  size = "default",
  role = NULL
) {
  variant <- arg_match(variant, bc_item_variants)
  size <- arg_match(size, bc_item_sizes)
  check_string(href, allow_null = TRUE, allow_empty = FALSE)
  check_string(role, allow_null = TRUE, allow_empty = FALSE)

  tag <- if (is.null(href)) tags$article else tags$a

  bc_tag(tag(
    href = href,
    role = role,
    class = "item",
    `data-variant` = if (variant != "default") variant,
    `data-size` = if (size != "default") size,
    if (!is.null(media)) tags$figure(media),
    if (!is.null(title) || !is.null(description)) {
      tags$section(
        if (!is.null(title)) tags$h3(title),
        if (!is.null(description)) tags$p(description)
      )
    },
    if (!is.null(actions)) tags$aside(actions),
    ...
  ))
}

#' @rdname bc_item
#' @param class String. Extra CSS classes for the group.
#' @param aria_label String. Accessible name for the group.
#' @export
bc_item_group <- function(..., class = NULL, aria_label = NULL) {
  check_string(class, allow_null = TRUE, allow_empty = TRUE)
  check_string(aria_label, allow_null = TRUE, allow_empty = FALSE)

  bc_tag(div(
    class = paste(c("item-group", class), collapse = " "),
    role = "list",
    `aria-label` = aria_label,
    ...
  ))
}
