#' Tooltip
#'
#' A tooltip component using Basecoat CSS.
#'
#' @param ... Tag attributes and children for the element with tooltip.
#' @param text String. The tooltip text.
#' @param side String. Position of the tooltip. One of `top`, `bottom`, `left`,
#'   `right`, `inline-start`, or `inline-end`. Defaults to `top`.
#' @param align String. Alignment of the tooltip. One of `start`, `center`, or
#'   `end`. Defaults to `center`.
#' @return An HTML element with tooltip attributes.
#' @export
#' @examples
#' bc_tooltip("Save", text = "Save your work")
#'
#' bc_tooltip("Info", text = "Additional information", side = "bottom")
bc_tooltip <- function(..., text, side = "top", align = "center") {
  check_string(text, allow_empty = FALSE)
  side <- arg_match(side, c("top", "bottom", "left", "right", "inline-start", "inline-end"))
  align <- arg_match(align, c("start", "center", "end"))

  bc_tag(tags$span(
    `data-tooltip` = text,
    `data-side` = side,
    `data-align` = align,
    ...
  ))
}