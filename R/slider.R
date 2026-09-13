#' Slider
#'
#' A range input component styled as a slider.
#'
#' @param min Number. The minimum value of the slider.
#' @param max Number. The maximum value of the slider.
#' @param value Number. The current value of the slider.
#' @param ... Additional attributes passed to the `<input>`.
#' @param disabled Bool. Whether the slider is disabled.
#' @param id String. The input `id`, and the `for` of its label.
#' @param label String or tag. Optional label for the slider.
#' @param description String or tag. Helper text shown under the label, wired to
#'   the input with `aria-describedby`.
#' @param oninput String. JavaScript function to run when the input changes.
#' @param aria_label String. Accessible name, for a slider with no visible
#'   `label`.
#' @return A tag with an `<input type="range">` element.
#' @export
#' @examples
#' bc_slider(0, 100, 50, aria_label = "Volume")
#'
#' bc_slider(
#'   min = 0,
#'   max = 100,
#'   value = 50,
#'   label = "Temperature",
#'   description = "Adjust the temperature setting"
#' )
bc_slider <- function(min,
                      max,
                      value,
                      ...,
                      disabled = FALSE,
                      id = NULL,
                      label = NULL,
                      description = NULL,
                      oninput = NULL,
                      aria_label = NULL) {
  check_number_whole(min)
  check_number_whole(max)
  check_number_whole(value)
  check_bool(disabled)
  check_string(aria_label, allow_null = TRUE, allow_empty = FALSE)

  if (is.null(id)) {
    id <- paste0("slider-", paste0(sample(1:9, 8, replace = TRUE), collapse = ""))
  }

  described_by <- if (!is.null(description)) paste0(id, "-description")

  input <- htmltools::attachDependencies(
    tags$input(
      type = "range",
      class = "input w-full",
      min = min,
      max = max,
      value = value,
      id = id,
      disabled = if (disabled) NA,
      `aria-describedby` = described_by,
      `aria-label` = if (is.null(label)) aria_label,
      oninput = oninput,
      ...
    ),
    bc_script_dep("range")
  )

  if (is.null(label) && is.null(description)) {
    return(bc_tag(input))
  }

  label_tag <- if (!is.null(label)) tags$label(class = "label", `for` = id, label)

  body <- if (is.null(description)) {
    label_tag
  } else {
    tags$section(label_tag, tags$p(id = described_by, description))
  }

  bc_field(
    orientation = "default",
    disabled = disabled,
    input,
    body
  )
}