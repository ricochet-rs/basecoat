# A sidebar is a fixed `<aside>` beside page content. Basecoat owns the fixed
# positioning and overlay behaviour, and the app owns the navigation data and
# current route, so the inner builders are named structure markers: a group is
# a heading and its `<ul>`, an item is the `<a>` or `<button>` that carries the
# route attributes, and a submenu is a `<details>` disclosure. The nav wraps an
# optional header, a scrollable content `<section>` and an optional footer.

bc_sidebar_variants <- c("default", "outline")
bc_sidebar_sizes <- c("default", "sm", "lg")

bc_sidebar_id <- function(prefix) {
  paste0(prefix, "-", paste0(sample(1:9, 8, replace = TRUE), collapse = ""))
}

#' Sidebar
#'
#' A fixed navigation panel beside the page content.
#'
#' @param ... Tag attributes and navigation groups for the scrollable
#'   `<section>`, between the optional `<header>` and `<footer>`.
#' @param side String. One of `"left"` or `"right"`. Which viewport side the
#'   sidebar pins to.
#' @param header Tag. Content for the optional `<header>` region, such as a
#'   brand or workspace control, or `NULL`.
#' @param footer Tag. Content for the optional `<footer>` region, such as an
#'   account control, or `NULL`.
#' @param aria_label String. The `aria-label` of the `<nav>` landmark.
#' @param initial_open Bool or `NULL`. Start open on the desktop layout.
#' @param initial_mobile_open Bool or `NULL`. Start open on the mobile overlay.
#' @param breakpoint String or `NULL`. A viewport width below which the sidebar
#'   becomes the mobile overlay, such as `"48rem"`.
#' @return An `<aside>` tag.
#' @details
#' The desktop margin of the sibling `<main>` is Basecoat's own styling; the
#' toggle button that opens and closes the sidebar is a page control.
#' @export
#' @examples
#' bc_sidebar(
#'   id = "sidebar",
#'   bc_sidebar_group(
#'     "Getting started",
#'     bc_sidebar_item("Playground", href = "#", aria_current = TRUE),
#'     bc_sidebar_item("Models", href = "#"),
#'     bc_sidebar_submenu(
#'       "Settings",
#'       bc_sidebar_item("General", href = "#"),
#'       bc_sidebar_item("Limits", href = "#")
#'     )
#'   ),
#'   bc_sidebar_separator(),
#'   bc_sidebar_group(
#'     "Account",
#'     bc_sidebar_item("Billing", href = "#")
#'   )
#' )
bc_sidebar <- function(id = NULL,
                       ...,
                       side = "left",
                       header = NULL,
                       footer = NULL,
                       aria_label = "Sidebar navigation",
                       initial_open = NULL,
                       initial_mobile_open = NULL,
                       breakpoint = NULL) {
  side <- arg_match(side, c("left", "right"))
  check_string(aria_label, allow_empty = FALSE)
  check_bool(initial_open, allow_null = TRUE)
  check_bool(initial_mobile_open, allow_null = TRUE)
  check_string(breakpoint, allow_null = TRUE, allow_empty = FALSE)

  bc_tag(htmltools::attachDependencies(
    tags$aside(
      id = id,
      class = "sidebar",
      `data-side` = side,
      `data-initial-open` = if (!is.null(initial_open)) tolower(initial_open),
      `data-initial-mobile-open` = if (!is.null(initial_mobile_open)) tolower(initial_mobile_open),
      `data-breakpoint` = breakpoint,
      tags$nav(
        `aria-label` = aria_label,
        if (!is.null(header)) tags$header(header),
        tags$section(class = "scrollbar-sm", ...),
        if (!is.null(footer)) tags$footer(footer)
      )
    ),
    bc_script_dep("sidebar")
  ))
}

#' @rdname bc_sidebar
#' @param title String. The group heading, which is also the label of the
#'   group.
#' @param id String or `NULL`. The element `id`. A `NULL` id is generated.
#' @param ... Tag attributes and children, wrapped in `<li>` by [bc_sidebar_group()]
#'   and [bc_sidebar_submenu()].
#' @export
#' @examples
#'
#' bs_group <- bc_sidebar_group(
#'   "Workspace",
#'   bc_sidebar_item("Dashboard", href = "#")
#' )
bc_sidebar_group <- function(title, ..., id = NULL) {
  check_string(title, allow_empty = FALSE)
  check_string(id, allow_null = TRUE, allow_empty = FALSE)

  if (is.null(id)) {
    id <- bc_sidebar_id("sidebar-group")
  }

  bc_tag(div(
    role = "group",
    `aria-labelledby` = id,
    tags$h3(id = id, title),
    tags$ul(lapply(list(...), tags$li))
  ))
}

#' @rdname bc_sidebar
#' @param label String. Text shown on the control, or in the `summary` of a
#'   submenu.
#' @param href String or `NULL`. A destination turns the item into a link, and
#'   `NULL` into a `<button>`.
#' @param icon Tag. An icon shown before the label, such as an `HTML()` lucide
#'   `<svg>`, or `NULL`.
#' @param variant String. One of `r toString(bc_sidebar_variants)`. `default`
#'   writes no attribute.
#' @param size String. One of `r toString(bc_sidebar_sizes)`. `default` writes
#'   no attribute.
#' @param active Bool. Mark the control as the active route.
#' @param disabled Bool. Disable the control in its own way: `disabled` on a
#'   `<button>`, `aria-disabled` on a link.
#' @param aria_current Bool. Write `aria-current = "page"` on a link.
#' @param keep_mobile_open Bool. Keep the mobile sidebar open when this control
#'   is clicked.
#' @export
#' @examples
#'
#' bc_sidebar_item("Profile", href = "/profile", aria_current = TRUE)
bc_sidebar_item <- function(label,
                            href = NULL,
                            ...,
                            icon = NULL,
                            variant = "default",
                            size = "default",
                            active = FALSE,
                            disabled = FALSE,
                            aria_current = FALSE,
                            keep_mobile_open = FALSE) {
  variant <- arg_match(variant, bc_sidebar_variants)
  size <- arg_match(size, bc_sidebar_sizes)
  check_string(label, allow_empty = FALSE)
  check_string(href, allow_null = TRUE, allow_empty = FALSE)
  check_bool(active)
  check_bool(disabled)
  check_bool(aria_current)
  check_bool(keep_mobile_open)

  item_tag <- if (!is.null(href)) tags$a else tags$button

  bc_tag(item_tag(
    href = href,
    type = if (is.null(href)) "button",
    `data-variant` = if (variant != "default") variant,
    `data-size` = if (size != "default") size,
    `data-active` = if (active) "true",
    `data-keep-mobile-sidebar-open` = if (keep_mobile_open) "true",
    `aria-current` = if (aria_current) "page",
    `aria-disabled` = if (disabled && !is.null(href)) "true",
    disabled = if (is.null(href) && disabled) NA,
    ...,
    icon,
    tags$span(label)
  ))
}

#' @rdname bc_sidebar
#' @export
#' @examples
#'
#' bc_sidebar_submenu(
#'   "Settings",
#'   bc_sidebar_item("General", href = "#")
#' )
bc_sidebar_submenu <- function(label,
                               ...,
                               id = NULL,
                               icon = NULL,
                               variant = "default",
                               size = "default",
                               active = FALSE,
                               keep_mobile_open = FALSE) {
  check_string(label, allow_empty = FALSE)
  check_string(id, allow_null = TRUE, allow_empty = FALSE)
  variant <- arg_match(variant, bc_sidebar_variants)
  size <- arg_match(size, bc_sidebar_sizes)
  check_bool(active)
  check_bool(keep_mobile_open)

  if (is.null(id)) {
    id <- bc_sidebar_id("sidebar-submenu")
  }
  content_id <- paste0(id, "-content")

  bc_tag(tags$details(
    id = id,
    tags$summary(
      `aria-controls` = content_id,
      `data-variant` = if (variant != "default") variant,
      `data-size` = if (size != "default") size,
      `data-active` = if (active) "true",
      `data-keep-mobile-sidebar-open` = if (keep_mobile_open) "true",
      icon,
      tags$span(label)
    ),
    tags$ul(id = content_id, lapply(list(...), tags$li))
  ))
}

#' @rdname bc_sidebar
#' @export
bc_sidebar_separator <- function() {
  bc_tag(tags$hr(role = "separator"))
}