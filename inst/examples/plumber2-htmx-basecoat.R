# A plumber2 API serving Basecoat components over htmx.
#
# Run with:
#
# plumber2::api(
#   system.file("examples", "plumber2-htmx-basecoat.R", package = "basecoat")
# ) |>
#   htmxr::hx_serve_assets() |>
#   plumber2::api_statics(
#     at = "/basecoat/",
#     path = system.file("basecoat", package = "basecoat")
#   ) |>
#   plumber2::api_run()
library(htmxr)
library(basecoat)

style <- "lyra"

htmx <- htmltools::tags$script(
  src = "/htmxr/assets/htmx/2.0.8/htmx.min.js",
  defer = NA
)

#* @get /
#* @parser none
#* @serializer html
function() {
  bc_page(
    title = "Basecoat with htmxr",
    style = style,
    head = htmx,
    tags$main(
      class = "prose mx-auto flex max-w-2xl flex-col gap-6 p-10",
      tags$h1("Basecoat components with htmxr"),
      tags$p(
        "Every component here is markup this package writes, wired to a",
        "plumber2 route over htmx."
      ),
      bc_card(
        bc_card_header(
          tags$h2("Sign up"),
          tags$p("Posts to /signup and swaps the reply in below.")
        ),
        bc_card_body(
          tags$form(
            class = "flex flex-col gap-4",
            bc_input(
              id = "name",
              label = "Name",
              placeholder = "Ada Lovelace"
            ),
            bc_input(
              id = "email",
              label = "Email",
              type = "email",
              placeholder = "ada@example.com"
            ),
            hx_button(
              "signup",
              "Sign up",
              class = "btn",
              post = "/signup",
              target = "#signup-reply",
              swap = "innerHTML"
            )
          )
        ),
        bc_card_footer(tags$div(id = "signup-reply"))
      ),
      bc_toast_trigger("Toast from the server", get = "/fragments/toast"),
      bc_toaster()
    )
  )
}

#* @post /signup
#* @serializer html
function(name = "", email = "") {
  if (!nzchar(name) || !nzchar(email)) {
    return(as.character(bc_alert(
      title = "Missing details",
      description = "Both a name and an email are needed.",
      variant = "destructive"
    )))
  }

  as.character(bc_alert(
    title = paste("Welcome,", name),
    description = paste("A confirmation is on its way to", email)
  ))
}

#* @get /fragments/toast
#* @parser none
#* @serializer html
function() {
  as.character(bc_toast(
    "Saved",
    description = "The server sent this toast.",
    category = "success",
    cancel = list(label = "Dismiss")
  ))
}
