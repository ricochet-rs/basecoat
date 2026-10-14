---
name: basecoat
description: Build web pages and Shiny apps in R with the basecoat package, which wraps the Basecoat UI (shadcn/ui in plain Tailwind CSS) as htmltools tags. Use when writing R code that calls bc_* functions, building static HTML pages, server-side rendered sites (plumber2, ambiorix, nanonext), htmx apps, or Shiny apps with basecoat components.
license: MIT
---

# basecoat

basecoat writes Basecoat UI components as htmltools tags. Every `bc_*()`
component returns a tag, so the same code works in a static page, a server
that returns HTML, an htmx fragment, or a Shiny UI.

## Rules that apply everywhere

- Use `bc_*()` components, never Bootstrap, bslib, or `shiny::*Input()`.
  Basecoat is Tailwind based and Bootstrap styles conflict with it.
- A page needs the stylesheet exactly once. Pick the loader for the setting:
  - static or htmltools page: `bc_deps()`
  - server that returns a string: `bc_page()`
  - Shiny: `bc_shiny_deps()` (it calls `bc_deps()` for you, so never add both)
- Components attach their own scripts. Only hand-written HTML needs
  `bc_deps(js = )`.
- Style packs are chosen with `style =`, one of `bc_styles` or `"base"`.
  A custom theme is a CSS file passed as `theme =`.
- Utility classes are limited to what the bundled CSS ships. Check that a
  Tailwind class exists in `system.file("basecoat", package = "basecoat")`
  before relying on it.
- Printing a component at the console shows it in the viewer with the
  stylesheet loaded.

## Page layouts

- `bc_page_sidebar(..., sidebar = bc_sidebar(), title, header)`: a
  collapsible sidebar beside the main content. Content in `...` is padded.
- `bc_page_navbar(..., title, nav = list(bc_nav_item()), end)`: a top bar.
- `bc_page(..., title, assets, style, theme, head)`: a whole document as a
  string, for servers that cannot return tags.

## Choose a reference

Read the reference that matches the task:

- `references/html.md`: static HTML pages and htmltools scaffolding.
- `references/ssr.md`: server-side rendering with plumber2, ambiorix, or
  nanonext.
- `references/htmx.md`: htmx fragments, partial swaps, and server toasts.
- `references/shiny.md`: Shiny apps, reading inputs, and updating them from
  the server.

Full examples ship with the package in
`system.file("examples", package = "basecoat")`.
