test_that("a single select with no placeholder starts on its first option", {
  html <- format(bc_select("apple", "pear", id = "fruit"))

  expect_match(html, '<input type="hidden" name="fruit" value="apple"/>', fixed = TRUE)
  expect_match(html, 'data-value="apple" aria-selected="true"', fixed = TRUE)
})

test_that("a placeholder or a multiple select starts empty", {
  expect_match(
    format(bc_select("apple", "pear", id = "fruit", placeholder = "Fruit")),
    'value=""',
    fixed = TRUE
  )
  expect_match(
    format(bc_select("apple", "pear", id = "fruit", multiple = TRUE)),
    'value="[]"',
    fixed = TRUE
  )
})

test_that("selected wins over the first option", {
  expect_match(
    format(bc_select("apple", "pear", id = "fruit", selected = "pear")),
    'value="pear"',
    fixed = TRUE
  )
})
