#' Radio Group
#'
#' A radio group component with individual radio inputs.
#'
#' @param ... Radio tags from [bc_radio()].
#' @param name String. The `name` attribute applied to every radio in the
#'   group, overriding any per-input name.
#' @param label String. Accessible label for the group, defaulting to `name`.
#' @param id String. The group `id`, defaulting to `name`. Used by
#'   [bc_shiny_deps()] to read and update the checked value as `input$id`.
#' @param disabled Bool. Whether to mark the entire group as disabled.
#' @param invalid Bool. Whether to show the invalid state for the group.
#' @return A tag with role="radiogroup".
#' @export
#' @examples
#' bc_radio_group(
#'   name = "density",
#'   bc_radio("default", "Default"),
#'   bc_radio("comfortable", "Comfortable"),
#'   bc_radio("compact", "Compact")
#' )
#'
#' bc_radio_group(
#'   name = "plan",
#'   bc_radio("monthly", "Monthly", checked = TRUE),
#'   bc_radio("yearly", "Yearly"),
#'   bc_radio("lifetime", "Lifetime")
#' )
bc_radio_group <- function(..., name, label = name, id = name, disabled = FALSE, invalid = FALSE) {
  check_string(name, allow_empty = FALSE)
  check_string(label, allow_empty = FALSE)
  check_string(id, allow_empty = FALSE)
  check_bool(disabled)
  check_bool(invalid)

  bc_tag(div(
    id = id,
    role = "radiogroup",
    `aria-label` = label,
    `data-slot` = "radio-group",
    class = "w-fit",
    `data-disabled` = if (disabled) NA,
    `data-invalid` = if (invalid) NA,
    lapply(list(...), radio_group_set_name, name = name)
  ))
}

radio_group_set_name <- function(tag, name) {
  if (inherits(tag, "shiny.tag")) {
    if (identical(tag$name, "input") && identical(tag$attribs$type, "radio")) {
      tag$attribs$name <- name
    } else if (length(tag$children)) {
      tag$children <- lapply(tag$children, radio_group_set_name, name = name)
    }
  } else if (is.list(tag)) {
    tag <- lapply(tag, radio_group_set_name, name = name)
  }
  tag
}

#' Radio Input
#'
#' A single radio input with its label, wrapped in a field.
#'
#' @param id String. The input `id`, and the `for` of its label.
#' @param label String or tag. The label content.
#' @param ... Attributes passed to the `<input>`.
#' @param checked Bool. Whether the radio starts selected.
#' @param disabled Bool. Whether the radio is disabled.
#' @param invalid Bool. Whether to show the invalid state.
#' @param description String or tag. Helper text shown under the label, wired to
#'   the input with `aria-describedby`.
#' @param name String. The input `name`, defaulting to `id`.
#' @return A `<div>` tag with role="group" containing radio and field.
#' @export
#' @examples
#' bc_radio("default", "Default")
#'
#' bc_radio("comfortable", "Comfortable", checked = TRUE, disabled = TRUE)
bc_radio <- function(id,
                     label,
                     ...,
                     checked = FALSE,
                     disabled = FALSE,
                     invalid = FALSE,
                     description = NULL,
                     name = id) {
  check_string(id, allow_empty = FALSE)
  check_bool(checked)
  check_bool(disabled)
  check_bool(invalid)
  check_string(name, allow_empty = FALSE)

  described_by <- if (!is.null(description)) paste0(id, "-description")

  input <- tags$input(
    type = "radio",
    id = id,
    name = name,
    value = id,
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