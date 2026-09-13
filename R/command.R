#' Command
#'
#' A searchable command palette or standalone command list.
#'
#' @param ... Command content. Strings become command items, tags pass through
#'   and lists are passed to [bc_command_item()]. Build the rest with
#'   `bc_command_group()` and `bc_command_separator()`.
#' @param id String. The ID for the command root, or the dialog when
#'   `dialog = TRUE`.
#' @param placeholder String. Placeholder text for the filter input.
#' @param empty String. Message shown when nothing matches the filter.
#' @param label String. Accessible name for the command menu.
#' @param dialog Bool. Wrap the command in a `<dialog class="command-dialog">`
#'   with a trigger button.
#' @param trigger String. The trigger button's label when `dialog = TRUE`.
#' @param manual Bool. Add `data-filter="manual"` when the app owns filtering.
#' @return A `<div class="command">`, or a trigger button and `<dialog>` pair.
#' @details
#' The script filters `role="menuitem"` items by the input and manages keyboard
#' selection.
#' @export
#' @examples
#' bc_command(
#'   bc_command_group("Suggestions", "Calendar", "Search Emoji"),
#'   bc_command_separator(),
#'   bc_command_item("Profile", shortcut = "CmdP")
#' )
bc_command <- function(...,
                       id = NULL,
                       placeholder = "Type a command or search...",
                       empty = "No results found.",
                       label = "Command menu",
                       dialog = FALSE,
                       trigger = NULL,
                       manual = FALSE) {
  check_string(placeholder, allow_empty = TRUE)
  check_string(empty, allow_empty = TRUE)
  check_string(label, allow_empty = FALSE)
  check_bool(dialog)
  check_bool(manual)
  check_string(trigger, allow_null = TRUE, allow_empty = FALSE)

  if (is.null(id)) {
    id <- paste0("command-", paste0(sample(1:9, 8, replace = TRUE), collapse = ""))
  }
  if (dialog && is.null(trigger)) {
    trigger <- "Open Menu"
  }

  input_id <- paste0(id, "-input")
  menu_id <- paste0(id, "-menu")

  command <- div(
    class = if (dialog) "command" else "command border",
    `aria-label` = if (!dialog) label,
    id = if (!dialog) id,
    `data-filter` = if (manual) "manual",
    tags$header(
      command_lucide(),
      tags$input(
        type = "text",
        id = input_id,
        placeholder = placeholder,
        autocomplete = "off",
        autocorrect = "off",
        spellcheck = "false",
        `aria-autocomplete` = "list",
        role = "combobox",
        `aria-expanded` = "true",
        `aria-controls` = menu_id
      )
    ),
    div(
      role = "menu",
      id = menu_id,
      `aria-orientation` = "vertical",
      `data-empty` = empty,
      command_items(list(...))
    )
  )

  if (!dialog) {
    return(bc_tag(htmltools::attachDependencies(command, bc_script_dep("command"))))
  }

  bc_tag(htmltools::attachDependencies(
    tagList(
      tags$button(
        type = "button",
        class = "btn",
        `data-variant` = "outline",
        onclick = paste0("document.getElementById('", id, "').showModal()"),
        trigger
      ),
      tags$dialog(
        id = id,
        class = "command-dialog",
        `aria-label` = label,
        onclick = "if (event.target === this) this.close()",
        command
      )
    ),
    bc_script_dep("command")
  ))
}

#' @rdname bc_command
#' @param label String. The item's label, used as the filter text.
#' @param shortcut String. A shortcut hint shown at the inline end.
#' @param icon A tag. An icon before the label.
#' @param disabled Bool. Mark the item as disabled.
#' @param href String. When given, the item is an `<a role="menuitem">`.
#' @param filter String. Overrides the text matched against the input.
#' @param keywords String. Extra terms matched against the input.
#' @param force Bool. Keep the item visible whatever the filter.
#' @param keep_open Bool. Keep the command open when the item is chosen.
#' @param checked Bool. Show the item's indicator.
#' @export
bc_command_item <- function(label,
                            ...,
                            shortcut = NULL,
                            icon = NULL,
                            disabled = FALSE,
                            href = NULL,
                            filter = NULL,
                            keywords = NULL,
                            force = FALSE,
                            keep_open = FALSE,
                            checked = FALSE) {
  check_string(label, allow_empty = FALSE)
  check_string(shortcut, allow_null = TRUE, allow_empty = TRUE)
  check_bool(disabled)
  check_string(href, allow_null = TRUE, allow_empty = FALSE)
  if (!is.null(filter)) check_string(filter, allow_empty = TRUE)
  check_string(keywords, allow_null = TRUE, allow_empty = TRUE)
  check_bool(force)
  check_bool(keep_open)
  check_bool(checked)

  item_tag <- if (!is.null(href)) tags$a else tags$div

  bc_tag(item_tag(
    role = "menuitem",
    href = href,
    `data-filter` = if (is.null(filter)) label else filter,
    `data-keywords` = keywords,
    `data-force` = if (force) NA,
    `data-keep-command-open` = if (keep_open) NA,
    `aria-disabled` = if (disabled) "true",
    `data-checked` = if (checked) "true",
    ...,
    if (checked) span(`data-indicator` = NA, command_check()),
    icon,
    if (is.null(shortcut) && is.null(icon) && !checked) {
      label
    } else {
      span(label)
    },
    if (!is.null(shortcut)) span(`data-shortcut` = NA, shortcut)
  ))
}

#' @rdname bc_command
#' @param title String. A group heading shown above its items.
#' @export
bc_command_group <- function(title, ...) {
  check_string(title, allow_empty = FALSE)
  heading_id <- paste0("command-label-", paste0(sample(1:9, 8, replace = TRUE), collapse = ""))

  bc_tag(div(
    role = "group",
    `aria-labelledby` = heading_id,
    span(role = "heading", id = heading_id, title),
    command_items(list(...))
  ))
}

#' @rdname bc_command
#' @export
bc_command_separator <- function() {
  bc_tag(tags$hr(role = "separator"))
}

command_items <- function(items) {
  lapply(items, function(item) {
    if (inherits(item, "shiny.tag") || inherits(item, "shiny.tag.list")) {
      return(item)
    }
    if (is.character(item)) {
      return(bc_command_item(item))
    }
    if (is.list(item)) {
      return(do.call(bc_command_item, item))
    }
    bc_command_item(as.character(item))
  })
}

command_lucide <- function() {
  HTML(
    '<svg class="lucide lucide-search-icon lucide-search" xmlns="http://www.w3.org/2000/svg" ',
    'width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" ',
    'stroke-width="2" stroke-linecap="round" stroke-linejoin="round">',
    '<circle cx="11" cy="11" r="8" /><path d="m21 21-4.3-4.3" /></svg>'
  )
}

command_check <- function() {
  HTML(
    '<svg class="lucide lucide-check" xmlns="http://www.w3.org/2000/svg" width="24" ',
    'height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" ',
    'stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5" /></svg>'
  )
}