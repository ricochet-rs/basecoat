# Pagination is Tailwind and the Button classes rather than a dedicated
# component: a `nav` landmark lists a previous link, page numbers, an ellipsis,
# and a next link.

#' Pagination
#'
#' Create a row of page links.
#'
#' @param ... For `bc_pagination()`, items from `bc_pagination_item()`,
#'   `bc_pagination_previous()`, `bc_pagination_next()` and
#'   `bc_pagination_ellipsis()`. For `bc_pagination_item()`, extra tag
#'   attributes for the link.
#' @param label String. For `bc_pagination()`, the accessible name, which
#'   defaults to `"pagination"`. For `bc_pagination_previous()` and
#'   `bc_pagination_next()`, the link text.
#' @return An htmltools tag.
#' @export
#' @examples
#' bc_pagination(
#'   bc_pagination_previous(),
#'   bc_pagination_item("1", href = "#"),
#'   bc_pagination_item("2", href = "#", current = TRUE),
#'   bc_pagination_item("3", href = "#"),
#'   bc_pagination_ellipsis(),
#'   bc_pagination_next()
#' )
bc_pagination <- function(..., label = "pagination") {
  check_string(label, allow_empty = FALSE)

  bc_tag(tags$nav(
    role = "navigation",
    `aria-label` = label,
    class = "mx-auto flex w-full justify-center",
    tags$ul(
      class = "flex flex-row items-center gap-1",
      ...
    )
  ))
}

#' @rdname bc_pagination
#' @param item String. The page label.
#' @param href String. The link URL. Defaults to `"#"`.
#' @param current Bool. Whether this is the current page, shown with the
#'   outline style. Defaults to `FALSE`.
#' @export
bc_pagination_item <- function(item, href = "#", current = FALSE, ...) {
  check_string(item, allow_empty = FALSE)
  check_string(href, allow_empty = FALSE)
  check_bool(current)

  bc_tag(tags$li(
    a(
      href = href,
      class = "btn",
      `data-variant` = if (current) "outline" else "ghost",
      `data-size` = "icon",
      item,
      ...
    )
  ))
}

#' @rdname bc_pagination
#' @export
bc_pagination_ellipsis <- function() {
  bc_tag(tags$li(
    div(
      class = "size-9 flex items-center justify-center",
      bc_icon("dots-three", class = "size-4 shrink-0")
    )
  ))
}

#' @rdname bc_pagination
#' @export
bc_pagination_previous <- function(label = "Previous", href = "#") {
  check_string(label, allow_empty = FALSE)
  check_string(href, allow_empty = FALSE)

  bc_tag(tags$li(
    a(
      href = href,
      class = "btn",
      `data-variant` = "ghost",
      bc_icon("caret-left"),
      span(label)
    )
  ))
}

#' @rdname bc_pagination
#' @export
bc_pagination_next <- function(label = "Next", href = "#") {
  check_string(label, allow_empty = FALSE)
  check_string(href, allow_empty = FALSE)

  bc_tag(tags$li(
    a(
      href = href,
      class = "btn",
      `data-variant` = "ghost",
      span(label),
      bc_icon("caret-right")
    )
  ))
}
