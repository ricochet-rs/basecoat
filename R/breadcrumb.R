# A breadcrumb is a `nav` landmark with an ordered list of the page hierarchy.
# Separators sit between items in hidden `<li>` elements, and the current page
# is marked with `aria-current="page"`.

#' Breadcrumb
#'
#' A navigation landmark listing the page hierarchy, with separators inserted
#' between items.
#'
#' @param ... Items from [bc_breadcrumb_item()] and [bc_breadcrumb_separator()].
#'   Separators are added between items automatically.
#' @param label String. The landmark's `aria-label`.
#' @param separator String. Separator icon: `chevron-right` (default) or `dot`.
#' @return A `<nav>` tag.
#' @export
#' @examples
#' bc_breadcrumb(
#'   bc_breadcrumb_item("Home", href = "#"),
#'   bc_breadcrumb_item("Components", href = "#"),
#'   bc_breadcrumb_item("Breadcrumb", current = TRUE)
#' )
#'
#' bc_breadcrumb(
#'   bc_breadcrumb_item("Docs", href = "#"),
#'   bc_breadcrumb_item("Theming", current = TRUE),
#'   separator = "dot"
#' )
#'
#' bc_breadcrumb_separator("dot")
bc_breadcrumb <- function(..., label = "Breadcrumb", separator = "chevron-right") {
  separator <- arg_match(separator, c("chevron-right", "dot"))
  check_string(label, allow_empty = FALSE)

  items <- list(...)
  if (length(items) > 1) {
    items <- c(
      unlist(lapply(seq_len(length(items) - 1), function(i) {
        list(items[[i]], bc_breadcrumb_separator(separator))
      }), recursive = FALSE),
      items[length(items)]
    )
  }

  bc_tag(tags$nav(
    class = "breadcrumb",
    `aria-label` = label,
    tags$ol(items)
  ))
}

#' @rdname bc_breadcrumb
#' @param item String. The item's label.
#' @param href String. Link target.
#' @param current Bool. Whether this is the current page. Renders a span with
#'   `aria-current="page"` instead of a link.
#' @export
bc_breadcrumb_item <- function(item, href = NULL, current = FALSE) {
  check_string(item, allow_empty = FALSE)
  check_string(href, allow_null = TRUE, allow_empty = FALSE)
  check_bool(current)

  if (current) {
    return(bc_tag(tags$li(span(`aria-current` = "page", item))))
  }

  bc_tag(tags$li(a(href = href, item)))
}

#' @rdname bc_breadcrumb
#' @param icon String. The separator icon: `chevron-right` or `dot`.
#' @export
bc_breadcrumb_separator <- function(icon = "chevron-right") {
  icon <- arg_match(icon, c("chevron-right", "dot"))

  bc_tag(tags$li(
    `aria-hidden` = "true",
    breadcrumb_icon(icon)
  ))
}

breadcrumb_icon <- function(icon) {
  if (icon == "dot") {
    return(bc_icon("dot"))
  }

  # data-rtl-flip is what turns the chevron around under dir="rtl".
  HTML(sub(
    "<svg ", '<svg data-rtl-flip ',
    as.character(bc_icon("caret-right")),
    fixed = TRUE
  ))
}