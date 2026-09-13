# Basecoat has no spinner component: a spinner is the `loader-circle` Lucide
# icon with the `animate-spin` utility, sized by a `size-*` class.

#' Spinner
#'
#' A loading indicator as the `loader-circle` Lucide icon with the `animate-spin`
#' utility.
#'
#' @param label String. The accessible `aria-label`.
#' @param size String. A Tailwind size utility suffix, e.g. `"4"` for `size-4`.
#'   `NULL` uses the icon's natural size.
#' @param ... Tag attributes for the `<svg>`.
#' @return An `<svg>` tag.
#' @export
#' @examples
#' bc_spinner()
#'
#' bc_spinner(size = "6")
bc_spinner <- function(label = "Loading", size = NULL, ...) {
  check_string(label, allow_empty = FALSE)
  check_string(size, allow_null = TRUE, allow_empty = FALSE)

  bc_tag(tags$svg(
    `aria-label` = label,
    role = "status",
    class = paste0(
      "animate-spin",
      if (!is.null(size)) paste0(" size-", size)
    ),
    xmlns = "http://www.w3.org/2000/svg",
    width = "24",
    height = "24",
    viewBox = "0 0 256 256",
    fill = "currentColor",
    HTML(bc_icon_paths[["circle-notch"]]),
    ...
  ))
}