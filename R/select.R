#' Select
#'
#' A dropdown of options, with a hidden input carrying what was chosen.
#'
#' @param ... Options. A [bc_select_option()], a plain string, or a tag with
#'   `role = "option"` for one that carries its own markup.
#' @param placeholder String. Text shown while nothing is chosen.
#' @param name String. The `name` of the hidden input, defaulting to `id`.
#' @param id String. The ID for the select root. Trigger, popover and listbox
#'   IDs derive from it.
#' @param selected String or character vector. Initial value, or values in
#'   multiple mode.
#' @param disabled Bool. Whether the select is disabled.
#' @param invalid Bool. Whether to show the invalid state.
#' @param multiple Bool. Whether the listbox accepts several selections.
#' @param close_on_select Bool. Whether choosing closes the popover. Defaults
#'   to `TRUE` for a single select and `FALSE` for a multiple one.
#' @param class Vector of class names merged onto the trigger button, which is
#'   where the control's width is set.
#' @param aria_label String. Accessible name for the trigger, when nothing
#'   outside the control already labels it.
#' @return A `<div>` tag of class `select`.
#' @details
#' The hidden input holds the chosen value as a string in single mode and as a
#' JSON array in multiple mode.
#' @seealso [bc_select_option()]
#' @export
#' @examples
#' bc_select(
#'   "Apple",
#'   "Banana",
#'   "Blueberry",
#'   placeholder = "Select a fruit"
#' )
#'
#' bc_select(
#'   bc_select_option("light", "Light"),
#'   bc_select_option("dark", "Dark"),
#'   bc_select_option("system", "System"),
#'   placeholder = "Theme",
#'   name = "appearance",
#'   selected = "dark"
#' )
#'
#' bc_select(
#'   "tank",
#'   "healer",
#'   "dps",
#'   placeholder = "Any role",
#'   multiple = TRUE,
#'   selected = c("tank", "healer"),
#'   class = "w-full"
#' )
bc_select <- function(...,
                      placeholder = NULL,
                      name = NULL,
                      id = NULL,
                      selected = NULL,
                      disabled = FALSE,
                      invalid = FALSE,
                      multiple = FALSE,
                      close_on_select = !multiple,
                      class = NULL,
                      aria_label = NULL) {
  check_string(placeholder, allow_null = TRUE, allow_empty = TRUE)
  check_string(name, allow_null = TRUE, allow_empty = FALSE)
  check_string(id, allow_null = TRUE, allow_empty = FALSE)
  check_character(selected, allow_null = TRUE, allow_empty = TRUE)
  check_bool(disabled)
  check_bool(invalid)
  check_bool(multiple)
  check_bool(close_on_select)
  check_character(class, allow_null = TRUE, allow_empty = TRUE)
  check_string(aria_label, allow_null = TRUE, allow_empty = FALSE)

  if (is.null(id)) {
    id <- paste0("select-", paste0(sample(1:9, 8, replace = TRUE), collapse = ""))
  }

  name <- name %||% id
  chosen <- selected[nzchar(selected)]
  options <- select_items(list2(...), chosen)

  trigger <- tags$button(
    type = "button",
    class = c(if (is.null(class)) "w-[180px]", class),
    id = paste0(id, "-trigger"),
    `aria-haspopup` = "listbox",
    `aria-expanded` = "false",
    `aria-controls` = paste0(id, "-listbox"),
    disabled = if (disabled) NA,
    `aria-invalid` = if (invalid) "true",
    `aria-label` = aria_label,
    span(class = "truncate", select_label(placeholder, chosen, multiple)),
    bc_icon("caret-down", class = "text-muted-foreground opacity-50 shrink-0")
  )

  bc_tag(htmltools::attachDependencies(div(
    class = "select",
    id = id,
    `data-placeholder` = placeholder,
    `data-close-on-select` = tolower(close_on_select),
    `data-disabled` = if (disabled) NA,
    `data-invalid` = if (invalid) NA,
    trigger,
    div(
      id = paste0(id, "-popover"),
      `data-popover` = NA,
      `aria-hidden` = "true",
      div(
        role = "listbox",
        id = paste0(id, "-listbox"),
        `aria-orientation` = "vertical",
        `aria-labelledby` = paste0(id, "-trigger"),
        # The script reads multiple from here, not from the root.
        `aria-multiselectable` = if (multiple) "true",
        options
      )
    ),
    tags$input(
      type = "hidden",
      name = name,
      value = select_value(chosen, multiple)
    )
  ), bc_script_dep("select", popover = TRUE)))
}

# A string, a `bc_select_option()`, a tag that already is an option, or a list
# of any of those, since building options with `lapply()` is the common case.
select_items <- function(items, chosen) {
  unlist(
    lapply(items, function(item) select_item(item, chosen)),
    recursive = FALSE
  )
}

select_item <- function(item, chosen) {
  if (inherits(item, "shiny.tag") || inherits(item, "shiny.tag.list")) {
    return(list(item))
  }

  if (is.character(item)) {
    return(lapply(item, function(value) {
      select_option_tag(list(value = value), chosen)
    }))
  }

  # A list carrying no `value` is a list of options rather than one option.
  if (is.list(item) && is.null(item$value)) {
    return(select_items(item, chosen))
  }

  list(select_option_tag(item, chosen))
}

# The script seeds a single select from `aria-selected` and a multiple one from
# the hidden input, so both are written.
select_option_tag <- function(option, chosen) {
  div(
    role = "option",
    `data-value` = option$value,
    `aria-selected` = if (option$value %in% chosen) "true",
    option$label %||% option$value
  )
}

# What the trigger reads before any script runs, so the closed control is not
# blank on a server rendered page.
select_label <- function(placeholder, chosen, multiple) {
  if (!length(chosen)) {
    return(placeholder)
  }

  if (multiple) {
    return(paste(chosen, collapse = ", "))
  }

  chosen[[1]]
}

select_value <- function(chosen, multiple) {
  if (!multiple) {
    return(if (length(chosen)) chosen[[1]] else "")
  }

  if (!length(chosen)) {
    return("[]")
  }

  paste0("[", paste(sprintf('"%s"', chosen), collapse = ", "), "]")
}
#' Select Option
#'
#' A helper function to create individual select options.
#'
#' @param value String. The value of the option.
#' @param label String. The display label for the option.
#' @return A list containing option properties.
#' @export
#' @examples
#' bc_select_option("dark", "Dark")
#'
#' bc_select(
#'   bc_select_option("us-east-1", "US East"),
#'   bc_select_option("eu-west-1", "EU West"),
#'   placeholder = "Region"
#' )
bc_select_option <- function(value, label = NULL) {
  check_string(value, allow_empty = FALSE)
  
  list(
    value = value,
    label = if (is.null(label)) value else label
  )
}