#' Dropdown Menu
#'
#' Create a menu of actions that opens from a button.
#'
#' @param ... For `bc_dropdown_menu()` and `bc_dropdown_group()`, menu items
#'   from `bc_dropdown_item()`, `bc_dropdown_group()`,
#'   `bc_dropdown_separator()`, `bc_dropdown_checkbox()` and
#'   `bc_dropdown_radio()`. A string becomes an item, and a list is passed to
#'   [bc_dropdown_item()] as its arguments. For the item functions, extra tag
#'   attributes.
#' @param id String. The ID. Defaults to a random ID.
#' @param trigger_label String. The button's label. Defaults to `"Menu"`.
#' @param trigger Tag, such as an avatar, that opens the menu in place of the
#'   default button.
#' @param variant String. For `bc_dropdown_menu()`, the button variant from
#'   [bc_button()]. Defaults to `"outline"`. For `bc_dropdown_item()`,
#'   `"destructive"` or `NULL`.
#' @param side String. Where the menu opens next to the button. One of
#'   `"top"`, `"right"`, `"bottom"`, `"left"`, `"inline-start"` or
#'   `"inline-end"`.
#' @param align String. Alignment of the menu along that side. One of
#'   `"start"`, `"center"`, or `"end"`.
#' @param class String. Extra CSS classes for the menu.
#' @return An htmltools tag.
#' @export
#' @examples
#' bc_dropdown_menu(
#'   bc_dropdown_group(
#'     "My Account",
#'     bc_dropdown_item("Profile", shortcut = "CtrP"),
#'     bc_dropdown_item("Settings", shortcut = "CtrS")
#'   ),
#'   bc_dropdown_separator(),
#'   bc_dropdown_item("Log out")
#' )
#'
#' bc_dropdown_menu(
#'   bc_dropdown_group(
#'     "Panels",
#'     bc_dropdown_checkbox("Status bar", checked = TRUE),
#'     bc_dropdown_checkbox("Activity bar"),
#'     bc_dropdown_checkbox("Terminal", disabled = TRUE)
#'   ),
#'   bc_dropdown_separator(),
#'   bc_dropdown_group(
#'     "Position",
#'     bc_dropdown_radio("Top", checked = TRUE),
#'     bc_dropdown_radio("Bottom")
#'   ),
#'   trigger_label = "View"
#' )
bc_dropdown_menu <- function(
  ...,
  id = NULL,
  trigger_label = "Menu",
  trigger = NULL,
  variant = "outline",
  side = NULL,
  align = NULL,
  class = NULL
) {
  if (is.null(trigger)) {
    check_string(trigger_label, allow_empty = FALSE)
  }
  variant <- arg_match(variant, bc_button_variants)
  if (!is.null(side)) {
    side <- arg_match(
      side,
      c("top", "right", "bottom", "left", "inline-start", "inline-end")
    )
  }
  if (!is.null(align)) {
    align <- arg_match(align, c("start", "center", "end"))
  }
  check_string(class, allow_null = TRUE, allow_empty = TRUE)

  if (is.null(id)) {
    id <- paste0(
      "dropdown-menu-",
      paste0(sample(1:9, 8, replace = TRUE), collapse = "")
    )
  }

  popover <- div(
    id = paste0(id, "-popover"),
    `data-popover` = NA,
    `aria-hidden` = "true",
    `data-side` = side,
    `data-align` = align,
    class = paste0("min-w-32", if (!is.null(class)) paste0(" ", class)),
    div(
      role = "menu",
      id = paste0(id, "-menu"),
      `aria-labelledby` = paste0(id, "-trigger"),
      dropdown_items(list(...))
    )
  )

  trigger <- htmltools::tagAppendAttributes(
    trigger %||%
      tags$button(
        type = "button",
        class = "btn",
        `data-variant` = if (variant != "default") variant,
        trigger_label
      ),
    id = paste0(id, "-trigger"),
    `aria-haspopup` = "menu",
    `aria-controls` = paste0(id, "-menu"),
    `aria-expanded` = "false"
  )

  bc_tag(htmltools::attachDependencies(
    div(class = "dropdown-menu", id = id, trigger, popover),
    bc_script_dep("dropdown-menu", popover = TRUE)
  ))
}

#' @rdname bc_dropdown_menu
#' @param label String. The item's label.
#' @param shortcut String. A shortcut hint shown at the end of the item.
#' @param icon Tag. An icon before the label.
#' @param disabled Bool. Whether the item is disabled. Defaults to `FALSE`.
#' @export
bc_dropdown_item <- function(
  label,
  ...,
  shortcut = NULL,
  icon = NULL,
  disabled = FALSE,
  variant = NULL
) {
  check_string(label, allow_empty = FALSE)
  check_string(shortcut, allow_null = TRUE, allow_empty = TRUE)
  check_bool(disabled)
  if (!is.null(variant)) {
    variant <- arg_match(variant, c("destructive"))
  }

  bc_tag(div(
    role = "menuitem",
    `aria-disabled` = if (disabled) "true",
    `data-variant` = variant,
    ...,
    icon,
    if (is.null(shortcut)) label else span(label),
    if (!is.null(shortcut)) tags$kbd(shortcut)
  ))
}

#' @rdname bc_dropdown_menu
#' @param title String. A group title shown above its items.
#' @param heading_id String. The ID of the group title. Defaults to a random
#'   ID.
#' @export
bc_dropdown_group <- function(title = NULL, ..., heading_id = NULL) {
  if (is.null(title)) {
    return(bc_tag(div(role = "group", dropdown_items(list(...)))))
  }

  check_string(title, allow_empty = FALSE)

  if (is.null(heading_id)) {
    heading_id <- paste0(
      "dropdown-label-",
      paste0(sample(1:9, 8, replace = TRUE), collapse = "")
    )
  }

  bc_tag(div(
    role = "group",
    `aria-labelledby` = heading_id,
    div(role = "heading", id = heading_id, title),
    dropdown_items(list(...))
  ))
}

#' @rdname bc_dropdown_menu
#' @export
bc_dropdown_separator <- function() {
  bc_tag(tags$hr(role = "separator"))
}

#' @rdname bc_dropdown_menu
#' @param checked Bool. Whether the item starts checked. Defaults to `FALSE`.
#' @export
bc_dropdown_checkbox <- function(
  label,
  ...,
  checked = FALSE,
  disabled = FALSE,
  icon = NULL
) {
  check_string(label, allow_empty = FALSE)
  check_bool(checked)
  check_bool(disabled)

  bc_tag(div(
    role = "menuitemcheckbox",
    `aria-checked` = tolower(checked),
    `aria-disabled` = if (disabled) "true",
    ...,
    span(`data-indicator` = NA, bc_icon("check")),
    if (!is.null(icon)) icon,
    if (is.null(icon)) label else span(label)
  ))
}

#' @rdname bc_dropdown_menu
#' @export
bc_dropdown_radio <- function(
  label,
  ...,
  checked = FALSE,
  disabled = FALSE,
  icon = NULL
) {
  check_string(label, allow_empty = FALSE)
  check_bool(checked)
  check_bool(disabled)

  bc_tag(div(
    role = "menuitemradio",
    `aria-checked` = tolower(checked),
    `aria-disabled` = if (disabled) "true",
    ...,
    span(`data-indicator` = NA, bc_icon("check")),
    if (!is.null(icon)) icon,
    if (is.null(icon)) label else span(label)
  ))
}

dropdown_items <- function(items) {
  lapply(items, function(item) {
    if (inherits(item, "shiny.tag") || inherits(item, "shiny.tag.list")) {
      return(item)
    }
    if (is.character(item)) {
      return(bc_dropdown_item(item))
    }
    if (is.list(item)) {
      return(do.call(bc_dropdown_item, item))
    }
    bc_dropdown_item(as.character(item))
  })
}
