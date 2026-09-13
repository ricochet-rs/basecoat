#' Popover
#'
#' An inline popover of content beside its trigger.
#'
#' @param ... Content for the popover.
#' @param id String. The ID for the popover wrapper.
#' @param trigger_label String or tag. The trigger button's label.
#' @param trigger A tag. A whole trigger, usually a [bc_button()], in place of
#'   the default outline button. The wiring attributes are added to it.
#' @param side String. Placement of the popover. One of `top`, `right`,
#'   `bottom`, `left`, `inline-start` or `inline-end`.
#' @param align String. Alignment of the popover on its side. One of `start`,
#'   `center` or `end`.
#' @param class Vector of class names for the popover content, replacing the
#'   default `w-72`.
#' @return A `<div class="popover">` with a trigger button and the popover
#'   content.
#' @details
#' The script toggles the popover's `data-popover` content next to its trigger.
#' @export
#' @examples
#' bc_popover(
#'   htmltools::tags$header(
#'     htmltools::tags$h4("Title"),
#'     htmltools::tags$p("A short description.")
#'   )
#' )
bc_popover <- function(...,
                       id = NULL,
                       trigger_label = "Open popover",
                       trigger = NULL,
                       side = "bottom",
                       align = "center",
                       class = NULL) {
  side <- arg_match(side, c("top", "right", "bottom", "left", "inline-start", "inline-end"))
  align <- arg_match(align, c("start", "center", "end"))
  check_character(class, allow_null = TRUE, allow_empty = TRUE)

  if (is.null(id)) {
    id <- paste0("popover-", paste0(sample(1:9, 8, replace = TRUE), collapse = ""))
  }

  trigger <- popover_trigger(trigger, trigger_label)

  trigger <- htmltools::tagAppendAttributes(
    trigger,
    id = paste0(id, "-trigger"),
    `aria-expanded` = "false",
    `aria-controls` = paste0(id, "-popover")
  )

  popover <- div(
    id = paste0(id, "-popover"),
    `data-popover` = NA,
    `aria-hidden` = "true",
    `data-side` = if (side != "bottom") side,
    `data-align` = align,
    # The default width steps aside for a caller's own, since two width
    # utilities on one element are resolved by stylesheet order, not this one.
    class = c(if (is.null(class)) "w-72", class),
    ...
  )

  bc_tag(htmltools::attachDependencies(
    div(class = "popover", id = id, trigger, popover),
    bc_script_dep("popover", popover = TRUE)
  ))
}

# The script finds the trigger as `:scope > button`, so a caller's own is used
# as given and only the wiring attributes are added to it.
popover_trigger <- function(trigger, trigger_label) {
  if (!is.null(trigger)) {
    return(trigger)
  }

  tags$button(
    type = "button",
    class = "btn",
    `data-variant` = "outline",
    trigger_label
  )
}
