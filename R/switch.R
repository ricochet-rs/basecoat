# A switch is a native checkbox with `role="switch"` and the `input` class,
# paired with its label in a horizontal field. States are written twice: on the
# input for behaviour, on the field wrapper for styling.

bc_switch_sizes <- c("default", "sm")

#' Switch
#'
#' Create an on and off toggle with a label. It submits like a checkbox.
#'
#' @inheritParams bc_checkbox id label checked disabled invalid description name
#' @param ... Extra tag attributes for the switch.
#' @param size String. `"default"` or `"sm"`.
#' @return An htmltools tag.
#' @export
#' @examples
#' bc_switch("airplane-mode", "Airplane Mode")
#'
#' bc_switch(
#'   "focus-mode",
#'   "Share across devices",
#'   checked = TRUE,
#'   description = "Focus is shared across devices."
#' )
bc_switch <- function(
  id,
  label,
  ...,
  size = "default",
  checked = FALSE,
  disabled = FALSE,
  invalid = FALSE,
  description = NULL,
  name = id
) {
  size <- arg_match(size, bc_switch_sizes)
  check_string(id, allow_empty = FALSE)
  check_bool(checked)
  check_bool(disabled)
  check_bool(invalid)
  check_string(name, allow_empty = FALSE)

  described_by <- if (!is.null(description)) paste0(id, "-description")

  input <- tags$input(
    type = "checkbox",
    role = "switch",
    id = id,
    name = name,
    class = "input",
    `data-size` = if (size != "default") size,
    checked = if (checked) NA,
    disabled = if (disabled) NA,
    `aria-invalid` = if (invalid) "true",
    `aria-describedby` = described_by,
    ...
  )

  field_label <- tags$label(`for` = id, label)

  body <- if (is.null(description)) {
    field_label
  } else {
    tags$section(field_label, tags$p(id = described_by, description))
  }

  bc_field(
    orientation = "horizontal",
    disabled = disabled,
    invalid = invalid,
    input,
    body
  )
}
