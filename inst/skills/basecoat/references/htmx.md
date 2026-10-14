# htmx

Render the page with `bc_page()` (see `ssr.md`), load htmx through `head`,
and return component fragments from the routes htmx calls.

```r
library(basecoat)
library(htmltools)
library(htmxr)

htmx <- htmltools::tags$script(
  src = "/htmxr/assets/htmx/2.0.8/htmx.min.js",
  defer = NA
)

#* @get /
#* @parser none
#* @serializer html
function() {
  bc_page(
    title = "Sign up",
    head = htmx,
    tags$main(
      class = "mx-auto flex max-w-2xl flex-col gap-6 p-10",
      tags$form(
        bc_input(id = "name", label = "Name"),
        hx_button(
          "signup",
          "Sign up",
          class = "btn",
          post = "/signup",
          target = "#reply",
          swap = "innerHTML"
        )
      ),
      tags$div(id = "reply"),
      bc_toast_trigger("Toast from the server", get = "/fragments/toast"),
      bc_toaster()
    )
  )
}

#* @post /signup
#* @serializer html
function(name = "") {
  as.character(bc_alert(title = paste("Welcome,", name)))
}

#* @get /fragments/toast
#* @parser none
#* @serializer html
function() {
  as.character(bc_toast("Saved", category = "success"))
}
```

Serve htmx and the basecoat assets alongside the API:

```r
plumber2::api("api.R") |>
  htmxr::hx_serve_assets() |>
  plumber2::api_statics(
    at = "/basecoat/",
    path = system.file("basecoat", package = "basecoat")
  ) |>
  plumber2::api_run()
```

## Notes

- Fragments are `as.character(component)`, not a full page.
- Swapped-in components set themselves up, so a swapped select, dropdown, or
  toast works without extra code.
- `bc_toast_trigger(get = )` fetches a toast from a route and shows it in the
  `bc_toaster()`.
- After an htmx history restore, content comes back already set up. Add
  `bc_init(force = TRUE)` to rebuild it.
- Use `class = "btn"` on htmxr buttons to style them as basecoat buttons.

See `plumber2-htmx-basecoat.R` and `plumber2-htmx-toast.R` in
`system.file("examples", package = "basecoat")`.
