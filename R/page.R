# Page layouts. bc_page_sidebar() and bc_page_navbar() compose components that
# already exist into the two shapes almost every app starts from, the way
# bslib's page_sidebar() and page_navbar() do. They return body markup, so the
# head stays the caller's and bc_deps() goes in the tree with everything else.
# bc_page() is the exception: a whole document as a string, for servers that
# cannot return tags.

# Phosphor's sidebar-simple, inlined so the toggle needs no icon set.
bc_panel_icon <- paste0(
  '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" ',
  'viewBox="0 0 256 256" fill="currentColor" aria-hidden="true">',
  '<path d="M216,40H40A16,16,0,0,0,24,56V200a16,16,0,0,0,16,16H216a16,16,0,0,0,',
  '16-16V56A16,16,0,0,0,216,40ZM40,56H80V200H40ZM216,200H96V56H216V200Z"/>',
  '</svg>'
)

#' Page with a Sidebar
#'
#' Create a page with a collapsible sidebar.
#'
#' @param ... Page content.
#' @param sidebar A [bc_sidebar()].
#' @param title String or tag. The page title.
#' @param header Tag or `NULL`. Extra content for the top of the page, such
#'   as [bc_theme_switcher()] or an avatar.
#' @param toggle Bool. Whether to show a button that opens and closes the
#'   sidebar. Defaults to `TRUE`.
#' @param toggle_label String. Accessible name for the toggle. Defaults to
#'   `"Toggle sidebar"`.
#' @return An [htmltools::tagList()].
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
#' @param id String. The ID of the [bc_sidebar()] to toggle.
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

#' Page with a Navbar
#'
#' Create a page with a navbar.
#'
#' @param ... For `bc_page_navbar()`, page content. For `bc_nav_item()`, extra
#'   tag attributes.
#' @param title String or tag. The app name, shown first in the navbar.
#' @param nav Tag or list. Links for the navbar, usually from [bc_nav_item()].
#' @param end Tag or `NULL`. Content aligned to the end of the navbar, such as
#'   [bc_theme_switcher()] or a [bc_dropdown_menu()].
#' @param href String or `NULL`. A link URL. For `bc_page_navbar()`, it makes
#'   the app name a link. For `bc_nav_item()`, `NULL` makes a button.
#' @param aria_label String. Accessible name for the navbar. Defaults to
#'   `"Main navigation"`.
#' @return An [htmltools::tagList()].
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
    tags$main(class = "flex-1", ...)
  ))
}

#' @rdname bc_page_navbar
#' @param label String or tag. The item's text.
#' @param current Bool. Whether the item is the current page. Defaults to
#'   `FALSE`.
#' @param disabled Bool. Whether the item is disabled. Defaults to `FALSE`.
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

  # A nav item is a button, so its shape, hover, and focus come from the style
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

#' HTML Page as a String
#'
#' Create a full HTML page as a string, for servers that send strings rather
#' than tags, such as plumber2, ambiorix, or nanonext. The page loads the
#' stylesheet and the scripts your components need.
#'
#' @param ... Page content.
#' @param title String. The page title.
#' @param assets String. The URL the bundled Basecoat files are served from.
#'   Defaults to `"/basecoat/"`.
#' @param style String or `NULL`. A style pack, as in [bc_deps()].
#' @param theme String or `NULL`. Path to a CSS file of your own. It loads
#'   after the style pack, so its tokens take precedence.
#' @param head Tag or `NULL`. Extra content for the page head, such as the
#'   htmx script.
#' @param lang String. The page language. Defaults to `"en"`.
#' @return A single string.
#' @details
#' Serve `system.file("basecoat", package = "basecoat")` at the `assets` URL.
#'
#' The `theme` file is written into the page, so you do not need to serve it.
#' @seealso [bc_deps()], [bc_page_sidebar()], [bc_page_navbar()]
#' @export
#' @examples
#' cat(substr(bc_page(bc_button("Save"), title = "Demo"), 1, 80))
#'
#' theme <- system.file("examples", "tweakcn-theme.css", package = "basecoat")
#' page <- bc_page(bc_button("Save"), theme = theme)
bc_page <- function(
  ...,
  title = NULL,
  assets = "/basecoat/",
  style = NULL,
  theme = NULL,
  head = NULL,
  lang = "en"
) {
  check_string(title, allow_null = TRUE, allow_empty = FALSE)
  check_string(assets, allow_empty = FALSE)
  check_string(theme, allow_null = TRUE, allow_empty = FALSE)
  check_string(lang, allow_empty = FALSE)

  if (!is.null(theme) && !file.exists(theme)) {
    cli::cli_abort("No file at {.path {theme}}.")
  }

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
        if (!is.null(theme)) {
          as.character(tags$style(HTML(
            paste(readLines(theme, warn = FALSE), collapse = "\n")
          )))
        },
        if (!is.null(head)) as.character(head)
      ),
      collapse = "\n"
    ),
    "\n</head>\n<body class=\"flex min-h-screen flex-col\">\n",
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
