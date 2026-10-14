# Every Basecoat input read and updated from a Shiny server.
#
# shiny::runApp(system.file("examples", "shiny-inputs.R", package = "basecoat"))

library(shiny)
library(basecoat)
library(htmltools)

fruits <- c("apple", "banana", "blueberry")
vegetables <- c("carrot", "leek", "pea")

native_inputs <- bc_card(
  bc_card_header(
    "Shiny bindings",
    tags$p("Read and updated with Shiny's own functions.")
  ),
  bc_card_body(
    class = "flex flex-col gap-4",
    bc_checkbox("agree", "I agree", checked = TRUE),
    bc_switch("notify", "Notifications"),
    bc_input(id = "name", label = "Name", placeholder = "Ada Lovelace"),
    bc_input(id = "age", label = "Age", type = "number", value = "36"),
    bc_textarea(id = "bio", label = "Bio", placeholder = "A short bio"),
    bc_input(id = "birthday", label = "Birthday", type = "date"),
    bc_input(id = "favourite", label = "Favourite colour", type = "color"),
    bc_native_select(
      bc_native_select_option("apple", label = "Apple"),
      bc_native_select_option("banana", label = "Banana"),
      id = "fruit_native",
      label = "Fruit (native)"
    )
  )
)

basecoat_inputs <- bc_card(
  bc_card_header(
    "basecoat bindings",
    tags$p("Read with bc_shiny_deps() and updated with the bc_update functions.")
  ),
  bc_card_body(
    class = "flex flex-col gap-4",
    bc_dropdown_menu(
      bc_dropdown_checkbox("Show grid", id = "grid", checked = TRUE),
      bc_dropdown_separator(),
      bc_dropdown_group(
        "Size",
        bc_dropdown_radio("Small"),
        bc_dropdown_radio("Medium", checked = TRUE),
        bc_dropdown_radio("Large"),
        id = "size"
      ),
      trigger_label = "View options"
    ),
    bc_radio_group(
      name = "density",
      label = "Density",
      bc_radio("default", "Default", checked = TRUE),
      bc_radio("comfortable", "Comfortable"),
      bc_radio("compact", "Compact")
    ),
    bc_slider(0, 100, 50, id = "volume", label = "Volume"),
    bc_select(fruits, id = "produce", class = "w-full"),
    bc_select(
      fruits,
      id = "basket",
      placeholder = "Fill a basket",
      multiple = TRUE,
      class = "w-full"
    ),
    bc_combobox(
      "framework",
      bc_combobox_option("Next.js"),
      bc_combobox_option("SvelteKit"),
      bc_combobox_option("Remix"),
      placeholder = "Select a framework"
    ),
    bc_accordion(
      id = "faq",
      bc_accordion_item("Billing", "Invoices go out monthly.", id = "billing"),
      bc_accordion_item("Refunds", "Refunds take five days.", id = "refunds")
    ),
    bc_command(
      id = "palette",
      bc_command_item("Calendar"),
      bc_command_item("Settings"),
      bc_command_item("Search emoji")
    ),
    bc_tabs(
      id = "view",
      bc_tab("Shown on the first tab.", label = "Overview"),
      bc_tab("Shown on the second tab.", label = "Activity")
    )
  )
)

controls <- bc_card(
  bc_card_header("From the server"),
  bc_card_body(
    class = "flex flex-wrap gap-2",
    bc_button("Update every input", id = "update"),
    bc_button(
      "Swap select choices",
      id = "swap",
      variant = "outline"
    ),
    bc_button("Open dialog", id = "show_dialog", variant = "outline"),
    bc_button("Show toast", id = "show_toast", variant = "outline"),
    bc_button("Toggle sidebar", id = "toggle_sidebar", variant = "outline"),
    bc_alert_dialog(
      id = "confirm",
      title = "Delete the project?",
      description = "This cannot be undone.",
      trigger = "Delete project"
    ),
    bc_drawer(
      bc_switch(
        "cookies_essential",
        "Essential",
        checked = TRUE,
        disabled = TRUE,
        description = "Needed for the site to work. Always on."
      ),
      bc_switch(
        "cookies_analytics",
        "Analytics",
        description = "Counts visits so we know which pages earn their keep."
      ),
      bc_switch(
        "cookies_marketing",
        "Marketing",
        description = "Lets advertisers follow you between sites."
      ),
      id = "cookies",
      title = "Cookies",
      description = "Choose what this site may store on your device.",
      trigger = "Cookie settings",
      actions = tagList(
        bc_dialog_close("Reject non-essential", variant = "outline"),
        bc_dialog_close("Accept all")
      )
    )
  ),
  bc_dialog(
    "notice",
    title = "Opened from the server",
    description = "bc_update_dialog() opened this dialog.",
    actions = bc_dialog_close("Close")
  )
)

values <- bc_card(
  bc_card_header("input$ values"),
  bc_card_body(tags$pre(class = "text-sm", textOutput("values")))
)

ui <- bc_page_sidebar(
  bc_shiny_deps(),
  title = "Shiny inputs",
  header = bc_theme_switcher(id = "theme"),
  sidebar = bc_sidebar(
    id = "sidebar",
    bc_sidebar_group(
      "Examples",
      bc_sidebar_item("Inputs", href = "#", aria_current = TRUE)
    )
  ),
  tags$div(
    class = "grid items-start gap-4 sm:grid-cols-3",
    native_inputs,
    basecoat_inputs,
    tags$div(class = "flex flex-col gap-4", values, controls)
  ),
  bc_toaster()
)

server <- function(input, output, session) {
  observeEvent(input$update, {
    updateCheckboxInput(inputId = "agree", value = FALSE)
    updateCheckboxInput(inputId = "notify", value = TRUE)
    updateTextInput(inputId = "name", value = "Grace Hopper")
    updateNumericInput(inputId = "age", value = 85)
    updateTextAreaInput(inputId = "bio", value = "Wrote the first compiler.")
    updateTextInput(inputId = "birthday", value = "1906-12-09")
    updateTextInput(inputId = "favourite", value = "#7c3aed")
    updateSelectInput(inputId = "fruit_native", selected = "banana")
    updateTabsetPanel(inputId = "view", selected = "Activity")
    updateCheckboxInput(inputId = "grid", value = FALSE)
    updateRadioButtons(inputId = "size", selected = "Large")

    bc_update_radio_group("density", "compact")
    bc_update_slider("volume", 80)
    updateSelectInput(inputId = "produce", selected = "blueberry")
    bc_update_select("basket", c("apple", "banana"))
    bc_update_combobox("framework", "Remix")
    bc_update_accordion("faq", "refunds")
    updateTextInput(inputId = "palette-input", value = "set")
    bc_update_theme_switcher("theme", if (input$theme == "dark") "light" else "dark")
    updateActionButton(inputId = "swap", label = "Swap the choices again")
    bc_show_toast(bc_toast("Every input updated", category = "success"))
  })

  observeEvent(input$show_toast, {
    bc_show_toast(bc_toast("Hello from the server", category = "info"))
  })

  observeEvent(input$toggle_sidebar, {
    bc_update_sidebar("sidebar", !isTRUE(input$sidebar))
  })

  observeEvent(input$show_dialog, {
    bc_update_dialog("notice", TRUE)
  })

  observeEvent(input$swap, {
    choices <- if (input$swap %% 2 == 1) vegetables else fruits
    updateSelectInput(inputId = "produce", label = "Produce", choices = choices)
  })

  output$values <- renderText({
    values <- list(
      agree = input$agree,
      notify = input$notify,
      name = input$name,
      age = input$age,
      bio = input$bio,
      birthday = input$birthday,
      favourite = input$favourite,
      fruit_native = input$fruit_native,
      density = input$density,
      volume = input$volume,
      produce = input$produce,
      basket = input$basket,
      framework = input$framework,
      faq = input$faq,
      palette = input$`palette-input`,
      view = input$view,
      grid = input$grid,
      size = input$size,
      sidebar = input$sidebar,
      confirm = input$confirm,
      theme = input$theme,
      update = as.integer(input$update),
      swap = as.integer(input$swap),
      notice = input$notice,
      cookies = input$cookies,
      cookies_analytics = input$cookies_analytics,
      cookies_marketing = input$cookies_marketing
    )
    paste(
      names(values),
      vapply(values, function(x) {
        if (inherits(x, "Date")) x <- format(x)
        paste(deparse(x), collapse = "")
      }, character(1)),
      sep = ": ",
      collapse = "\n"
    )
  })
}

shinyApp(ui, server)
