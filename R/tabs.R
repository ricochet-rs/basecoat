#' Tabs
#'
#' A tab component with navigation and content panels.
#'
#' @param ... List of tabs. Each item should be a list with 'label', 'content',
#'   and optionally 'id' and 'disabled'.
#' @param variant String. The tab variant ("default" or "line").
#' @param orientation String. The tab orientation ("horizontal" or "vertical").
#' @param id String. The ID for the tabs container.
#' @param aria_label String. Accessible name for the tablist, useful when a
#'   page has more than one.
#' @return A tag with proper tab structure.
#' @export
#' @examples
#' bc_tabs(
#'   bc_tab("Account details", label = "Account"),
#'   bc_tab("Password settings", label = "Password"),
#'   bc_tab("Not yet", label = "Billing", disabled = TRUE)
#' )
#'
#' bc_tabs(
#'   bc_tab(bc_card(bc_card_body("Usage this month")), label = "Usage"),
#'   bc_tab(bc_card(bc_card_body("Seats and roles")), label = "Team"),
#'   variant = "line",
#'   id = "workspace"
#' )
bc_tabs <- function(
  ...,
  variant = "default",
  orientation = "horizontal",
  id = NULL,
  aria_label = NULL
) {
  check_string(variant, allow_empty = FALSE)
  check_string(orientation, allow_empty = FALSE)
  check_string(aria_label, allow_null = TRUE, allow_empty = FALSE)

  # Validate variant
  if (!(variant %in% c("default", "line"))) {
    cli::cli_abort(
      "Variant must be 'default' or 'line'",
      call = rlang::caller_env()
    )
  }

  # Validate orientation
  if (!(orientation %in% c("horizontal", "vertical"))) {
    cli::cli_abort(
      "Orientation must be 'horizontal' or 'vertical'",
      call = rlang::caller_env()
    )
  }

  tabs_list <- list(...)

  # Generate IDs if not provided
  if (is.null(id)) {
    id <- paste0("tabs-", paste0(sample(1:9, 8, replace = TRUE), collapse = ""))
  }

  tablist_id <- paste0(id, "-tablist")
  tab_ids <- lapply(seq_along(tabs_list), function(i) paste0(id, "-tab-", i))
  panel_ids <- lapply(seq_along(tabs_list), function(i) {
    paste0(id, "-panel-", i)
  })

  # Create tab buttons
  tab_buttons <- lapply(seq_along(tabs_list), function(i) {
    tab_data <- tabs_list[[i]]
    is_active <- i == 1
    disabled <- !is.null(tab_data$disabled) && tab_data$disabled

    tags$button(
      type = "button",
      role = "tab",
      id = tab_ids[[i]],
      `aria-controls` = panel_ids[[i]],
      `aria-selected` = if (is_active) "true" else "false",
      tabindex = if (is_active) "0" else "-1",
      `data-disabled` = if (disabled) NA,
      tab_data$label
    )
  })

  # Create panels
  panels <- lapply(seq_along(tabs_list), function(i) {
    tab_data <- tabs_list[[i]]
    is_active <- i == 1
    disabled <- !is.null(tab_data$disabled) && tab_data$disabled

    div(
      role = "tabpanel",
      id = panel_ids[[i]],
      `aria-labelledby` = tab_ids[[i]],
      tabindex = "-1",
      `aria-selected` = if (is_active) "true" else "false",
      `data-disabled` = if (disabled) NA,
      hidden = !is_active,
      tab_data$content
    )
  })

  # Create the tablist nav
  nav <- tags$nav(
    role = "tablist",
    `aria-orientation` = orientation,
    `aria-label` = aria_label,
    `data-variant` = variant,
    class = "w-full",
    tab_buttons
  )

  # Create the main tabs container
  bc_tag(htmltools::attachDependencies(
    div(
      class = "tabs w-full",
      id = id,
      nav,
      panels
    ),
    bc_script_dep("tabs")
  ))
}

#' Tab Panel
#'
#' A helper function to create individual tab content panels.
#'
#' @param ... Content for the tab panel.
#' @param id String. The ID for this tab panel (optional).
#' @param label String. The label for this tab.
#' @param disabled Bool. Whether the tab is disabled.
#' @return A list containing tab properties.
#' @export
#' @examples
#' bc_tab("Account details", label = "Account")
#'
#' bc_tab(
#'   htmltools::p("Nothing to bill yet."),
#'   label = "Billing",
#'   disabled = TRUE
#' )
bc_tab <- function(..., id = NULL, label, disabled = FALSE) {
  check_string(label, allow_empty = FALSE)
  check_bool(disabled)

  list(
    id = id,
    label = label,
    content = tagList(...),
    disabled = disabled
  )
}
