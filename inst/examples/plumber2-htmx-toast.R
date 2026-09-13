# A plumber2 API that toasts from the server with htmxr.
#
# The page route serves a Basecoat page with an empty toaster, an HTMX button
# that fetches a toast fragment, and a JavaScript button. The fragment route
# returns `bc_toast()` markup, which htmx appends into the toaster for the
# Toast script to mount.
#
# Run from package root with:
#
# plumber2::api("inst/examples/plumber2-htmx-toast.R") |>
#   htmxr::hx_serve_assets() |>
#   plumber2::api_run()
library(htmxr)
library(basecoat)

#* @get /
#* @serializer htmx
function() {
  hx_page(
    hx_head(
      title = "Basecoat toasts with htmxr",
      htmltools::renderDependencies(
        list(bc_deps(style = "lyra", js = TRUE, source = "cdn")),
        srcType = "href"
      )
    ),
    tags$main(
      class = "flex flex-col items-center gap-6 p-10",
      tags$h1(
        style = "font-size:1.5rem;font-weight:700;margin:0",
        "Toasts from the server"
      ),
      tags$p(
        style = "color:var(--muted-foreground);margin:0",
        "Backend toasts come from a plumber2 endpoint over htmx; front-end toasts come from JavaScript."
      ),
      bc_toast_trigger(
        "Toast from backend (with HTMX)",
        get = "/fragments/toast/success"
      ),
      tags$button(
        class = "btn",
        `data-variant` = "outline",
        onclick = "document.getElementById('toaster').toast({ category: 'info', title: 'From the front end', description: 'A toast called from JavaScript.' })",
        "Toast from front end"
      ),
      bc_toaster()
    )
  )
}

#* @get /fragments/toast/success
#* @serializer htmx
function() {
  bc_toast(
    "Success",
    description = "Your changes are in place.",
    category = "success",
    cancel = list(label = "Dismiss")
  )
}