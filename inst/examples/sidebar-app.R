# An application shell built with bc_page_sidebar().
#
# source(system.file("examples", "sidebar-app.R", package = "basecoat"))
#
# sidebar_app()
# sidebar_app("rhea")
# sidebar_app(
#   "vega",
#   theme = system.file(
#     "examples/tweakcn-theme.css",
#     package = "basecoat"
#   )
# )

library(basecoat)
library(htmltools)
library(phosphoricons)

icons <- list(
  terminal = ph("terminal-window", title = NULL),
  bot = ph("robot", title = NULL),
  book = ph("book-open", title = NULL),
  settings = ph("gear", title = NULL),
  life = ph("lifebuoy", title = NULL)
)

sidebar_id <- "app-sidebar"

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

app_crumbs <- bc_breadcrumb(
  bc_breadcrumb_item("Acme Inc", href = "#"),
  bc_breadcrumb_item("Platform", href = "#"),
  bc_breadcrumb_item("Playground", current = TRUE)
)

app_content <- div(
  class = "flex flex-col gap-6 p-6",
  app_crumbs,
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
      title = "Collapse the sidebar",
      description = "The header toggle calls toggle() on the aside element.",
      actions = bc_sidebar_toggle(sidebar_id, "Collapse from the content area"),
      variant = "outline",
      role = "listitem"
    ),
    bc_item(
      title = "Narrow the window",
      description = "Below 48rem the sidebar becomes an overlay.",
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
  page <- bc_page_sidebar(
    app_content,
    sidebar = app_sidebar,
    title = "Playground",
    header = bc_theme_switcher()
  )

  save_html(
    attachDependencies(page, bc_deps(style = style, theme = theme)),
    file,
    background = "var(--background)"
  )

  if (browse) {
    utils::browseURL(file)
  }

  invisible(file)
}

sidebar_app()
