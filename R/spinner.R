# Basecoat has no spinner component: a spinner is the `circle-notch` Phosphor
# icon with the `animate-spin` utility, sized by a `size-*` class.

#' Spinner
#'
#' Create a spinning icon that shows something is loading.
#'
#' @param label String. Accessible name for the spinner. Defaults to
#'   `"Loading"`.
#' @param size String. A Tailwind size, such as `"4"` for `size-4`. `NULL`
#'   keeps the default of 24 pixels.
#' @param ... Extra tag attributes.
#' @return An htmltools tag.
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
