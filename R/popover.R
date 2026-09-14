#' Popover
#'
#' An inline popover of content beside its trigger.
#'
#' @param ... Content for the popover.
#' @param title String or tag. A heading for the popover.
#' @param description String or tag. Text shown under the heading.
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
#' @export
#' @examples
#' bc_popover(
#'   title = "Dimensions",
#'   description = "Set the dimensions for the layer."
#' )
#'
#' bc_popover(
#'   bc_input(id = "width", label = "Width", value = "100%"),
#'   title = "Dimensions",
#'   trigger_label = "Resize"
#' )
bc_popover <- function(...,
                       id = NULL,
                       title = NULL,
                       description = NULL,
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
    # The stylesheet finds the heading and the text through the <header>, so
    # the pair is written here rather than left to every caller.
    if (!is.null(title) || !is.null(description)) {
      tags$header(
        if (!is.null(title)) tags$h4(title),
        if (!is.null(description)) tags$p(description)
      )
    },
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
