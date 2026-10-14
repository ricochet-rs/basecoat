test_that("two groups can offer the same values", {
  html <- format(htmltools::tagList(
    bc_radio_group(name = "newsletter", bc_radio("yes", "Yes")),
    bc_radio_group(
      name = "terms",
      bc_radio("yes", "Yes", description = "I agree.")
    )
  ))

  expect_match(html, 'id="newsletter-yes"', fixed = TRUE)
  expect_match(html, 'for="newsletter-yes"', fixed = TRUE)
  expect_match(html, 'id="terms-yes"', fixed = TRUE)
  expect_match(html, 'for="terms-yes"', fixed = TRUE)
  expect_match(html, 'aria-describedby="terms-yes-description"', fixed = TRUE)
  expect_match(html, 'id="terms-yes-description"', fixed = TRUE)
  expect_no_match(html, 'id="yes"', fixed = TRUE)
  expect_match(html, 'value="yes"', fixed = TRUE)
})
