# A complete application shell: a collapsible navigation sidebar, a `<main>`
# that takes the desktop margin, and the controls that open and close it.
#
#   source(system.file("examples", "sidebar-app.R", package = "basecoat"))
#
# Below the breakpoint the sidebar becomes an overlay that closes when a link
# inside it is clicked. Above it, the toggle in the toolbar collapses the panel
# and `<main>` reclaims the width. Both are the Sidebar script's doing, and
# `bc_sidebar()` attaches it itself, along with what `bc_dropdown_menu()`
# needs for the header and footer controls.
#
#   sidebar_app()                       # the default pack
#   sidebar_app("rhea")                 # another pack
#   sidebar_app("vega", theme = "~/theme.css")   # under your own tokens

library(basecoat)
library(htmltools)
library(phosphoricons)

# `ph()` returns inline SVG, so these still pull nothing over the network.
icons <- list(
  panel = ph("sidebar-simple", title = NULL),
  terminal = ph("terminal-window", title = NULL),
  bot = ph("robot", title = NULL),
  book = ph("book-open", title = NULL),
  settings = ph("gear", title = NULL),
  life = ph("lifebuoy", title = NULL)
)

# The id the toggle reaches for. The Sidebar script puts `open()`, `close()` and
# `toggle()` on the element itself, so a plain onclick is the whole wiring.
sidebar_id <- "app-sidebar"

sidebar_toggle <- function(label = "Toggle sidebar") {
  bc_button(
    icons$panel,
    variant = "ghost",
    size = "icon",
    aria_label = label,
    `aria-controls` = sidebar_id,
    onclick = paste0("document.getElementById('", sidebar_id, "')?.toggle()")
  )
}

# Branding and a workspace switcher, pinned above the scrolling nav.
app_header <- bc_dropdown_menu(
  bc_dropdown_group(
    "Workspaces",
    bc_dropdown_radio("Acme Inc", checked = TRUE),
    bc_dropdown_radio("Globex")
  ),
  bc_dropdown_separator(),
  bc_dropdown_item("Add workspace", shortcut = "N"),
  trigger_label = "Acme Inc",
  variant = "ghost",
  align = "start"
)

# The account control, pinned below it. Opening upwards keeps it on screen.
app_footer <- bc_dropdown_menu(
  bc_dropdown_group(
    "Signed in",
    bc_dropdown_item("Account", shortcut = "A"),
    bc_dropdown_item("Billing", shortcut = "B")
  ),
  bc_dropdown_separator(),
  bc_dropdown_item("Log out", variant = "destructive"),
  trigger_label = "Ada Lovelace",
  variant = "ghost",
  side = "top",
  align = "start"
)

app_sidebar <- bc_sidebar(
  id = sidebar_id,
  breakpoint = "48rem",
  header = app_header,
  footer = app_footer,
  bc_sidebar_group(
    "Platform",
    bc_sidebar_item(
      "Playground",
      href = "#playground",
      icon = icons$terminal,
      aria_current = TRUE
    ),
    bc_sidebar_item("Models", href = "#models", icon = icons$bot),
    bc_sidebar_submenu(
      "Settings",
      bc_sidebar_item("General", href = "#general"),
      bc_sidebar_item("Team", href = "#team"),
      bc_sidebar_item("Limits", href = "#limits"),
      icon = icons$settings
    )
  ),
  bc_sidebar_separator(),
  bc_sidebar_group(
    "Resources",
    bc_sidebar_item("Documentation", href = "#docs", icon = icons$book),
    bc_sidebar_item("Support", href = "#support", icon = icons$life),
    # This one opens a panel rather than navigating, so the mobile overlay has
    # no reason to close behind it.
    bc_sidebar_item(
      "Changelog",
      href = "#changelog",
      keep_mobile_open = TRUE
    )
  )
)

# The toolbar above the page content. The toggle lives here rather than in the
# sidebar so it stays reachable once the panel is collapsed.
app_toolbar <- tags$header(
  class = "flex items-center gap-2 border-b p-3",
  sidebar_toggle(),
  bc_breadcrumb(
    bc_breadcrumb_item("Acme Inc", href = "#"),
    bc_breadcrumb_item("Platform", href = "#"),
    bc_breadcrumb_item("Playground", current = TRUE)
  ),
  div(class = "ml-auto flex items-center gap-2", bc_theme_switcher())
)

app_content <- div(
  class = "flex flex-col gap-6 p-6",
  tags$h1(class = "text-2xl font-semibold", "Playground"),
  div(
    class = "grid gap-4 sm:grid-cols-2",
    bc_card(
      bc_card_header(
        tags$h2("Production deploy"),
        tags$p("v1.4.2, 3m 12s"),
        bc_card_action(bc_badge("passed", variant = "secondary"))
      ),
      bc_card_body(tags$p("All 128 checks green.")),
      bc_card_footer(bc_button("Audit", variant = "outline", size = "sm"))
    ),
    bc_card(
      bc_card_header(
        tags$h2("Usage"),
        tags$p("Requests this month")
      ),
      bc_card_body(bc_progress(66, label = "Monthly quota")),
      bc_card_footer(tags$p("660k of 1M."))
    )
  ),
  bc_item_group(
    bc_item(
      tags$section(
        tags$h3("Collapse the sidebar"),
        tags$p("The toolbar toggle calls toggle() on the aside element.")
      ),
      tags$aside(sidebar_toggle("Collapse from the content area")),
      variant = "outline",
      role = "listitem"
    ),
    bc_item(
      tags$section(
        tags$h3("Narrow the window"),
        tags$p("Below 48rem the sidebar becomes an overlay.")
      ),
      variant = "outline",
      role = "listitem"
    )
  )
)

sidebar_app <- function(
  style = NULL,
  theme = NULL,
  file = tempfile("basecoat-sidebar-", fileext = ".html"),
  browse = TRUE
) {
  page <- tagList(
    app_sidebar,
    # The desktop margin lands on the sibling immediately after the sidebar, so
    # `<main>` has to come next.
    tags$main(app_toolbar, app_content)
  )

  save_html(
    attachDependencies(page, bc_deps(style = style, theme = theme)),
    file,
    background = "var(--background)"
  )

  # A page under `tempfile()` lives only as long as the session, so pass `file`
  # to keep one, and `browse = FALSE` when nothing should open.
  if (browse) {
    utils::browseURL(file)
  }

  invisible(file)
}

sidebar_app(theme = )
