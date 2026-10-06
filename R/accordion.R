#' Accordion
#'
#' Create a stack of collapsible sections.
#'
#' @param ... For `bc_accordion()`, items from [bc_accordion_item()]. A list
#'   is passed to [bc_accordion_item()] as its arguments. For
#'   `bc_accordion_item()`, the item's content.
#' @param id String. The ID. `bc_accordion()` uses a random ID by default.
#' @param multiple Bool. Allow more than one item open at a time. Defaults to
#'   `FALSE`, so opening one item closes the others.
#' @param class String. Extra CSS classes.
#' @return An htmltools tag.
#' @export
#' @examples
#' bc_accordion(
#'   bc_accordion_item("First section", "First section content.", open = TRUE),
#'   bc_accordion_item("Second section", "Second section content.")
#' )
bc_accordion <- function(..., id = NULL, multiple = FALSE, class = NULL) {
  check_bool(multiple)
  check_string(class, allow_null = TRUE, allow_empty = TRUE)

  if (is.null(id)) {
    id <- paste0(
      "accordion-",
      paste0(sample(1:9, 8, replace = TRUE), collapse = "")
    )
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
#' @param title String. The item's title, always visible.
#' @param open Bool. Whether the item starts open. Defaults to `FALSE`.
#' @param disabled Bool. Lock the item open or closed. Defaults to `FALSE`.
#' @param icon Tag. An icon to replace the default caret, such as one from the
#'   phosphoricons package.
#' @export
bc_accordion_item <- function(
  title,
  ...,
  open = FALSE,
  disabled = FALSE,
  id = NULL,
  icon = NULL
) {
  check_string(title, allow_empty = FALSE)
  check_bool(open)
  check_bool(disabled)
  check_string(id, allow_null = TRUE, allow_empty = FALSE)

  bc_tag(tags$details(
    id = id,
    open = if (open) NA,
    `aria-disabled` = if (disabled) "true",
    tags$summary(title, icon %||% bc_icon("caret-down")),
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
