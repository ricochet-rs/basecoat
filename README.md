

<!-- README.md is generated from README.qmd. Run `just readme` to rebuild it. -->

# basecoat

<!-- badges: start -->

<!-- badges: end -->

[Basecoat](https://basecoatui.com) is [shadcn/ui](https://ui.shadcn.com)
rebuilt in plain CSS, with no React and no build step. This package
writes its markup with `htmltools` tags and ships the stylesheet and
scripts inside the package, so a page needs no network access.

It suits any R stack that emits HTML: Shiny, plumber2, htmxr, R
Markdown, Quarto, or a `save_html()` file on disk.

## Installation

``` r
pak::pak("JosiahParry/basecoat")
```

## Components

Every component is a function returning a tag.

``` r
library(basecoat)

cat(format(bc_button("Deploy", variant = "outline")))
#> <button type="button" class="btn" data-variant="outline">Deploy</button>
```

Printing one at the console opens it in the viewer instead, with the
stylesheet and scripts attached. Nothing is baked into the tag itself,
so components compose without accumulating copies of the dependency.

``` r
bc_card(
  bc_card_header(
    htmltools::h2("Production deploy"),
    htmltools::p("v1.4.2, 3m 12s"),
    bc_card_action(bc_badge("passed"))
  ),
  bc_card_body(htmltools::p("All 128 checks green.")),
  bc_card_footer(bc_button("Audit", variant = "ghost", size = "sm"))
)
```

Form controls build their own `field` wrapper when given a label.

``` r
bc_input(
  id = "email",
  label = "Email",
  type = "email",
  placeholder = "you@example.com",
  description = "We only use this to reach you about the run."
)
```

## Putting it on a page

`bc_deps()` returns the stylesheet and scripts as an
`htmltools::htmlDependency()`. Attach it once per page and it lands in
the `<head>`, de-duplicated across the render.

``` r
library(htmltools)

page <- tags$main(
  bc_button("Deploy"),
  bc_toaster()
)

save_html(attachDependencies(page, bc_deps()), "index.html")
```

In Shiny, return it in the UI:

``` r
ui <- tagList(
  bc_deps(),
  bc_card(bc_card_body("Hello"))
)
```

Eleven components need JavaScript. `js = TRUE` loads all of them; name
the ones you use to load less.

``` r
bc_deps(style = "maia", js = c("select", "toast"))
```

## Examples

Runnable examples ship with the package. Each is standalone and draws
its own page when sourced.

``` r
# Every component, once per style pack, with an index.
source(system.file("examples", "kitchen-sink.R", package = "basecoat"))

# An app shell: collapsible sidebar, toolbar, content.
source(system.file("examples", "sidebar-app.R", package = "basecoat"))
```

Both define a function you can call again for one pack, or under your
own tokens.

``` r
kitchen_sink("rhea")
sidebar_app("nova", theme = "theme.css")
```

## Style packs

Basecoat ships eight style packs, and all eight are bundled here.

`vega`, `nova`, `maia`, `lyra`, `mira`, `luma`, `sera`, `rhea`

`style = "base"` is the styleless layer: tokens and component structure
with no visual decisions at all. It is where you start when writing a
pack of your own, not a way to theme an existing one.

## Theming

Point `theme` at a CSS file and it loads after the style pack, so its
tokens win. Basecoat reads shadcn/ui token names, which means a
[tweakcn](https://tweakcn.com) export works unedited.

``` r
bc_deps(style = "vega", theme = "theme.css")
```

``` css
/* theme.css */
:root {
  --primary: oklch(0.5106 0.2301 276.9656);
  --radius: 0.25rem;
}

.dark {
  --primary: oklch(0.6801 0.1583 276.9349);
}
```

Only the `:root` and `.dark` blocks of such a file reach the browser.
`@import "tailwindcss"`, `@custom-variant`, `@theme inline` and
`@layer base` are Tailwind build syntax, and a browser ignores them.
Nothing is lost: the bundled stylesheet already maps `--color-primary`
to `--primary` and already paints the page background, so those blocks
would only restate what is there. See `?bc_theme` for the two things
they do carry that you have to restate, namely web fonts and letter
spacing.

`bc_theme_switcher()` writes a button that toggles the `dark` class,
which is what the `.dark` block hangs off.

## Why the assets are bundled

Basecoat is authored for Tailwind, and its published stylesheets carry
only the utilities Basecoat’s own source happens to use. Several
components are documented in plain Tailwind, so served from those files
a pagination row does not lay out and a spinner does not turn.

The stylesheets here are this package’s own Tailwind build, run against
the markup these functions write. That is why `source = "local"` is the
default, and why adding a utility class to a component means rebuilding
with `just vendor`.

## License

MIT. The bundled `basecoat-css` and Tailwind CSS are MIT as well; see
`LICENSE.note`.
