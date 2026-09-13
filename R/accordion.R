#' Accordion
#'
#' A vertically stacked set of collapsible sections built on native
#' `<details>` elements.
#'
#' @param ... Accordion items. Tags pass through and lists are passed to
#'   [bc_accordion_item()] with `title`, `content`, `open` and `disabled`.
#' @param id String. The ID for the accordion root.
#' @param multiple Bool. Allow more than one item open at a time. Off by
#'   default, so opening one item closes the others.
#' @param class String. Extra classes for the accordion root.
#' @return A `<section class="accordion">` of `<details>` items.
#' @details
#' The script enforces single-item behavior and stops disabled items from
#' toggling.
#' @export
#' @examples
#' bc_accordion(
#'   bc_accordion_item("First section", "First section content.", open = TRUE),
#'   bc_accordion_item("Second section", "Second section content.")
#' )
bc_accordion <- function(...,
                         id = NULL,
                         multiple = FALSE,
                         class = NULL) {
  check_bool(multiple)
  check_string(class, allow_null = TRUE, allow_empty = TRUE)

  if (is.null(id)) {
    id <- paste0("accordion-", paste0(sample(1:9, 8, replace = TRUE), collapse = ""))
  }

  bc_tag(htmltools::attachDependencies(
    tags$section(
      id = id,
      class = paste0("accordion", if (!is.null(class)) paste0(" ", class)),
      `data-multiple` = if (multiple) NA,
      accordion_items(list(...))
    ),
    bc_script_dep("accordion")
  ))
}

#' @rdname bc_accordion
#' @param title String. The item's trigger, always visible.
#' @param open Bool. Whether the item starts open.
#' @param disabled Bool. Whether the item can be toggled.
#' @export
bc_accordion_item <- function(title, ..., open = FALSE, disabled = FALSE, id = NULL) {
  check_string(title, allow_empty = FALSE)
  check_bool(open)
  check_bool(disabled)
  check_string(id, allow_null = TRUE, allow_empty = FALSE)

  bc_tag(tags$details(
    id = id,
    open = if (open) NA,
    `aria-disabled` = if (disabled) "true",
    tags$summary(title, accordion_lucide()),
    tags$section(...)
  ))
}

accordion_items <- function(items) {
  lapply(items, function(item) {
    if (inherits(item, "shiny.tag") || inherits(item, "shiny.tag.list")) {
      return(item)
    }
    if (is.list(item)) {
      return(do.call(bc_accordion_item, item))
    }
    bc_accordion_item(item, "")
  })
}

accordion_lucide <- function() {
  HTML(
    '<svg class="lucide lucide-chevron-down" xmlns="http://www.w3.org/2000/svg" width="24" ',
    'height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" ',
    'stroke-linecap="round" stroke-linejoin="round"><path d="m6 9 6 6 6-6" /></svg>'
  )
}