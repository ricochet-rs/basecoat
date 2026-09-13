test_that("components carry the class that makes printing render them", {
  components <- list(
    bc_accordion(bc_accordion_item("One", "Body")),
    bc_alert("Heads up"),
    bc_alert_dialog(title = "Sure?"),
    bc_avatar(fallback = "JP"),
    bc_badge("new"),
    bc_breadcrumb(bc_breadcrumb_item("Home", href = "#")),
    bc_button("Save"),
    bc_button_group(bc_button("Copy")),
    bc_card(bc_card_body("Body")),
    bc_checkbox("terms", "Accept"),
    bc_combobox("frameworks", bc_combobox_option("Shiny")),
    bc_command(bc_command_item("Search")),
    bc_dialog("confirm", title = "Sure?"),
    bc_drawer("Body", title = "Filters"),
    bc_dropdown_menu(bc_dropdown_item("Profile")),
    bc_empty(title = "Nothing here"),
    bc_field(bc_label("Email")),
    bc_input(id = "email", label = "Email"),
    bc_input_group(bc_input()),
    bc_item(bc_card_body("Body")),
    bc_kbd("K"),
    bc_label("Email"),
    bc_native_select(aria_label = "Pick one"),
    bc_pagination(bc_pagination_item("1")),
    bc_popover("Body"),
    bc_progress(50),
    bc_radio("one", "One"),
    bc_radio_group(bc_radio("one", "One"), name = "pick"),
    bc_scroll_area("Body"),
    bc_select(),
    bc_sidebar(bc_sidebar_group("Main", bc_sidebar_item("Home"))),
    bc_skeleton(),
    bc_slider(0, 10, 5),
    bc_spinner(),
    bc_switch("live", "Live"),
    bc_tabs(bc_tab("Body", label = "One")),
    bc_textarea(id = "bio", label = "Bio"),
    bc_theme_switcher(),
    bc_toast("Saved"),
    bc_toaster(),
    bc_tooltip("Hover", text = "Tip")
  )

  for (component in components) {
    expect_s3_class(component, "bc_tag")
  }
})

test_that("a component still renders as the tag it was", {
  expect_true(grepl('class="badge"', format(bc_badge("stable")), fixed = TRUE))
  expect_s3_class(bc_badge("stable"), "shiny.tag")
  expect_s3_class(
    bc_alert_dialog(title = "Sure?", trigger = "Open"),
    "shiny.tag.list"
  )
})

test_that("the class survives composition without duplicating", {
  nested <- bc_card(bc_card_body(bc_badge("stable")))

  expect_identical(sum(class(nested) == "bc_tag"), 1L)
  expect_identical(class(bc_tag(bc_badge("stable"))), class(bc_badge("stable")))
})

test_that("printing without a viewer writes the HTML", {
  expect_output(print(bc_badge("stable"), browse = FALSE), "badge")
})

test_that("the dependency is not baked into the component", {
  expect_null(htmltools::htmlDependencies(bc_badge("stable")))
})
