# Every Basecoat input wired to Shiny, inside a `bc_page_navbar()` shell.
#
# shiny::runApp(system.file("examples", "shiny-app.R", package = "basecoat"))

library(shiny)
library(basecoat)
library(htmltools)

ui <- tagList(
  bc_deps(),
  bc_shiny_deps(),
  bc_page_navbar(
    tags$div(
      class = "mx-auto flex max-w-lg flex-col gap-6 p-6",
      tags$section(
        class = "prose",
        tags$h1("Inputs"),
        tags$p("Each control below reports straight back to the server.")
      ),
      bc_checkbox("agree", "I agree", checked = TRUE),
      bc_switch("notify", "Notifications"),
      bc_radio_group(
        name = "density",
        label = "Density",
        bc_radio("default", "Default", checked = TRUE),
        bc_radio("comfortable", "Comfortable"),
        bc_radio("compact", "Compact")
      ),
      bc_slider(0, 100, 50, id = "volume", label = "Volume"),
      bc_native_select(
        bc_native_select_option("Apple", value = "apple"),
        bc_native_select_option("Banana", value = "banana"),
        id = "fruit_native",
        label = "Fruit (native)"
      ),
      bc_select(
        "apple",
        "banana",
        "blueberry",
        id = "fruit_select",
        placeholder = "Select a fruit",
        selected = "apple"
      ),
      bc_combobox(
        "framework",
        bc_combobox_option("Next.js"),
        bc_combobox_option("SvelteKit"),
        bc_combobox_option("Remix"),
        placeholder = "Select a framework"
      ),
      bc_input(id = "name", label = "Name", placeholder = "Ada Lovelace"),
      bc_textarea(id = "bio", label = "Bio", placeholder = "A short bio"),
      bc_card(
        bc_card_header(tags$h2("input$ values")),
        bc_card_body(tags$pre(textOutput("values")))
      )
    ),
    title = "basecoat",
    href = "https://basecoatui.com",
    nav = list(
      bc_nav_item("Inputs", href = "#", current = TRUE),
      bc_nav_item("Reference", href = "https://ricochet-rs.github.io/basecoat/")
    ),
    end = bc_theme_switcher()
  )
)

server <- function(input, output) {
  output$values <- renderText({
    values <- list(
      agree = input$agree,
      notify = input$notify,
      density = input$density,
      volume = input$volume,
      fruit_native = input$fruit_native,
      fruit_select = input$fruit_select,
      framework = input$framework,
      name = input$name,
      bio = input$bio
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
