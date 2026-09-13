# A text input is `class="input"`, with a label and helper text wrapped in a
# `field`. The raw input carries the class and the native form attributes; the
# field wrapper mirrors the disabled and invalid states for styling.

#' Input
#'
#' An `<input>` carrying the Basecoat `input` class, optionally wrapped with a
#' label in a `field`.
#'
#' @param ... Tag attributes for the `<input>`.
#' @inheritParams bc_checkbox
#' @param id String. The input `id`, required when a `label` is given.
#' @param type String. The `type` attribute, `"text"` by default.
#' @param placeholder String. Placeholder text.
#' @param description String or tag. Helper text shown under the input, wired
#'   to it with `aria-describedby`.
#' @param value String. The initial value.
#' @param required Bool. Whether the input is required.
#' @param disabled Bool. Whether the input is disabled.
#' @param aria_label String. Accessible name, for an input with no visible
#'   `label`. A placeholder alone is not one.
#' @return An `<input>` tag or, with a `label`, a `<div>` tag.
#' @export
#' @examples
#' bc_input(type = "email", placeholder = "Email", aria_label = "Email")
#'
#' bc_input(
#'   id = "email",
#'   label = "Email",
#'   type = "email",
#'   placeholder = "m@example.com",
#'   description = "Enter your email address."
#' )
bc_input <- function(...,
                     label = NULL,
                     id = NULL,
                     type = "text",
                     placeholder = NULL,
                     description = NULL,
                     value = NULL,
                     name = id,
                     required = FALSE,
                     disabled = FALSE,
                     invalid = FALSE,
                     aria_label = NULL) {
  check_string(id, allow_null = TRUE, allow_empty = FALSE)
  check_string(type, allow_empty = FALSE)
  check_string(placeholder, allow_null = TRUE)
  check_string(value, allow_null = TRUE)
  check_string(name, allow_null = TRUE, allow_empty = FALSE)
  check_bool(required)
  check_bool(disabled)
  check_bool(invalid)
  check_string(aria_label, allow_null = TRUE, allow_empty = FALSE)

  if (is.null(id) && !is.null(label)) {
    cli::cli_abort(
      "{.arg id} is required when {.arg label} is given.",
      call = caller_env()
    )
  }
  if (is.null(label) && !is.null(description)) {
    cli::cli_abort(
      "{.arg description} needs a {.arg label} to sit under.",
      call = caller_env()
    )
  }

  described_by <- if (!is.null(description)) paste0(id, "-description")

  input <- tags$input(
    id = id,
    name = name,
    class = "input",
    type = type,
    placeholder = placeholder,
    value = value,
    required = if (required) NA,
    disabled = if (disabled) NA,
    `aria-invalid` = if (invalid) "true",
    `aria-describedby` = described_by,
    `aria-label` = if (is.null(label)) aria_label,
    ...
  )

  if (is.null(label)) {
    return(bc_tag(input))
  }

  bc_field(
    disabled = disabled,
    invalid = invalid,
    tags$label(`for` = id, label),
    input,
    if (!is.null(description)) tags$p(id = described_by, description)
  )
}