#' Radio Group
#'
#' Create a set of radio buttons where the user selects one.
#'
#' @param ... Radio buttons from [bc_radio()].
#' @param name String. The form field name for the group.
#' @param label String. Accessible name for the group. Defaults to `name`.
#' @param id String. The group ID. Defaults to `name`. With
#'   [bc_shiny_deps()], the selected value is `input$id`.
#' @param disabled Bool. Whether the group is disabled. Defaults to `FALSE`.
#' @param invalid Bool. Whether to show the invalid state. Defaults to
#'   `FALSE`.
#' @return An htmltools tag.
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
bc_radio_group <- function(
  ...,
  name,
  label = name,
  id = name,
  disabled = FALSE,
  invalid = FALSE
) {
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

#' Radio Button
#'
#' Create a radio button with a label.
#'
#' @param id String. The input ID, also used as the radio's value.
#' @param label String or tag. The label.
#' @param ... Extra tag attributes for the radio.
#' @param checked Bool. Whether the radio starts selected. Defaults to `FALSE`.
#' @param disabled Bool. Whether the radio is disabled. Defaults to `FALSE`.
#' @param invalid Bool. Whether to show the invalid state. Defaults to
#'   `FALSE`.
#' @param description String or tag. Helper text shown under the label.
#' @param name String. The input name. Defaults to `id`.
#' @return An htmltools tag.
#' @export
#' @examples
#' bc_radio("default", "Default")
#'
#' bc_radio("comfortable", "Comfortable", checked = TRUE, disabled = TRUE)
bc_radio <- function(
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
