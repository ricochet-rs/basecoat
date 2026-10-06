# The custom Select needs JavaScript, Basecoat's own data model, and a hidden
# input. A native `<select>` with the same `select` class keeps browser
# behaviour and form integration and needs no script.

bc_native_select_sizes <- c("default", "sm")

#' Native Select
#'
#' Create a browser-native select with an optional label and helper text.
#'
#' @param ... For `bc_native_select()`, options from
#'   [bc_native_select_option()] and [bc_native_select_group()]. For the other
#'   functions, extra tag attributes or content.
#' @param label String or tag. The field label for `bc_native_select()`, the
#'   option text for `bc_native_select_option()`, or the group title for
#'   `bc_native_select_group()`.
#' @param id String. The select ID. Required when `label` is set.
#' @param aria_label String. Accessible name for the select when there is no
#'   `label`.
#' @param placeholder String. Text of a blank first option, such as
#'   `"Select a fruit"`.
#' @param size String. `"default"` or `"sm"`.
#' @param description String or tag. Helper text shown under the select.
#' @return An htmltools tag.
#' @details
#' Needs a `label` or an `aria_label`, not both.
#' @inheritParams bc_input disabled invalid name
#' @export
#' @examples
#' bc_native_select(
#'   bc_native_select_option("Apple", value = "apple"),
#'   bc_native_select_option("Banana", value = "banana"),
#'   bc_native_select_option("Blueberry", value = "blueberry"),
#'   aria_label = "Fruit",
#'   placeholder = "Select a fruit"
#' )
#'
#' bc_native_select(
#'   bc_native_select_group(
#'     "Vegetables",
#'     bc_native_select_option("Carrot", value = "carrot"),
#'     bc_native_select_option("Potato", value = "potato")
#'   ),
#'   id = "food",
#'   label = "Food",
#'   placeholder = "Select food"
#' )
bc_native_select <- function(
  ...,
  label = NULL,
  id = NULL,
  aria_label = NULL,
  placeholder = NULL,
  size = "default",
  description = NULL,
  name = id,
  disabled = FALSE,
  invalid = FALSE
) {
  size <- arg_match(size, bc_native_select_sizes)
  check_string(id, allow_null = TRUE, allow_empty = FALSE)
  check_string(aria_label, allow_null = TRUE, allow_empty = FALSE)
  check_string(placeholder, allow_null = TRUE, allow_empty = TRUE)
  check_string(name, allow_null = TRUE, allow_empty = FALSE)
  check_bool(disabled)
  check_bool(invalid)

  if (is.null(id) && !is.null(label)) {
    cli::cli_abort(
      "{.arg id} is required when {.arg label} is given.",
      call = caller_env()
    )
  }
  if (is.null(label) && is.null(aria_label)) {
    cli::cli_abort(
      "A native select needs an accessible name: give {.arg label} or {.arg aria_label}.",
      call = caller_env()
    )
  }
  if (!is.null(label) && !is.null(aria_label)) {
    cli::cli_abort(
      "A select has one name: pass {.arg label} or {.arg aria_label}, not both.",
      call = caller_env()
    )
  }

  described_by <- if (!is.null(description)) paste0(id, "-description")

  select <- tags$select(
    id = id,
    name = name,
    class = "select",
    `data-size` = if (size != "default") size,
    `aria-label` = aria_label,
    disabled = if (disabled) NA,
    `aria-invalid` = if (invalid) "true",
    `aria-describedby` = described_by,
    if (!is.null(placeholder)) tags$option(value = "", placeholder),
    ...
  )

  if (is.null(label)) {
    return(bc_tag(select))
  }

  bc_field(
    disabled = disabled,
    invalid = invalid,
    tags$label(`for` = id, label),
    select,
    if (!is.null(description)) tags$p(id = described_by, description)
  )
}

#' @rdname bc_native_select
#' @param value String. The option's value.
#' @export
bc_native_select_option <- function(value, ..., label = NULL) {
  check_string(value, allow_empty = TRUE)
  bc_tag(tags$option(value = value, ..., label))
}

#' @rdname bc_native_select
#' @export
bc_native_select_group <- function(label, ...) {
  check_string(label, allow_empty = FALSE)
  bc_tag(tags$optgroup(label = label, ...))
}
