# The value is written twice, once for the screen and once for a screen reader,
# and the two must agree. That is the only reason this component takes an
# argument rather than passing everything through.

#' Progress
#'
#' A bar showing how far along a task is.
#'
#' @param value Number. How far along the task is, between `min` and `max`.
#' @param min,max Number. The ends of the range `value` is measured against.
#' @param label String. What the bar is measuring, for a screen reader. Pass
#'   `NULL` and an `aria-labelledby` in `...` to point at visible text instead.
#' @inheritParams bc_skeleton
#' @return A `<div>` tag.
#' @export
#' @examples
#' bc_progress(66, label = "Upload progress")
#'
#' bc_progress(3, max = 8, label = "Pulls audited")
bc_progress <- function(value, min = 0, max = 100, label = NULL, ...) {
  check_number_decimal(value)
  check_number_decimal(min)
  check_number_decimal(max)
  check_string(label, allow_null = TRUE, allow_empty = FALSE)

  if (min >= max) {
    cli::cli_abort(
      "{.arg min} must be less than {.arg max}, not {.val {min}} and {.val {max}}.",
      call = rlang::caller_env()
    )
  }

  if (value < min || value > max) {
    cli::cli_abort(
      "{.arg value} must be between {.val {min}} and {.val {max}}, not {.val {value}}.",
      call = rlang::caller_env()
    )
  }

  bc_tag(div(
    class = "progress",
    role = "progressbar",
    `aria-label` = label,
    `aria-valuenow` = value,
    `aria-valuemin` = min,
    `aria-valuemax` = max,
    ...,
    span(style = paste0("width: ", bc_share(value, min, max), "%"))
  ))
}

# Where `value` sits in its range, as a percentage. Two decimals is finer than
# a pixel on any screen this will be read on, and keeps the style attribute
# from carrying fifteen digits.
bc_share <- function(value, min, max) {
  round((value - min) / (max - min) * 100, 2)
}
