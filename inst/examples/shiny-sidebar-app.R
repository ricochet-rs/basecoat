# An application shell with a collapsible sidebar
# shiny::runApp(system.file("examples", "shiny-sidebar-app.R", package = "basecoat"))

library(shiny)
library(basecoat)
library(htmltools)
library(phosphoricons)

icons <- list(
  terminal = ph("terminal-window", title = NULL),
  settings = ph("gear", title = NULL),
  book = ph("book-open", title = NULL)
)

sidebar_id <- "app-sidebar"

app_header <- bc_dropdown_menu(
  bc_dropdown_group(
    "Workspaces",
    bc_dropdown_radio("Acme Inc", checked = TRUE),
    bc_dropdown_radio("Globex")
  ),
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
      icon = icons$terminal
    ),
    bc_sidebar_item(
      "Settings",
      href = "#settings",
      icon = icons$settings,
      aria_current = TRUE
    )
  ),
  bc_sidebar_separator(),
  bc_sidebar_group(
    "Resources",
    bc_sidebar_item("Documentation", href = "#docs", icon = icons$book)
  )
)

settings_form <- bc_card(
  bc_card_header(
    tags$h2("Profile"),
    tags$p("These settings are wired up as Shiny inputs.")
  ),
  bc_card_body(
    class = "flex flex-col gap-4",
    bc_input(
      id = "display_name",
      label = "Display name",
      value = "Ada Lovelace"
    ),
    bc_textarea(
      id = "bio",
      label = "Bio",
      placeholder = "A short bio",
      rows = "3"
    ),
    bc_select(
      "utc",
      "est",
      "pst",
      id = "timezone",
      label = "Timezone",
      placeholder = "Select a timezone",
      selected = "utc"
    ),
    bc_combobox(
      "framework",
      bc_combobox_option("Next.js"),
      bc_combobox_option("SvelteKit"),
      bc_combobox_option("Remix"),
      placeholder = "Preferred framework"
    ),
    bc_radio_group(
      name = "plan",
      label = "Plan",
      bc_radio("monthly", "Monthly", checked = TRUE),
      bc_radio("yearly", "Yearly")
    ),
    bc_slider(
      0,
      100,
      80,
      id = "storage_limit",
      label = "Storage alert threshold (%)"
    ),
    bc_switch("notify", "Email notifications", checked = TRUE)
  )
)

values_card <- bc_card(
  bc_card_header(tags$h2("input$ values")),
  bc_card_body(tags$pre(textOutput("values")))
)

app_content <- div(
  class = "flex max-w-lg flex-col gap-6 p-6",
  bc_breadcrumb(
    bc_breadcrumb_item("Acme Inc", href = "#"),
    bc_breadcrumb_item("Settings", current = TRUE)
  ),
  settings_form,
  values_card
)

ui <- tagList(
  bc_deps(style = "lyra"),
  bc_shiny_deps(),
  bc_page_sidebar(
    app_content,
    sidebar = app_sidebar,
    title = "Settings",
    header = bc_theme_switcher()
  )
)

server <- function(input, output) {
  output$values <- renderText({
    values <- list(
      display_name = input$display_name,
      bio = input$bio,
      timezone = input$timezone,
      framework = input$framework,
      plan = input$plan,
      storage_limit = input$storage_limit,
      notify = input$notify
    )
    paste(
      names(values),
      vapply(values, toString, character(1)),
      sep = ": ",
      collapse = "\n"
    )
  })
}

shinyApp(ui, server)
