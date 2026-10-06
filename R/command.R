#' Command
#'
#' Create a searchable command menu, inline or in a modal.
#'
#' @param ... For `bc_command()` and `bc_command_group()`, items from
#'   [bc_command_item()], [bc_command_group()] and [bc_command_separator()]. A
#'   string becomes an item, and a list is passed to [bc_command_item()] as its
#'   arguments. For `bc_command_item()`, extra tag attributes.
#' @param id String. The ID. Defaults to a random ID.
#' @param placeholder String. Placeholder text for the search input.
#' @param empty String. Message shown when nothing matches the search.
#'   Defaults to `"No results found."`.
#' @param label String. Accessible name for the command menu. Defaults to
#'   `"Command menu"`.
#' @param dialog Bool. Show the menu in a modal opened by a button. Defaults to
#'   `FALSE`.
#' @param trigger String. The button's label when `dialog = TRUE`. Defaults to
#'   `"Open Menu"`.
#' @param manual Bool. Turn off the built-in search so your app filters the
#'   items itself. Defaults to `FALSE`.
#' @param icon Tag. An icon to replace the search icon, such as one from the
#'   phosphoricons package.
#' @return An htmltools tag. With `dialog = TRUE`, a tag list of the button and
#'   the dialog.
#' @export
#' @examples
#' bc_command(
#'   bc_command_group("Suggestions", "Calendar", "Search Emoji"),
#'   bc_command_separator(),
#'   bc_command_item("Profile", shortcut = "CmdP")
#' )
bc_command <- function(
  ...,
  id = NULL,
  placeholder = "Type a command or search...",
  empty = "No results found.",
  label = "Command menu",
  dialog = FALSE,
  trigger = NULL,
  manual = FALSE,
  icon = NULL
) {
  check_string(placeholder, allow_empty = TRUE)
  check_string(empty, allow_empty = TRUE)
  check_string(label, allow_empty = FALSE)
  check_bool(dialog)
  check_bool(manual)
  check_string(trigger, allow_null = TRUE, allow_empty = FALSE)

  if (is.null(id)) {
    id <- paste0(
      "command-",
      paste0(sample(1:9, 8, replace = TRUE), collapse = "")
    )
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
      icon %||% bc_icon("magnifying-glass"),
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
    return(bc_tag(htmltools::attachDependencies(
      command,
      bc_script_dep("command")
    )))
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
#' @param label String. The item's label, also used as its search text.
#' @param shortcut String. A shortcut hint shown at the end of the item.
#' @param icon Tag. An icon before the label.
#' @param disabled Bool. Whether the item is disabled. Defaults to `FALSE`.
#' @param href String. A link URL. When set, the item is a link.
#' @param filter String. Search text to use instead of `label`.
#' @param keywords String. Extra search terms.
#' @param force Bool. Keep the item visible whatever the search. Defaults to
#'   `FALSE`.
#' @param keep_open Bool. Keep the menu open when the item is chosen. Defaults
#'   to `FALSE`.
#' @param checked Bool. Show a check mark beside the item. Defaults to
#'   `FALSE`.
#' @export
bc_command_item <- function(
  label,
  ...,
  shortcut = NULL,
  icon = NULL,
  disabled = FALSE,
  href = NULL,
  filter = NULL,
  keywords = NULL,
  force = FALSE,
  keep_open = FALSE,
  checked = FALSE
) {
  check_string(label, allow_empty = FALSE)
  check_string(shortcut, allow_null = TRUE, allow_empty = TRUE)
  check_bool(disabled)
  check_string(href, allow_null = TRUE, allow_empty = FALSE)
  if (!is.null(filter)) {
    check_string(filter, allow_empty = TRUE)
  }
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
    if (checked) span(`data-indicator` = NA, bc_icon("check")),
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
#' @param title String. A group title shown above its items.
#' @export
bc_command_group <- function(title, ...) {
  check_string(title, allow_empty = FALSE)
  heading_id <- paste0(
    "command-label-",
    paste0(sample(1:9, 8, replace = TRUE), collapse = "")
  )

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
