# A plumber2 API that toasts from the server with htmxr.
#
# Run with:
#
#   plumber2::api(
#     system.file("examples", "plumber2-htmx-toast.R", package = "basecoat")
#   ) |>
#     htmxr::hx_serve_assets() |>
#     plumber2::api_statics(
#       at = "/basecoat/",
#       path = system.file("basecoat", package = "basecoat")
#     ) |>
#     plumber2::api_run()
#
library(htmxr)
library(basecoat)

style <- "lyra"

#* @get /
#* @parser none
#* @serializer html
function() {
  hx_page(
    hx_head(
      title = "Basecoat toasts with htmxr",
      htmltools::renderDependencies(
        list(bc_deps(style = style, js = TRUE, source = "/basecoat/")),
        "href"
      )
    ),
    tags$main(
      class = "prose mx-auto flex max-w-2xl flex-col items-start gap-6 p-10",
      tags$h1("Toasts from the server"),
      tags$p(
        "Backend toasts come from a plumber2 endpoint over htmx.",
        "Front-end toasts come from JavaScript."
      ),
      bc_toast_trigger(
        "Toast from backend (with HTMX)",
        get = "/fragments/toast/success"
      ),
      bc_button(
        "Toast from front end",
        variant = "outline",
        onclick = paste0(
          "document.getElementById('toaster').toast({",
          "category: 'info', title: 'From the front end',",
          "description: 'A toast called from JavaScript.' })"
        )
      ),
      bc_toaster()
    )
  )
}

#* @get /fragments/toast/success
#* @parser none
#* @serializer html
function() {
  as.character(bc_toast(
    "Success",
    description = "Your changes are in place.",
    category = "success",
    cancel = list(label = "Dismiss")
  ))
}
