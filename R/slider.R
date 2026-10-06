#' Slider
#'
#' Create a slider for selecting a number.
#'
#' @param min Whole number. The smallest value.
#' @param max Whole number. The largest value.
#' @param value Whole number. The starting value.
#' @param ... Extra tag attributes for the slider.
#' @param disabled Bool. Whether the slider is disabled. Defaults to `FALSE`.
#' @param id String. The input ID. Defaults to a random ID.
#' @param label String or tag. A visible label.
#' @param description String or tag. Helper text shown under the label.
#' @param oninput String. JavaScript to run when the value changes.
#' @param aria_label String. Accessible name for the slider. Set it when there
#'   is no `label`.
#' @return An htmltools tag.
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
bc_slider <- function(
  min,
  max,
  value,
  ...,
  disabled = FALSE,
  id = NULL,
  label = NULL,
  description = NULL,
  oninput = NULL,
  aria_label = NULL
) {
  check_number_whole(min)
  check_number_whole(max)
  check_number_whole(value)
  check_bool(disabled)
  check_string(aria_label, allow_null = TRUE, allow_empty = FALSE)

  if (is.null(id)) {
    id <- paste0(
      "slider-",
      paste0(sample(1:9, 8, replace = TRUE), collapse = "")
    )
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

  label_tag <- if (!is.null(label)) {
    tags$label(class = "label", `for` = id, label)
  }

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
