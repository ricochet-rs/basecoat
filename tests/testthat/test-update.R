mock_session <- function() {
  sent <- NULL
  list(
    sendInputMessage = function(id, message) {
      sent <<- list(id = id, message = message)
    },
    sent = function() sent
  )
}

test_that("updates send the value to the input", {
  session <- mock_session()

  bc_update_radio_group("plan", "yearly", session = session)
  expect_identical(session$sent(), list(id = "plan", message = list(value = "yearly")))

  bc_update_slider("volume", 40, session = session)
  expect_identical(session$sent()$message, list(value = 40))

  bc_update_select("fruit", c("apple", "pear"), session = session)
  expect_identical(session$sent()$message, list(value = c("apple", "pear")))

  bc_update_combobox("framework", "shiny", session = session)
  expect_identical(session$sent()$message, list(value = "shiny"))

  bc_update_accordion("faq", character(0), session = session)
  expect_identical(session$sent()$message, list(open = character(0)))
})

test_that("updates outside a session error", {
  expect_error(bc_update_slider("volume", 40, session = NULL), "Shiny")
})

test_that("only an accordion given an id is a Shiny input", {
  expect_match(
    format(bc_accordion(bc_accordion_item("Billing", "Body"), id = "faq")),
    "data-input",
    fixed = TRUE
  )
  expect_no_match(
    format(bc_accordion(bc_accordion_item("Billing", "Body"))),
    "data-input",
    fixed = TRUE
  )
})

test_that("accordion items are named by id, then title", {
  expect_match(
    format(bc_accordion_item("Billing", "Body")),
    'data-value="Billing"',
    fixed = TRUE
  )
  expect_match(
    format(bc_accordion_item("Billing", "Body", id = "billing")),
    'data-value="billing"',
    fixed = TRUE
  )
})

test_that("bc_shiny_deps() loads bc_deps() with the bindings", {
  names <- vapply(bc_shiny_deps(), `[[`, character(1), "name")
  expect_identical(names, c("basecoat", "basecoat-shiny"))

  css <- tempfile(fileext = ".css")
  writeLines(":root { --primary: red; }", css)
  expect_length(bc_shiny_deps(theme = css), 3)
})

test_that("a button with an id is an action button", {
  html <- format(bc_button("Save", id = "save"))
  expect_match(html, 'class="btn action-button"', fixed = TRUE)
  expect_match(html, '<span class="action-label">Save</span>', fixed = TRUE)

  expect_no_match(format(bc_button("Save")), "action-button", fixed = TRUE)
})

test_that("the theme switcher updates with light or dark", {
  session <- mock_session()
  bc_update_theme_switcher("theme", "dark", session = session)
  expect_identical(session$sent()$message, list(value = "dark"))
  expect_error(bc_update_theme_switcher("theme", "blue", session = session))
})
