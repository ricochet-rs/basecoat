# A textarea is `class="textarea"`, or bare inside a `field` which styles
# textareas automatically. The field wrapper mirrors the disabled and invalid
# states for styling.

#' Textarea
#'
#' A multiline `<textarea>` carrying the Basecoat `textarea` class, optionally
#' wrapped with a label in a `field`.
#'
#' @param ... Tag attributes for the `<textarea>`.
#' @param rows String. The `rows` attribute.
#' @inheritParams bc_input id label placeholder value description required disabled invalid name aria_label
#' @return A `<textarea>` tag or, with a `label`, a `<div>` tag.
#' @details
#' The value is rendered as the textarea's text content, and a textarea inside a
#' `field` is styled by the field without needing the `textarea` class.
#' @export
#' @examples
#' bc_textarea(placeholder = "Type your message here", aria_label = "Message")
#'
#' bc_textarea(
#'   id = "message",
#'   label = "Message",
#'   placeholder = "Type your message here",
#'   description = "Write a short message."
#' )
bc_textarea <- function(...,
                        label = NULL,
                        id = NULL,
                        placeholder = NULL,
                        value = NULL,
                        rows = NULL,
                        description = NULL,
                        name = id,
                        required = FALSE,
                        disabled = FALSE,
                        invalid = FALSE,
                        aria_label = NULL) {
  check_string(id, allow_null = TRUE, allow_empty = FALSE)
  check_string(placeholder, allow_null = TRUE)
  check_string(value, allow_null = TRUE)
  check_string(rows, allow_null = TRUE)
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

  textarea <- tags$textarea(
    id = id,
    name = name,
    class = if (is.null(label)) "textarea",
    placeholder = placeholder,
    rows = rows,
    required = if (required) NA,
    disabled = if (disabled) NA,
    `aria-invalid` = if (invalid) "true",
    `aria-describedby` = described_by,
    `aria-label` = if (is.null(label)) aria_label,
    ...,
    value
  )

  if (is.null(label)) {
    return(bc_tag(textarea))
  }

  bc_field(
    disabled = disabled,
    invalid = invalid,
    tags$label(`for` = id, label),
    textarea,
    if (!is.null(description)) tags$p(id = described_by, description)
  )
}