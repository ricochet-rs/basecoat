# Pagination is Tailwind and the Button classes rather than a dedicated
# component: a `nav` landmark lists a previous link, page numbers, an ellipsis,
# and a next link.

#' Pagination
#'
#' A set of page controls built from the Button classes in a `nav` landmark.
#'
#' @param ... The pagination items as `<li>` tags, from the item helpers.
#' @param label String. The navigation landmark's `aria-label`.
#' @return A `<nav>` tag.
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
#' @param href String. The link target.
#' @param current Bool. Whether this is the current page. Renders as the
#'   outline variant.
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
      HTML(pagination_lucide("ellipsis"))
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
      HTML(pagination_lucide("chevron-left")),
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
      HTML(pagination_lucide("chevron-right"))
    )
  ))
}

pagination_lucide <- function(icon) {
  svg <- function(class, inner) {
    paste0(
      '<svg class="', class, '" xmlns="http://www.w3.org/2000/svg" width="24" ',
      'height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" ',
      'stroke-width="2" stroke-linecap="round" stroke-linejoin="round">',
      inner,
      '</svg>'
    )
  }

  switch(icon,
    `chevron-left` = svg(
      "lucide lucide-chevron-left",
      '<path d="m15 18-6-6 6-6" />'
    ),
    `chevron-right` = svg(
      "lucide lucide-chevron-right",
      '<path d="m9 18 6-6-6-6" />'
    ),
    ellipsis = svg(
      "size-4 shrink-0 lucide lucide-ellipsis",
      paste0(
        '<circle cx="12" cy="12" r="1" />',
        '<circle cx="19" cy="12" r="1" />',
        '<circle cx="5" cy="12" r="1" />'
      )
    )
  )
}