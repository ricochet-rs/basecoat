# Static HTML with htmltools

Build the page from `bc_*()` tags and attach the stylesheet with `bc_deps()`.

```r
library(basecoat)
library(htmltools)

page <- bc_page_sidebar(
  bc_deps(style = "vega"),
  title = "Dashboard",
  header = bc_theme_switcher(),
  sidebar = bc_sidebar(
    id = "nav",
    bc_sidebar_group(
      "Reports",
      bc_sidebar_item("Daily", href = "#", aria_current = TRUE),
      bc_sidebar_item("Weekly", href = "#")
    )
  ),
  bc_card(
    bc_card_header("Production deploy", tags$p("v1.4.2, 3m 12s")),
    bc_card_body("All 128 checks green."),
    bc_card_footer(bc_button("View logs"))
  )
)

save_html(page, "index.html", background = "var(--background)")
```

## Notes

- `bc_deps()` goes anywhere in the tag tree, usually as the first argument of
  the page layout. Call it once per page.
- `bc_deps(theme = "theme.css")` loads a custom theme after the style pack.
  `bc_theme_builder()` makes one, and tweakcn themes work as they are.
- Web fonts named in a theme must be imported manually.
- `bc_card_header()` takes the title first and wraps it in an `h2`; anything
  after it goes in the header.
- Wrap free text in a container with the `prose` class to get headings,
  paragraphs, and lists with vertical rhythm.
- Use `bc_dialog_trigger()`, `bc_toast_trigger()`, and the `trigger` argument
  of `bc_drawer()` and `bc_alert_dialog()` to open overlays without writing
  JavaScript.
- `bc_command()` items outside `bc_command_group()` are grouped for you.
- Cards clip their overflow, so place dropdowns where the menu has room to
  open inside the card.

See `system.file("examples", "sidebar-app.R", package = "basecoat")`.
