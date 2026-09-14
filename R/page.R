# Page layouts. These compose components that already exist into the two
# shapes almost every app starts from, the way bslib's page_sidebar() and
# page_navbar() do. They return the body markup rather than a whole document:
# the head is still the caller's, and bc_deps() still goes in it.

# Phosphor's sidebar-simple, inlined so the toggle needs no icon set.
bc_panel_icon <- paste0(
  '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" ',
  'viewBox="0 0 256 256" fill="currentColor" aria-hidden="true">',
  '<path d="M216,40H40A16,16,0,0,0,24,56V200a16,16,0,0,0,16,16H216a16,16,0,0,0,',
  '16-16V56A16,16,0,0,0,216,40ZM40,56H80V200H40ZM216,200H96V56H216V200Z"/>',
  '</svg>'
)

#' Page with a sidebar
#'
#' A collapsible [bc_sidebar()] beside a `<main>` region, with a header
#' carrying the sidebar toggle and a title.
#'
#' @param ... Tag attributes and children for the `<main>` content region.
#' @param sidebar A [bc_sidebar()] tag.
#' @param title String or tag. Shown in the header beside the toggle.
#' @param header Tag or `NULL`. Extra header content, aligned to the end, such
#'   as [bc_theme_switcher()] or an avatar.
#' @param toggle Bool. Whether the header carries the sidebar toggle.
#' @param toggle_label String. Accessible name for the toggle.
#' @return A [htmltools::tagList()] of the `<aside>` and the `<main>`.
#' @seealso [bc_page_navbar()]
#' @export
#' @examples
#' bc_page_sidebar(
#'   class = "prose",
#'   htmltools::h2("Overview"),
#'   htmltools::p("Everything is fine."),
#'   sidebar = bc_sidebar(
#'     id = "reports-sidebar",
#'     bc_sidebar_group(
#'       "Reports",
#'       bc_sidebar_item("Daily", href = "#", aria_current = TRUE),
#'       bc_sidebar_item("Weekly", href = "#")
#'     )
#'   ),
#'   title = "Dashboard",
#'   header = bc_theme_switcher()
#' )
bc_page_sidebar <- function(
  ...,
  sidebar,
  title = NULL,
  header = NULL,
  toggle = TRUE,
  toggle_label = "Toggle sidebar"
) {
  check_bool(toggle)
  check_string(toggle_label, allow_empty = FALSE)

  if (!inherits(sidebar, "shiny.tag") || !identical(sidebar$name, "aside")) {
    cli::cli_abort(c(
      "{.arg sidebar} must be a {.fun bc_sidebar} tag.",
      i = "{.fun bc_sidebar} takes {.arg id} first, so name its other arguments."
    ))
  }

  sidebar_id <- sidebar$attribs$id %||% bc_sidebar_id("sidebar")
  sidebar$attribs$id <- sidebar_id

  head <- if (toggle || !is.null(title) || !is.null(header)) {
    tags$header(
      class = "flex items-center gap-3 border-b px-4 py-3",
      if (toggle) bc_sidebar_toggle(sidebar_id, toggle_label),
      if (!is.null(title)) tags$h1(class = "text-lg font-semibold", title),
      if (!is.null(header)) {
        tags$div(class = "ms-auto flex items-center gap-2", header)
      }
    )
  }

  bc_tag(tagList(
    sidebar,
    tags$main(head, ...)
  ))
}

#' @rdname bc_page_sidebar
#' @param id String. The `id` of the [bc_sidebar()] to toggle.
#' @param label String. Accessible name for the button.
#' @export
#' @examples
#'
#' bc_sidebar_toggle("sidebar")
bc_sidebar_toggle <- function(id, label = "Toggle sidebar") {
  check_string(id, allow_empty = FALSE)
  check_string(label, allow_empty = FALSE)

  bc_tag(htmltools::attachDependencies(
    tags$button(
      type = "button",
      class = "btn",
      `data-variant` = "ghost",
      `data-size` = "icon",
      `aria-label` = label,
      `aria-controls` = id,
      onclick = paste0("document.getElementById('", id, "')?.toggle()"),
      HTML(bc_panel_icon)
    ),
    bc_script_dep("sidebar")
  ))
}

#' Page with a navbar
#'
#' A sticky top navigation bar over a `<main>` region.
#'
#' @param ... Tag attributes and children for the `<main>` content region.
#' @param title String or tag. The brand, shown first.
#' @param nav Tag or list. Navigation controls, usually [bc_nav_item()]s.
#' @param end Tag or `NULL`. Content aligned to the end of the bar, such as
#'   [bc_theme_switcher()] or a [bc_dropdown_menu()].
#' @param href String or `NULL`. Makes the brand a link.
#' @param aria_label String. Accessible name for the `<nav>` landmark.
#' @return A [htmltools::tagList()] of the `<header>` and the `<main>`.
#' @seealso [bc_page_sidebar()]
#' @export
#' @examples
#' bc_page_navbar(
#'   htmltools::h2("Overview"),
#'   title = "Acme",
#'   href = "/",
#'   nav = list(
#'     bc_nav_item("Home", href = "/", current = TRUE),
#'     bc_nav_item("Reports", href = "/reports")
#'   ),
#'   end = bc_theme_switcher()
#' )
bc_page_navbar <- function(
  ...,
  title = NULL,
  nav = NULL,
  end = NULL,
  href = NULL,
  aria_label = "Main navigation"
) {
  check_string(href, allow_null = TRUE, allow_empty = FALSE)
  check_string(aria_label, allow_empty = FALSE)

  brand <- if (!is.null(title)) {
    if (is.null(href)) {
      tags$span(class = "font-semibold", title)
    } else {
      tags$a(class = "font-semibold", href = href, title)
    }
  }

  bc_tag(tagList(
    tags$header(
      class = "bg-background sticky top-0 z-30 flex items-center gap-6 border-b px-4 py-3",
      brand,
      if (!is.null(nav)) {
        tags$nav(
          `aria-label` = aria_label,
          tags$ul(
            class = "flex list-none items-center gap-1",
            lapply(nav, tags$li)
          )
        )
      },
      if (!is.null(end)) {
        tags$div(class = "ms-auto flex items-center gap-2", end)
      }
    ),
    tags$main(...)
  ))
}

#' @rdname bc_page_navbar
#' @param label String or tag. The item's text.
#' @param current Bool. Marks the item as the current page.
#' @param disabled Bool. Whether the item is disabled.
#' @export
#' @examples
#'
#' bc_nav_item("Reports", href = "/reports", current = TRUE)
bc_nav_item <- function(
  label,
  href = NULL,
  ...,
  current = FALSE,
  disabled = FALSE
) {
  check_string(href, allow_null = TRUE, allow_empty = FALSE)
  check_bool(current)
  check_bool(disabled)

  # A nav item is a button, so its shape, hover and focus come from the style
  # pack rather than from anything this package invents.
  variant <- if (current) "secondary" else "ghost"

  if (is.null(href)) {
    return(bc_tag(tags$button(
      type = "button",
      class = "btn",
      `data-variant` = variant,
      `data-size` = "sm",
      disabled = if (disabled) NA,
      ...,
      label
    )))
  }

  bc_tag(a(
    href = href,
    class = "btn",
    `data-variant` = variant,
    `data-size` = "sm",
    `aria-current` = if (current) "page",
    `aria-disabled` = if (disabled) "true",
    ...,
    label
  ))
}

#' A complete HTML page
#'
#' A whole document as a string, with the stylesheet and every component
#' script already in the head. For servers that write their own HTML.
#'
#' @param ... Tag attributes and children for the `<body>`.
#' @param title String. The page title.
#' @param assets String. The URL prefix the bundled directory is served from.
#' @param style String or `NULL`. A style pack, as in [bc_deps()].
#' @param head Tag or `NULL`. Extra content for the `<head>`.
#' @param lang String. The `lang` attribute on `<html>`.
#' @return A single string.
#' @details
#' Serve `system.file("basecoat", package = "basecoat")` at `assets`. Every
#' dependency the components ask for is rewritten to that prefix.
#' @seealso [bc_deps()], [bc_page_sidebar()], [bc_page_navbar()]
#' @export
#' @examples
#' cat(substr(bc_page(bc_button("Save"), title = "Demo"), 1, 80))
bc_page <- function(
  ...,
  title = NULL,
  assets = "/basecoat/",
  style = NULL,
  head = NULL,
  lang = "en"
) {
  check_string(title, allow_null = TRUE, allow_empty = FALSE)
  check_string(assets, allow_empty = FALSE)
  check_string(lang, allow_empty = FALSE)

  body <- tagList(...)

  deps <- c(
    list(bc_deps(style = style, source = assets)),
    htmltools::findDependencies(body)
  )
  deps <- lapply(deps, bc_page_remount, assets = assets)
  deps <- htmltools::resolveDependencies(deps, resolvePackageDir = FALSE)

  paste0(
    "<!doctype html>\n<html lang=\"",
    lang,
    "\">\n<head>\n",
    paste(
      c(
        '<meta charset="utf-8">',
        if (!is.null(title)) as.character(tags$title(title)),
        htmltools::renderDependencies(deps, "href"),
        if (!is.null(head)) as.character(head)
      ),
      collapse = "\n"
    ),
    "\n</head>\n<body>\n",
    as.character(body),
    "\n</body>\n</html>"
  )
}

# A dependency shipped by this package points at files inside it, which no
# server can reach. Everything it owns lives under one directory, so one
# prefix stands in for all of them.
bc_page_remount <- function(dep, assets) {
  if (!identical(dep$package, "basecoat")) {
    return(dep)
  }

  dep$src <- c(href = sub("/+$", "", assets))
  dep$package <- NULL
  dep
}
