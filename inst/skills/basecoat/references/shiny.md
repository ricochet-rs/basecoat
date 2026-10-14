# Shiny

Put `bc_shiny_deps()` in the UI. It loads the stylesheet through `bc_deps()`
and adds the Shiny bindings, so do not also call `bc_deps()`. Pass `style` or
`theme` to it the same way.

```r
library(shiny)
library(basecoat)

ui <- bc_page_sidebar(
  bc_shiny_deps(style = "lyra"),
  title = "Settings",
  header = bc_theme_switcher(id = "theme"),
  sidebar = bc_sidebar(id = "sidebar"),
  bc_card(
    bc_card_header("Profile"),
    bc_card_body(
      class = "flex flex-col gap-4",
      bc_input(id = "name", label = "Name"),
      bc_select("utc", "est", "pst", id = "timezone"),
      bc_switch("notify", "Email notifications")
    ),
    bc_card_footer(bc_button("Save", id = "save"))
  ),
  bc_toaster()
)

server <- function(input, output, session) {
  observeEvent(input$save, {
    bc_show_toast(bc_toast("Saved", category = "success"))
  })
}

shinyApp(ui, server)
```

## Reading inputs

Every input is read as `input$<id>`. Components whose random default ID would
change on each render become inputs only when given an `id`: `bc_accordion()`,
`bc_tabs()`, `bc_sidebar()`, `bc_alert_dialog()`, `bc_drawer()`, and
`bc_dropdown_group()`.

| Component | `input$<id>` |
| --- | --- |
| `bc_button(id = )` | click count, an action button |
| `bc_checkbox()`, `bc_switch()`, `bc_dropdown_checkbox(id = )` | `TRUE` or `FALSE` |
| `bc_input()`, `bc_textarea()` | string; a number for `type = "number"`, a Date for `type = "date"` |
| `bc_native_select()`, `bc_radio_group()` | string |
| `bc_select()`, `bc_combobox()` | string, or a vector when `multiple = TRUE`; `NULL` when empty |
| `bc_slider()` | number |
| `bc_accordion()` | IDs, or titles, of the open items |
| `bc_tabs()` | label of the selected tab |
| `bc_dropdown_group()` | label of the checked `bc_dropdown_radio()` |
| `bc_dialog()`, `bc_alert_dialog()`, `bc_drawer()`, `bc_sidebar()` | `TRUE` while open |
| `bc_theme_switcher(id = )` | `"light"` or `"dark"` |
| `bc_command(id = "x")` | search text, read as `input$"x-input"` |

## Updating from the server

Shiny's own update functions work for:

- `updateCheckboxInput()`: `bc_checkbox()`, `bc_switch()`,
  `bc_dropdown_checkbox()`
- `updateTextInput()`: `bc_input()` of any type, `bc_command()` (its
  `"<id>-input"`)
- `updateTextAreaInput()`, `updateNumericInput()`
- `updateSelectInput()`: `bc_native_select()` and `bc_select()`, including
  new `choices`
- `updateActionButton()`: `bc_button()`
- `updateTabsetPanel()`: `bc_tabs()`
- `updateRadioButtons(selected = )`: `bc_dropdown_group()`

The rest have `bc_update_*()` functions:

- `bc_update_radio_group(id, value)`
- `bc_update_slider(id, value)`
- `bc_update_select(id, value)` and `bc_update_combobox(id, value)`
- `bc_update_accordion(id, open)`: items to open, others close
- `bc_update_dialog(id, open)`: `bc_dialog()`, `bc_alert_dialog()`,
  `bc_drawer()`
- `bc_update_sidebar(id, open)`
- `bc_update_theme_switcher(id, mode)`

## Alerts

- `bc_show_toast(bc_toast(...))` shows a toast. The page needs a
  `bc_toaster()`.
- For an inline `bc_alert()`, render it with `renderUI()` and `uiOutput()`.
- For a confirmation, give `bc_alert_dialog()` an `id` and open it with
  `bc_update_dialog(id, TRUE)`.

## Do not

- Do not use `shiny::showModal()`. It renders a Bootstrap modal, which
  basecoat does not style. Use `bc_dialog()` and `bc_update_dialog()`.
- Do not use `shiny::*Input()` or bslib components alongside basecoat.

See `shiny-inputs.R` in `system.file("examples", package = "basecoat")` for
every input read and updated.
