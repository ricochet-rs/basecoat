# Render every component through a style, one standalone page per style, and
# open an index. Each page attaches its own `bc_deps()` dependency, so this also
# proves the style argument reaches the `<head>`.
#
#   source(system.file("examples", "kitchen-sink.R", package = "basecoat"))
#
# Sourcing the file draws all eight packs and opens an index. Call it again for
# one pack, or for a pack under your own tokens:
#
#   kitchen_sink("rhea")
#   kitchen_sink("base")
#   kitchen_sink("vega", theme = "~/theme.css")
#
# tweakcn-theme.css sits beside this file, an unedited tweakcn export kept here
# so the claim that one works unedited stays honest:
#
#   kitchen_sink(
#     "vega",
#     theme = system.file("examples", "tweakcn-theme.css", package = "basecoat")
#   )

library(basecoat)
library(htmltools)
library(phosphoricons)

# One labelled row of examples. Layout is inline style, not Tailwind, so the
# only stylesheet in play is the Basecoat bundle under test.
demo_group <- function(title, ...) {
  tags$section(
    style = "display:flex;flex-direction:column;gap:.75rem",
    tags$h2(style = "font-size:1.1rem;font-weight:600;margin:0", title),
    tags$div(
      style = "display:flex;flex-wrap:wrap;gap:.5rem;align-items:center",
      ...
    )
  )
}

demo_sections <- function() {
  tagList(
    demo_group(
      "Buttons",
      bc_button("Primary"),
      bc_button("Secondary", variant = "secondary"),
      bc_button("Outline", variant = "outline"),
      bc_button("Ghost", variant = "ghost"),
      bc_button("Link", variant = "link"),
      bc_button("Destructive", variant = "destructive"),
      bc_button("Small", variant = "outline", size = "sm"),
      bc_button("Large", variant = "outline", size = "lg")
    ),
    demo_group(
      "Badges",
      bc_badge("Default"),
      bc_badge("Secondary", variant = "secondary"),
      bc_badge("Destructive", variant = "destructive"),
      bc_badge("Outline", variant = "outline"),
      bc_badge("Ghost", variant = "ghost")
    ),
    demo_group(
      "Alerts",
      bc_alert(
        h2("Heads up"),
        tags$section("You can add components to your app."),
        tags$footer(bc_button("Enable", variant = "outline", size = "xs"))
      ),
      bc_alert(
        h2("Payment failed"),
        tags$section("Check your card and try again."),
        variant = "destructive"
      )
    ),
    demo_group(
      "Avatars",
      bc_avatar(
        src = "https://github.com/shadcn.png",
        alt = "@shadcn",
        fallback = "CN"
      ),
      bc_avatar(fallback = "JP", size = "sm"),
      bc_avatar(fallback = "LG", size = "lg"),
      bc_avatar(
        fallback = "ER",
        badge = bc_avatar_badge(class = "bg-green-600")
      ),
      bc_avatar_group(
        bc_avatar(fallback = "CN"),
        bc_avatar(fallback = "LR"),
        bc_avatar(fallback = "ER"),
        count = "+3"
      )
    ),
    demo_group(
      "Inputs",
      bc_input(type = "email", placeholder = "Email"),
      bc_input(
        id = "email",
        label = "Email",
        type = "email",
        placeholder = "m@example.com",
        description = "Enter your email address."
      ),
      bc_input(
        id = "username",
        label = "Username",
        value = "hunvreus",
        required = TRUE
      ),
      bc_input(
        id = "disabled-email",
        type = "email",
        placeholder = "Email",
        disabled = TRUE
      ),
      bc_input(
        id = "invalid-email",
        type = "email",
        placeholder = "Email",
        invalid = TRUE
      )
    ),
    demo_group(
      "Fields",
      bc_field(
        tags$label(`for` = "f-name", "Full name"),
        tags$input(id = "f-name", placeholder = "Evil Rabbit"),
        tags$p("This appears on invoices and emails.")
      ),
      bc_field(
        tags$label(`for` = "f-username", "Username"),
        tags$input(id = "f-username", value = "MAX"),
        tags$p(
          id = "f-username-error",
          role = "alert",
          "Choose another username."
        ),
        invalid = TRUE
      ),
      bc_field(
        tags$input(id = "f-newsletter", type = "checkbox", role = "switch"),
        tags$label(`for` = "f-newsletter", "Subscribe to the newsletter"),
        orientation = "horizontal"
      ),
      bc_fieldset(
        legend = "Address Information",
        description = "We need your address to deliver your order.",
        bc_field(
          tags$label(`for` = "f-street", "Street"),
          tags$input(id = "f-street", type = "text", placeholder = "123 Main St")
        ),
        bc_field_group(
          bc_field(
            tags$label(`for` = "f-city", "City"),
            tags$input(id = "f-city", type = "text", placeholder = "New York")
          ),
          bc_field(
            tags$label(`for` = "f-zip", "Postal Code"),
            tags$input(id = "f-zip", type = "text", placeholder = "90502")
          )
        )
      ),
      bc_fieldset(
        legend = "Billing",
        bc_field(
          tags$label(`for` = "f-same-as-shipping", "Same as shipping address"),
          tags$input(id = "f-same-as-shipping", type = "checkbox", checked = NA),
          orientation = "horizontal"
        ),
        bc_field_separator(),
        bc_field(
          tags$label(`for` = "f-comments", "Comments"),
          tags$textarea(
            id = "f-comments",
            rows = "3",
            placeholder = "Add any additional comments"
          )
        )
      )
    ),
    demo_group(
      "Checkboxes",
      bc_checkbox("cb-terms", "Accept terms and conditions"),
      bc_checkbox(
        "cb-updates",
        "Email me updates",
        checked = TRUE,
        description = "Unsubscribe at any time."
      ),
      bc_checkbox("cb-disabled", "Disabled option", disabled = TRUE),
      bc_checkbox("cb-invalid", "Invalid option", invalid = TRUE)
    ),
    demo_group(
      "Combobox",
      bc_combobox(
        "framework",
        bc_combobox_option("Next.js"),
        bc_combobox_option("SvelteKit"),
        bc_combobox_option("Nuxt.js"),
        bc_combobox_option("Remix"),
        bc_combobox_option("Astro"),
        placeholder = "Select a framework",
        class = "w-60"
      ),
      bc_combobox(
        "timezone",
        bc_combobox_group(
          "Americas",
          bc_combobox_option("(GMT-5) New York"),
          bc_combobox_option("(GMT-8) Los Angeles"),
          bc_combobox_option("(GMT-6) Chicago")
        ),
        bc_combobox_separator(),
        bc_combobox_group(
          "Europe",
          bc_combobox_option("(GMT+0) London"),
          bc_combobox_option("(GMT+1) Paris"),
          bc_combobox_option("(GMT+1) Berlin")
        ),
        placeholder = "Select a timezone",
        selected = "(GMT+0) London"
      )
    ),
    demo_group(
      "Kbd",
      tags$span(
        style = "display:inline-flex;align-items:center;gap:.25rem",
        bc_kbd("⌘"),
        bc_kbd("⇧"),
        bc_kbd("⌥"),
        bc_kbd("⌃")
      ),
      tags$p(
        style = "font-size:.875rem;color:var(--muted-foreground);margin:0",
        "Use",
        tags$span(
          style = "display:inline-flex;align-items:center;gap:.25rem",
          bc_kbd("Ctrl"),
          tags$span("+"),
          bc_kbd("B")
        ),
        " and ",
        tags$span(
          style = "display:inline-flex;align-items:center;gap:.25rem",
          bc_kbd("Ctrl"),
          tags$span("+"),
          bc_kbd("K")
        ),
        " to open the command palette"
      ),
      bc_button(
        "Accept",
        bc_kbd("⏎", `data-icon` = "inline-end"),
        variant = "outline"
      ),
      div(
        class = "input-group",
        tags$input(type = "search", placeholder = "Search..."),
        tags$span(
          `data-align` = "start",
          `aria-hidden` = "true",
          ph("magnifying-glass", title = NULL)
        ),
        tags$span(
          style = "display:inline-flex;align-items:center;gap:.25rem",
          `data-align` = "end",
          bc_kbd("⌘"),
          bc_kbd("K")
        )
      )
    ),
    demo_group(
      "Sidebar",
      bc_sidebar(
        id = "sidebar-demo",
        bc_sidebar_group(
          "Components",
          bc_sidebar_item("Buttons", href = "#", aria_current = TRUE),
          bc_sidebar_item("Cards", href = "#"),
          bc_sidebar_submenu(
            "Layout",
            bc_sidebar_item("Sidebar", href = "#"),
            bc_sidebar_item("Tabs", href = "#")
          )
        ),
        bc_sidebar_separator(),
        bc_sidebar_group(
          "Account",
          bc_sidebar_item("Profile", href = "#"),
          bc_sidebar_item("Log out", href = "#")
        )
      ),
      tags$button(
        type = "button",
        class = "btn",
        `data-variant` = "outline",
        onclick = "document.getElementById('sidebar-demo')?.toggle()",
        "Toggle sidebar"
      )
    ),
    demo_group(
      "Card",
      bc_card(
        bc_card_header(
          h2("Production deploy"),
          p("v1.4.2, 3m 12s"),
          bc_card_action(bc_badge("passed", variant = "secondary"))
        ),
        bc_card_body(p("All 128 checks green.")),
        bc_card_footer(p("Deployed just now."))
      )
    ),
    demo_group(
      "Theme switcher",
      bc_theme_switcher()
    ),
    demo_group(
      "Progress",
      div(style = "width:16rem", bc_progress(66, label = "Upload progress"))
    ),
    demo_group(
      "Skeleton",
      bc_skeleton(style = "height:1rem;width:16rem"),
      bc_skeleton(style = "height:1rem;width:12rem")
    ),
    demo_group(
      "Tooltips",
      bc_tooltip("Hover me", text = "This is a tooltip"),
      bc_tooltip("Bottom", text = "Bottom tooltip", side = "bottom"),
      bc_tooltip("Left", text = "Left tooltip", side = "left", align = "start")
    ),
    demo_group(
      "Radio Groups",
      bc_radio_group(
        name = "view-density",
        bc_radio("default", "Default"),
        bc_radio("comfortable", "Comfortable", checked = TRUE),
        bc_radio("compact", "Compact")
      )
    ),
    demo_group(
      "Sliders",
      bc_slider(0, 100, 50),
      bc_slider(
        min = 0,
        max = 100,
        value = 50,
        label = "Temperature",
        description = "Adjust the temperature setting"
      ),
      bc_slider(0, 100, 50, disabled = TRUE)
    ),
    demo_group(
      "Tabs",
      bc_tabs(
        bc_tab("Account details", label = "Account"),
        bc_tab("Password settings", label = "Password")
      )
    ),
    demo_group(
      "Select",
      bc_select(
        "Apple",
        "Banana",
        "Blueberry",
        placeholder = "Select a fruit"
      )
    ),
    demo_group(
      "Dropdown Menu",
      bc_dropdown_menu(
        bc_dropdown_group(
          "My Account",
          bc_dropdown_item("Profile", shortcut = "CmdP"),
          bc_dropdown_item("Settings", shortcut = "CmdS")
        ),
        bc_dropdown_separator(),
        bc_dropdown_item("Team"),
        bc_dropdown_separator(),
        bc_dropdown_item("Log out", variant = "destructive")
      )
    ),
    demo_group(
      "Popover",
      bc_popover(
        tags$header(
          tags$h4(style = "margin:0", "Dimensions"),
          p(style = "margin:0", "Set the dimensions for the layer.")
        ),
        trigger_label = "Open popover"
      )
    ),
    demo_group(
      "Command",
      bc_command(
        bc_command_group(
          "Suggestions",
          "Calendar",
          "Search Emoji",
          bc_command_item("Calculator", disabled = TRUE)
        ),
        bc_command_separator(),
        bc_command_group(
          "Settings",
          bc_command_item("Profile", shortcut = "CmdP"),
          bc_command_item("Billing", shortcut = "CmdB")
        )
      )
    ),
    demo_group(
      "Accordion",
      bc_accordion(
        bc_accordion_item(
          "What are your shipping options?",
          "We offer standard (5-7 days), express (2-3 days) and overnight shipping.",
          open = TRUE
        ),
        bc_accordion_item(
          "What is your return policy?",
          "You can return items within 30 days of delivery."
        ),
        bc_accordion_item(
          "How can I contact customer support?",
          "Email support@example.com or use live chat during business hours."
        )
      )
    ),
    demo_group(
      "Drawer",
      bc_drawer(
        "Use this panel for content that needs the full viewport width.",
        title = "Move Goal",
        description = "Set your daily activity goal.",
        actions = tagList(
          tags$button(
            class = "btn",
            onclick = "this.closest('dialog').close()",
            "Submit"
          ),
          tags$button(
            class = "btn",
            `data-variant` = "outline",
            onclick = "this.closest('dialog').close()",
            "Cancel"
          )
        )
      )
    ),
    demo_group(
      "Toast",
      bc_toaster(
        bc_toast(
          "Saved",
          description = "Your changes are in place.",
          category = "success",
          cancel = list(label = "Dismiss")
        ),
        bc_toast(
          "Warning",
          description = "You are close to your storage limit.",
          category = "warning",
          action = list(label = "Upgrade")
        ),
        tags$button(
          class = "btn",
          `data-variant` = "outline",
          onclick = "document.getElementById('toaster').toast({ category: 'info', title: 'From the front end', description: 'A toast called from JavaScript.' })",
          "Toast from front end"
        ),
        bc_toast_trigger(
          "Toast from backend (with HTMX)",
          get = "/fragments/toast/success"
        )
      )
    ),
    demo_group(
      "Switch",
      bc_switch("sw-airplane", "Airplane Mode"),
      bc_switch(
        "sw-focus",
        "Share across devices",
        checked = TRUE,
        description = "Focus is shared across devices."
      ),
      bc_switch("sw-disabled", "Disabled option", disabled = TRUE),
      bc_switch("sw-invalid", "Invalid option", invalid = TRUE),
      bc_switch("sw-small", "Small switch", size = "sm")
    ),
    demo_group(
      "Textareas",
      bc_textarea(placeholder = "Type your message here"),
      bc_textarea(
        id = "ta-message",
        label = "Message",
        placeholder = "Type your message here",
        description = "Write a short message."
      ),
      bc_textarea(placeholder = "Disabled", disabled = TRUE),
      bc_textarea(placeholder = "Invalid", invalid = TRUE)
    ),
    demo_group(
      "Spinners",
      bc_spinner(size = "3"),
      bc_spinner(size = "4"),
      bc_spinner(size = "6"),
      bc_spinner(size = "8"),
      bc_button(bc_spinner(), "Loading...", size = "sm", disabled = TRUE),
      bc_badge(bc_spinner(), "Syncing"),
      bc_empty(
        title = "Processing your request",
        description = "Please wait, do not refresh the page.",
        icon = bc_spinner(),
        actions = bc_button("Cancel", variant = "outline", size = "sm")
      )
    ),
    demo_group(
      "Native Selects",
      bc_native_select(
        bc_native_select_option("Apple", value = "apple"),
        bc_native_select_option("Banana", value = "banana"),
        bc_native_select_option("Blueberry", value = "blueberry"),
        aria_label = "Fruit",
        placeholder = "Select a fruit"
      ),
      bc_native_select(
        bc_native_select_group(
          "Vegetables",
          bc_native_select_option("Carrot", value = "carrot"),
          bc_native_select_option("Potato", value = "potato")
        ),
        id = "ns-food",
        label = "Food",
        placeholder = "Select a food"
      ),
      bc_native_select(
        bc_native_select_option("Apple", value = "apple"),
        aria_label = "Disabled fruit",
        placeholder = "Select a fruit",
        disabled = TRUE
      )
    ),
    demo_group(
      "Pagination",
      bc_pagination(
        bc_pagination_previous(),
        bc_pagination_item("1", href = "#"),
        bc_pagination_item("2", href = "#", current = TRUE),
        bc_pagination_item("3", href = "#"),
        bc_pagination_ellipsis(),
        bc_pagination_next()
      )
    ),
    demo_group(
      "Scroll Areas",
      bc_scroll_area(
        tags$p(style = "margin:0;white-space:nowrap", "v1.2.0-beta.50"),
        tags$p(style = "margin:0;white-space:nowrap", "v1.2.0-beta.49"),
        tags$p(style = "margin:0;white-space:nowrap", "v1.2.0-beta.48"),
        tags$p(style = "margin:0;white-space:nowrap", "v1.2.0-beta.47"),
        class = "h-32"
      )
    ),
    demo_group(
      "Labels",
      bc_label("Your email address", `for` = "label-email"),
      bc_input(
        id = "label-email",
        type = "email",
        placeholder = "name@example.com"
      ),
      bc_label(
        "Accept terms and conditions",
        class = "gap-2",
        tags$input(type = "checkbox", class = "input")
      )
    ),
    demo_group(
      "Items",
      bc_item(
        tags$section(
          tags$h3("Basic Item"),
          p("A simple item with title and description.")
        ),
        tags$aside(bc_button("Action", variant = "outline", size = "sm")),
        variant = "outline"
      ),
      bc_item(
        tags$section(tags$h3("Visit our documentation"), p("Get started.")),
        tags$aside(span("2 min read")),
        href = "#"
      ),
      bc_item(
        tags$section(tags$h3("Muted Variant"), p("Muted background.")),
        variant = "muted"
      )
    ),
    demo_group(
      "Input Groups",
      bc_input_group(
        tags$input(type = "text", placeholder = "Search..."),
        bc_input_group_addon("Ctrl K", align = "start"),
        bc_input_group_addon("12 results", align = "end")
      ),
      bc_input_group(
        tags$input(type = "text", placeholder = "0.00"),
        bc_input_group_addon("$", align = "start"),
        bc_input_group_addon("USD", align = "end")
      ),
      bc_input_group(
        tags$textarea(placeholder = "Enter your message"),
        tags$footer(
          `data-align` = "end",
          span("120 characters left")
        ),
        orientation = "vertical"
      )
    ),
    demo_group(
      "Empty States",
      bc_empty(
        title = "No Projects Yet",
        description = "Create your first project to get started.",
        actions = tagList(
          bc_button("Create Project"),
          bc_button("Import Project", variant = "outline")
        )
      ),
      bc_empty(
        title = "Cloud Storage Empty",
        description = "Upload files to access them anywhere.",
        actions = bc_button("Upload Files", variant = "outline", size = "sm"),
        class = "border border-dashed"
      )
    ),
    demo_group(
      "Button Groups",
      bc_button_group(
        bc_button("Archive", variant = "outline"),
        bc_button("Report", variant = "outline"),
        aria_label = "Message actions"
      ),
      bc_button_group(
        bc_button("Copy", variant = "secondary", size = "sm"),
        bc_button_group_separator(),
        bc_button("Paste", variant = "secondary", size = "sm")
      ),
      bc_button_group(
        bc_button("Zoom in", variant = "outline", size = "icon"),
        bc_button_group_separator(),
        bc_button("Zoom out", variant = "outline", size = "icon"),
        orientation = "vertical"
      )
    ),
    demo_group(
      "Breadcrumbs",
      bc_breadcrumb(
        bc_breadcrumb_item("Home", href = "#"),
        bc_breadcrumb_item("Components", href = "#"),
        bc_breadcrumb_item("Breadcrumb", current = TRUE)
      ),
      bc_breadcrumb(
        bc_breadcrumb_item("Home", href = "#"),
        bc_breadcrumb_item("Components", href = "#"),
        bc_breadcrumb_item("Breadcrumb", current = TRUE),
        separator = "dot"
      )
    ),
    demo_group(
      "Alert Dialogs",
      bc_alert_dialog(
        title = "Are you absolutely sure?",
        description = "This action cannot be undone.",
        trigger = "Show Dialog"
      ),
      bc_alert_dialog(
        title = "Delete this chat?",
        description = "This action cannot be undone.",
        confirm = list(label = "Delete", variant = "destructive"),
        trigger = "Delete Chat"
      ),
      bc_alert_dialog(
        title = "Invite team members?",
        description = "Send an invitation link to your teammates.",
        size = "sm",
        trigger = "Invite Members"
      )
    )
  )
}

# `save_html()` builds the document and renders the attached `bc_deps()`
# dependency into its `<head>`. It gives a bare `<body>` with only a background,
# so the padding, font and text colour ride on an inner wrapper. The theme
# switcher attaches its icon-swap utilities itself.
demo_page <- function(style, theme = NULL) {
  body <- tags$div(
    style = paste(
      "max-width:48rem;margin:0 auto;padding:2.5rem",
      "font-family:system-ui,sans-serif;color:var(--foreground)",
      "display:flex;flex-direction:column;gap:2.5rem",
      sep = ";"
    ),
    tags$h1(
      style = "font-size:1.5rem;font-weight:700;margin:0",
      paste0("Style pack: ", style)
    ),
    demo_sections()
  )

  attachDependencies(body, bc_deps(style = style, theme = theme))
}

write_page <- function(page, file, background = "var(--background)") {
  htmltools::save_html(page, file, background = background)
}

kitchen_sink <- function(styles = bc_styles, theme = NULL) {
  styles <- rlang::arg_match(styles, c("base", bc_styles), multiple = TRUE)

  dir <- tempfile("basecoat-kitchen-")
  dir.create(dir)

  files <- file.path(dir, paste0(styles, ".html"))
  Map(
    function(style, file) write_page(demo_page(style, theme), file),
    styles,
    files
  )

  target <- if (length(styles) == 1) {
    files[[1]]
  } else {
    index <- file.path(dir, "index.html")
    links <- lapply(styles, function(s) {
      tags$li(tags$a(href = paste0(s, ".html"), s))
    })
    write_page(
      tags$div(
        style = "font-family:system-ui,sans-serif;padding:2rem",
        tags$h1("basecoat style packs"),
        tags$ul(links)
      ),
      index,
      background = "white"
    )
    index
  }

  utils::browseURL(target)
  invisible(dir)
}

kitchen_sink()
