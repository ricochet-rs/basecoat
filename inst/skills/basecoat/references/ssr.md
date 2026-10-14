# Server-side rendering

For servers that send HTML text, build the whole document with `bc_page()`
and serve the bundled assets yourself.

1. Serve `system.file("basecoat", package = "basecoat")` at a URL, by default
   `/basecoat/`.
2. Return `bc_page(...)` from the route. It writes the stylesheet and the
   scripts the components need, pointing at `assets`.

## plumber2

```r
# api.R
library(basecoat)
library(htmltools)

#* @get /
#* @parser none
#* @serializer html
function() {
  bc_page(
    title = "Home",
    style = "lyra",
    tags$main(
      class = "prose mx-auto max-w-2xl p-10",
      tags$h1("Hello"),
      bc_button("Save")
    )
  )
}
```

```r
plumber2::api("api.R") |>
  plumber2::api_statics(
    at = "/basecoat/",
    path = system.file("basecoat", package = "basecoat")
  ) |>
  plumber2::api_run()
```

## Notes

- `assets` must match where the files are served. Change both together.
- `theme = "theme.css"` inlines the theme into the page, so it does not need
  to be served.
- `head = ` adds extra tags to the document head, such as the htmx script.
- A route that returns a fragment rather than a page returns
  `as.character(component)`.
- If the page is built with tags rather than `bc_page()`, use
  `bc_deps(source = "/basecoat/")` so the dependency points at the served
  copy.

See `plumber2-htmx-basecoat.R` and `nanonext.R` in
`system.file("examples", package = "basecoat")`.
