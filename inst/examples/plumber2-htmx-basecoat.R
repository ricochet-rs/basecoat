# A plumber2 API that demonstrates Basecoat components with htmxr.
#
# This example shows how to use Basecoat UI components within an HTMXR
# application, including forms, cards, and interactive elements.
#
# Run from package root with:
#
# plumber2::api("inst/examples/plumber2-htmx-basecoat.R") |>
#   htmxr::hx_serve_assets() |>
#   plumber2::api_run()
#
# Then open http://localhost:8080 to see the Basecoat HTMX application.

library(htmxr)
library(basecoat)

#* @get /
#* @serializer htmx
function() {
  hx_page(
    hx_head(
      title = "Basecoat with HTMXR",
      htmltools::renderDependencies(
        list(bc_deps(style = "lyra", js = TRUE, source = "cdn")),
        srcType = "href"
      )
    ),
    tags$main(
      class = "flex flex-col items-center gap-6 p-10 max-w-4xl mx-auto",
      tags$h1(
        style = "font-size:2rem;font-weight:700;margin:0",
        "Basecoat Components with HTMXR"
      ),
      tags$p(
        style = "color:var(--muted-foreground);margin:0;text-align:center;",
        "This page demonstrates Basecoat UI components integrated with HTMXR for interactive web applications."
      ),

      # Example of a card component
      bc_card(
        bc_card_header(h2("Interactive Card")),
        bc_card_body(
          tags$p("This is an example card component from Basecoat."),
          tags$p("It can contain any HTML content including forms and buttons.")
        ),
        bc_card_footer(
          bc_button("Action Button", variant = "outline")
        )
      ),

      # Example of a form with basecoat styling
      bc_form(
        bc_field(
          tags$label(`for` = "user-name", "Name"),
          bc_input(id = "user-name", placeholder = "Enter your name")
        ),
        bc_field(
          tags$label(`for` = "user-email", "Email"),
          bc_input(
            id = "user-email",
            type = "email",
            placeholder = "Enter your email"
          )
        ),
        bc_button("Submit Form", type = "submit", variant = "default")
      ),

      # Example of a table with basecoat styling
      bc_table(
        bc_table_header(
          bc_table_row(
            bc_table_cell("Name"),
            bc_table_cell("Email"),
            bc_table_cell("Status")
          )
        ),
        bc_table_body(
          bc_table_row(
            bc_table_cell("John Doe"),
            bc_table_cell("john@example.com"),
            bc_table_cell(bc_badge("Active", variant = "default"))
          ),
          bc_table_row(
            bc_table_cell("Jane Smith"),
            bc_table_cell("jane@example.com"),
            bc_table_cell(bc_badge("Inactive", variant = "secondary"))
          )
        )
      ),

      # Example of a toast trigger
      bc_toast_trigger(
        "Show Success Toast",
        get = "/fragments/toast/success"
      ),

      # Example of a modal trigger
      bc_button("Open Modal", id = "open-modal-btn", variant = "outline"),

      # The toaster for displaying toasts
      bc_toaster()
    )
  )
}

#* @get /fragments/toast/success
#* @serializer htmx
function() {
  bc_toast(
    "Success",
    description = "Your changes have been saved successfully.",
    category = "success",
    cancel = list(label = "Dismiss")
  )
}

#* @post /submit-form
#* @serializer htmx
function(req) {
  # Process form submission
  name <- req$post$`user-name`
  email <- req$post$`user-email`

  if (is.null(name) || is.null(email)) {
    bc_toast(
      "Error",
      description = "Please fill in all fields.",
      category = "error",
      cancel = list(label = "Dismiss")
    )
  } else {
    # Simulate processing
    Sys.sleep(0.5)

    bc_toast(
      "Success",
      description = paste("Form submitted for", name),
      category = "success",
      cancel = list(label = "Dismiss")
    )
  }
}

#* @get /modal-content
#* @serializer htmx
function() {
  # Content for modal
  bc_modal(
    bc_modal_header(h3("Modal Title")),
    bc_modal_body(
      tags$p("This is an example of a modal component from Basecoat."),
      tags$p("It can contain any content including forms and buttons.")
    ),
    bc_modal_footer(
      bc_button(
        "Close",
        variant = "outline",
        onclick = "document.getElementById('modal').close()"
      )
    )
  )
}
