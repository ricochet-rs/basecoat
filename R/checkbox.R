# Basecoat 1.0 styles the raw `<input class="input">`, but a usable checkbox is
# the input paired with a label inside a `field` wrapper. Disabled and invalid
# are written twice: on the input for behaviour, on the wrapper for styling.

#' Checkbox
#'
#' Create a checkbox with a label.
#'
#' @param id String. The input ID.
#' @param label String or tag. The label.
#' @param ... Extra tag attributes for the checkbox.
#' @param checked Bool. Whether the box starts checked. Defaults to `FALSE`.
#' @param disabled Bool. Whether the box is disabled. Defaults to `FALSE`.
#' @param invalid Bool. Whether to show the invalid state. Defaults to
#'   `FALSE`.
#' @param description String or tag. Helper text shown under the label.
#' @param name String. The input name. Defaults to `id`.
#' @return An htmltools tag.
#' @export
#' @examples
#' bc_checkbox("terms", "Accept terms and conditions")
#'
#' bc_checkbox(
#'   "updates",
#'   "Email me updates",
#'   checked = TRUE,
#'   description = "Unsubscribe at any time."
#' )
bc_checkbox <- function(
  id,
  label,
  ...,
  checked = FALSE,
  disabled = FALSE,
  invalid = FALSE,
  description = NULL,
  name = id
) {
  check_string(id, allow_empty = FALSE)
  check_bool(checked)
  check_bool(disabled)
  check_bool(invalid)
  check_string(name, allow_empty = FALSE)

  described_by <- if (!is.null(description)) paste0(id, "-description")

  input <- tags$input(
    type = "checkbox",
    id = id,
    name = name,
    class = "input",
    checked = if (checked) NA,
    disabled = if (disabled) NA,
    `aria-invalid` = if (invalid) "true",
    `aria-describedby` = described_by,
    ...
  )

  label_tag <- tags$label(`for` = id, label)

  body <- if (is.null(description)) {
    label_tag
  } else {
    tags$section(label_tag, tags$p(id = described_by, description))
  }

  bc_field(
    orientation = "horizontal",
    disabled = disabled,
    invalid = invalid,
    input,
    body
  )
}
