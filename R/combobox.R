# Combobox, inlined from the docs mirror. The visible input is the editable
# control, the hidden input stores the submitted value, and the listbox sits in
# a `data-popover` wrapper the Combobox script can resolve.

#' Combobox
#'
#' A searchable select with an editable text input and a hidden value input.
#'
#' @param id String. The ID for the combobox root. Input, popover and listbox
#'   IDs derive from it.
#' @param ... For [bc_combobox()], option tags from [bc_combobox_option()] and
#'   [bc_combobox_group()], or plain character values that become simple
#'   options.
#' @param placeholder String. Text shown while empty.
#' @param name String. The `name` of the hidden value input.
#' @param selected String or character vector. Initial value, or values in
#'   multiple mode.
#' @param empty String. Text shown when filtering finds no options.
#' @param multiple Bool. Whether the listbox accepts several selections.
#' @param auto_highlight Bool. Whether the first visible option activates when
#'   the list opens or filters.
#' @param disabled Bool. Whether the input is disabled.
#' @param class Vector of class names merged onto the combobox root.
#' @param aria_label String. Accessible name for the input, since its
#'   placeholder alone is not one.
#' @return A `<div>` tag of class `combobox`.
#' @details
#' Submits a string, or a JSON array when `multiple = TRUE`.
#' @seealso [bc_combobox_option()], [bc_combobox_group()],
#'   [bc_combobox_separator()]
#' @export
#' @examples
#' bc_combobox(
#'   "framework",
#'   bc_combobox_option("Next.js"),
#'   bc_combobox_option("SvelteKit"),
#'   bc_combobox_option("Remix"),
#'   placeholder = "Select a framework",
#'   class = "w-60"
#' )
bc_combobox <- function(
  id,
  ...,
  placeholder = "",
  name = id,
  selected = "",
  empty = "No items found.",
  multiple = FALSE,
  auto_highlight = FALSE,
  disabled = FALSE,
  class = NULL,
  aria_label = NULL
) {
  if (is.null(id)) {
    id <- paste0(
      "combobox-",
      paste0(sample(1:9, 8, replace = TRUE), collapse = "")
    )
  }
  if (is.null(name)) {
    name <- id
  }
  check_string(id, allow_empty = FALSE)
  check_string(placeholder, allow_empty = TRUE)
  check_string(name, allow_empty = FALSE)
  check_character(selected, allow_null = TRUE, allow_empty = TRUE)
  check_string(empty, allow_empty = TRUE)
  check_bool(multiple)
  check_bool(auto_highlight)
  check_bool(disabled)
  check_character(class, allow_null = TRUE, allow_empty = TRUE)
  check_string(aria_label, allow_null = TRUE, allow_empty = FALSE)

  listbox_id <- paste0(id, "-listbox")
  options <- combobox_items(list2(...))

  hidden_value <- if (multiple) {
    if (length(selected) && any(nzchar(selected))) {
      paste0("[", paste(sprintf('"%s"', selected), collapse = ", "), "]")
    } else {
      "[]"
    }
  } else {
    if (length(selected)) selected[[1]] else ""
  }

  bc_tag(htmltools::attachDependencies(
    div(
      class = c("combobox", class),
      id = id,
      `data-auto-highlight` = if (auto_highlight) "true",
      tags$input(
        type = "text",
        role = "combobox",
        id = paste0(id, "-input"),
        placeholder = placeholder,
        autocomplete = "off",
        autocorrect = "off",
        spellcheck = "false",
        `aria-autocomplete` = "list",
        `aria-expanded` = "false",
        `aria-controls` = listbox_id,
        `aria-label` = aria_label,
        disabled = if (disabled) NA
      ),
      HTML(paste0(
        '<svg aria-hidden="true" xmlns="http://www.w3.org/2000/svg" width="24" ',
        'height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" ',
        'stroke-width="2" stroke-linecap="round" stroke-linejoin="round" ',
        'class="combobox-trigger-icon"><path d="m6 9 6 6 6-6" /></svg>'
      )),
      div(
        id = paste0(id, "-popover"),
        `data-popover` = NA,
        `aria-hidden` = "true",
        div(
          role = "listbox",
          id = listbox_id,
          `aria-orientation` = "vertical",
          `aria-multiselectable` = if (multiple) "true",
          `data-empty` = empty,
          options
        )
      ),
      tags$input(type = "hidden", name = name, value = hidden_value)
    ),
    bc_script_dep("combobox", popover = TRUE)
  ))
}

#' Combobox option
#'
#' A selectable entry in a combobox listbox.
#'
#' @param value String. The submitted value. When `label` is `NULL`, the
#'   rendered text too.
#' @param ... Content of the option, used when `label` is `NULL`.
#' @param label String. Display text. Defaults to the value when `NULL`.
#' @param filter String. Extra text searched beyond the label.
#' @return A `<div>` tag of class `option` role.
#' @details
#' `data-label` sets the input text when it differs from the content.
#' @export
#' @examples
#' bc_combobox_option("Next.js")
#'
#' bc_combobox_option(
#'   "argentina",
#'   label = "Argentina",
#'   filter = "Argentina South America"
#' )
bc_combobox_option <- function(value, ..., label = NULL, filter = NULL) {
  check_string(value, allow_empty = FALSE)
  if (!is.null(label)) {
    check_string(label, allow_empty = TRUE)
  }
  if (!is.null(filter)) {
    check_string(filter, allow_empty = TRUE)
  }

  # `label` is what the input displays, so it only stands in as the content
  # when there is none: an option may be an icon beside its name.
  content <- if (length(list(...))) {
    list(...)
  } else {
    label %||% value
  }
  bc_tag(div(
    role = "option",
    `data-value` = value,
    `data-label` = label,
    `data-filter` = filter,
    content
  ))
}

#' Combobox group
#'
#' A headed set of options separated from the rest of the list.
#'
#' @param title String. The group heading.
#' @param ... Option tags to group under the heading.
#' @return A `<div>` tag of class `option group`.
#' @export
#' @examples
#' bc_combobox_group(
#'   "Americas",
#'   bc_combobox_option("New York"),
#'   bc_combobox_option("Chicago")
#' )
bc_combobox_group <- function(title, ...) {
  check_string(title, allow_empty = FALSE)
  heading_id <- paste0(
    "combobox-group-",
    paste0(sample(1:9, 8, replace = TRUE), collapse = "")
  )
  bc_tag(div(
    role = "group",
    `aria-labelledby` = heading_id,
    div(role = "heading", id = heading_id, title),
    ...
  ))
}

#' Combobox separator
#'
#' A horizontal rule between combobox groups.
#'
#' @return An `<hr>` tag.
#' @export
#' @examples
#' bc_combobox_separator()
bc_combobox_separator <- function() {
  bc_tag(tags$hr(role = "separator"))
}

combobox_items <- function(args) {
  unlist(
    lapply(args, function(a) {
      if (is.character(a)) {
        lapply(a, combobox_option_tag)
      } else {
        list(a)
      }
    }),
    recursive = FALSE
  )
}

combobox_option_tag <- function(value) {
  div(role = "option", `data-value` = value, value)
}
