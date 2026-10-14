test_that("items outside a group are gathered into one", {
  menu <- bc_command(
    bc_command_item("Calendar"),
    bc_command_item("Settings"),
    bc_command_separator(),
    bc_command_group("Help", bc_command_item("Docs")),
    id = "palette"
  )$children[[2]]

  roles <- vapply(menu$children[[1]], function(x) x$attribs$role, character(1))
  expect_identical(roles, c("group", "separator", "group"))
})
