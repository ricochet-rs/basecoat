# Basecoat has no scroll area component and no script: put `scrollbar` or
# `scrollbar-sm` on an element that already scrolls. The class augments native
# scrolling instead of wrapping content.

#' Scroll Area
#'
#' A scrollable region carrying the Basecoat scrollbar or `scrollbar-sm` class.
#'
#' @param ... Content and attributes for the scroll container.
#' @param size String. `default` for `scrollbar`, `sm` for `scrollbar-sm`.
#' @param overflow String. The overflow utility: `auto`, `x` or `y`.
#' @param class String. Extra classes, such as a height (`h-72`).
#' @param aria_label String. Accessible name for the region, when its content
#'   needs one of its own.
#' @return A `<div>` tag.
#' @export
#' @examples
#' bc_scroll_area(
#'   htmltools::tags$p("Content that scrolls."),
#'   class = "h-72"
#' )
bc_scroll_area <- function(
  ...,
  size = "default",
  overflow = "auto",
  class = NULL,
  aria_label = NULL
) {
  size <- arg_match(size, c("default", "sm"))
  overflow <- arg_match(overflow, c("auto", "x", "y"))
  check_string(class, allow_null = TRUE, allow_empty = TRUE)
  check_string(aria_label, allow_null = TRUE, allow_empty = FALSE)

  bc_tag(div(
    class = paste(
      c(
        if (size == "sm") "scrollbar-sm" else "scrollbar",
        if (overflow == "auto") {
          "overflow-auto"
        } else {
          paste0("overflow-", overflow)
        },
        class
      ),
      collapse = " "
    ),
    role = if (!is.null(aria_label)) "region",
    `aria-label` = aria_label,
    ...
  ))
}
