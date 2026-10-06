#' Tooltip
#'
#' Create text that shows when you hover over or focus an element.
#'
#' @param ... The content the tooltip belongs to, and tag attributes.
#' @param text String. The tooltip text.
#' @param side String. Where the tooltip opens. One of `"top"` (default),
#'   `"bottom"`, `"left"`, `"right"`, `"inline-start"`, or `"inline-end"`.
#' @param align String. Alignment of the tooltip along that side. One of
#'   `"start"`, `"center"` (default), or `"end"`.
#' @return An htmltools tag.
#' @export
#' @examples
#' bc_tooltip("Save", text = "Save your work")
#'
#' bc_tooltip("Info", text = "Additional information", side = "bottom")
bc_tooltip <- function(..., text, side = "top", align = "center") {
  check_string(text, allow_empty = FALSE)
  side <- arg_match(
    side,
    c("top", "bottom", "left", "right", "inline-start", "inline-end")
  )
  align <- arg_match(align, c("start", "center", "end"))

  bc_tag(tags$span(
    `data-tooltip` = text,
    `data-side` = side,
    `data-align` = align,
    ...
  ))
}
