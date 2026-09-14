# A field wraps one form control with its label and helper text, a fieldset
# groups related fields, and a separator divides stacked sections. Only the
# roots carry classes; the CSS finds the label, control and text by element
# name.

bc_field_orientations <- c("default", "horizontal", "responsive")

#' Field
#'
#' A single form control wrapped with its label and helper text.
#'
#' @param ... Tag attributes and children for the `<div>`.
#' @inheritParams bc_checkbox
#' @param orientation String. One of `r toString(bc_field_orientations)`.
#'   `default` writes no attribute.
#' @param disabled Bool. Whether to mark the field as disabled.
#' @return A tag.
#' @details
#' Children render in order: label, control, helper text. A horizontal field
#' takes the control first.
#' @export
#' @examples
#' bc_field(
#'   htmltools::tags$label(`for` = "username", "Username"),
#'   htmltools::tags$input(id = "username", type = "text"),
#'   htmltools::tags$p("Choose a unique username for your account.")
#' )
#'
#' bc_field(
#'   htmltools::tags$input(id = "sync", type = "checkbox", role = "switch"),
#'   htmltools::tags$label(`for` = "sync", "Sync folders"),
#'   orientation = "horizontal"
#' )
bc_field <- function(...,
                     orientation = "default",
                     disabled = FALSE,
                     invalid = FALSE) {
  orientation <- arg_match(orientation, bc_field_orientations)
  check_bool(disabled)
  check_bool(invalid)

  bc_tag(div(
    role = "group",
    class = "field",
    `data-orientation` = if (orientation != "default") orientation,
    `data-disabled` = if (disabled) NA,
    `data-invalid` = if (invalid) NA,
    ...
  ))
}

#' @rdname bc_field
#' @param legend String or tag. The group's heading, as a `<legend>`.
#' @param description String or tag. Shown under the legend.
#' @export
#' @examples
#'
#' bc_fieldset(
#'   legend = "Address Information",
#'   description = "We need your address to deliver your order.",
#'   bc_field(
#'     htmltools::tags$label(`for` = "street", "Street"),
#'     htmltools::tags$input(id = "street", type = "text")
#'   )
#' )
bc_fieldset <- function(..., legend = NULL, description = NULL) {
  bc_tag(tags$fieldset(
    class = "fieldset",
    if (!is.null(legend)) tags$legend(legend),
    if (!is.null(description)) tags$p(description),
    ...
  ))
}

#' @rdname bc_field
#' @param aria_label String. Accessible name for the group.
#' @export
#' @examples
#'
#' bc_field_group(
#'   aria_label = "Account credentials",
#'   bc_field(
#'     htmltools::tags$label(`for` = "email", "Email"),
#'     htmltools::tags$input(id = "email", type = "email")
#'   ),
#'   bc_field_separator(),
#'   bc_field(
#'     htmltools::tags$label(`for` = "password", "Password"),
#'     htmltools::tags$input(id = "password", type = "password")
#'   )
#' )
bc_field_group <- function(..., aria_label = NULL) {
  check_string(aria_label, allow_null = TRUE, allow_empty = FALSE)

  bc_tag(div(
    role = "group",
    class = "fieldset",
    `aria-label` = aria_label,
    ...
  ))
}

#' @rdname bc_field
#' @export
bc_field_separator <- function() {
  bc_tag(div(
    class = "field-separator",
    tags$hr(role = "separator")
  ))
}