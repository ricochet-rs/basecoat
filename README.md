

# basecoat

<!-- badges: start -->

[![R-CMD-check](https://github.com/ricochet-rs/basecoat/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ricochet-rs/basecoat/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

Bindings to the [basecoat UI](https://basecoatui.com/) component library
from R.

Basecoat is a pure tailwind css implementation of
[shadcn/ui](https://ui.shadcn.com/) that is the very same design system
that powers [ricochet.rs](https://ricochet.rs). Naturally, we’ve grown
quite fond of it.

## Installation

``` r
pak::pak("ricochet-rs/basecoat")
```

## Usage

`{basecoat}` is designed as an `htmltools` package that generates raw
HTML with *opt-in* shiny binding.

It works for creating HTML templates or with server-side-rendering (SSR)
with a framework like `{plumber2}` or `{ambiorix}` as well as an opt-in
[`{shiny}`]() integration.

## Examples:

Basecoat is a framework agnostic package. There

- [`{htmltools}` static html sidebar](./inst/examples/sidebar-app.R)
- [`{shiny}` sidebar layout app](./inst/examples/shiny-sidebar-app.R)
- [`{plumber2}` + {htmxr} for HTMX + Sever Side Rendered (SSR)
  website](./inst/examples/plumber2-htmx-basecoat.R)
- [`{nanonext}` SSR website](./inst/examples/nanonext.R)

## Page Layouts

To help create full page applications, two page layout helps are
shipped:

- `bc_page_navbar()`
- `bc_page_sidebar()`

## Shiny integration

{basecoat} ships an optional shiny integration.

<picture>
<source media="(prefers-color-scheme: dark)" srcset="images/shiny-app-dark.png"/>
<img src="images/shiny-app-light.png" alt="A Shiny app using bc_page_sidebar(), with basecoat inputs wired to input$"/>
</picture>

Open an example application file with:

``` r
tmp <- tempfile(fileext = ".R")
fp <- system.file("examples", "shiny-app.R", package = "basecoat")
file.copy(fp, tmp)

file.edit(tmp)
```

## Use with Shiny

Because `basecoat` is not a shiny-only package, it must be opted into.
Do this by calling `bc_shiny_deps()` inside your top level UI component
(or frankly anywhere in your UI).

``` r
ui <- bc_page_navbar(
  bc_shiny_deps()
)
```

## Custom themes

`bc_theme_builder()` can be used to launch a small html page to
customize your own theme. Alternatively, you can use the theme
customization in the [package
docs](https://ricochet-rs.github.io/basecoat/theme/index.html) to help

``` r
bc_theme_builder()
```

The theme builder can be used with any tweakcn theme.

Copy the example tweakcn theme and paste it into the “Import” button to
see how simple it is to cusotmize your theme.

``` r
clipr::write_clip(
  brio::read_file(
    system.file(
      "examples/tweakcn-theme.css",
      package = "basecoat"
    )
  )
)
```

<picture>
<source media="(prefers-color-scheme: dark)" srcset="images/ricochet-theme-dark.png"/>
<img src="images/ricochet-theme-light.png" alt="The theme builder on the ricochet style pack"/>
</picture>

<picture>
<source media="(prefers-color-scheme: dark)" srcset="images/random-theme-dark.png"/>
<img src="images/random-theme-light.png" alt="The same page after deriving a palette from a new primary colour"/>
</picture>

### Importing themes

Set your theme by using the `bc_deps()` function. For SSR or normal
htmltools usage, `bc_deps()` inside your top level UI component, for
example here, it is `bc_page_sidebar()`.

``` r
bc_page_sidebar(
  bc_deps(
    style = "lyra",
    theme = system.file(
      "examples/tweakcn-theme.css",
      package = "basecoat"
    )
  ),
  title = "Production",
  sidebar = bc_sidebar(id = "sidebar"),
  header = bc_theme_switcher(id = "switcher"),
  div(
    class = "max-w-sm p-4",
    bc_card(
      bc_card_header(
        htmltools::h2("Production deploy"),
        htmltools::p("v1.4.2, 3m 12s"),
        bc_card_action(bc_badge("passed"))
      ),
      bc_card_body("All 128 checks green."),
      bc_card_footer("Deployed just now.")
    )
  )
)
```
