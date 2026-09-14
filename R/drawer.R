#' Drawer
#'
#' A modal side panel built on a native `<dialog>` element.
#'
#' @param ... Content for the drawer body.
#' @param id String. The ID for the dialog.
#' @param side String. The viewport side the drawer slides from. One of
#'   `bottom` (default), `top`, `right` or `left`.
#' @param trigger String. The trigger button's label, or `NULL` for no button.
#' @param title String. A header title shown above the body.
#' @param description String. A header description under the title.
#' @param actions A tag or tag list. Footer actions pinned below the body.
#' @param class String. Extra classes for the dialog.
#' @return A trigger button and a `<dialog class="drawer">`, or just the dialog
#'   when `trigger = NULL` and no opener is wanted.
#' @export
#' @examples
#' bc_drawer(
#'   bc_switch(
#'     "cookies-essential",
#'     "Essential",
#'     checked = TRUE,
#'     disabled = TRUE,
#'     description = "Needed for the site to work. Always on."
#'   ),
#'   bc_switch(
#'     "cookies-analytics",
#'     "Analytics",
#'     description = "Counts visits so we know which pages earn their keep."
#'   ),
#'   bc_switch(
#'     "cookies-marketing",
#'     "Marketing",
#'     description = "Lets advertisers follow you between sites."
#'   ),
#'   title = "Cookies",
#'   description = "Choose what this site may store on your device.",
#'   trigger = "Cookie settings",
#'   actions = htmltools::tagList(
#'     bc_dialog_close("Reject non-essential", variant = "outline"),
#'     bc_dialog_close("Accept all")
#'   )
#' )
bc_drawer <- function(...,
                      id = NULL,
                      side = "bottom",
                      trigger = "Open Drawer",
                      title = NULL,
                      description = NULL,
                      actions = NULL,
                      class = NULL) {
  side <- arg_match(side, c("bottom", "top", "right", "left"))
  check_string(trigger, allow_null = TRUE, allow_empty = FALSE)
  check_string(title, allow_null = TRUE, allow_empty = FALSE)
  check_string(description, allow_null = TRUE, allow_empty = TRUE)
  check_string(class, allow_null = TRUE, allow_empty = TRUE)

  if (is.null(id)) {
    id <- paste0("drawer-", paste0(sample(1:9, 8, replace = TRUE), collapse = ""))
  }

  title_id <- paste0(id, "-title")
  desc_id <- paste0(id, "-description")

  header <- if (!is.null(title)) {
    tags$header(
      class = "mx-auto w-full max-w-sm",
      tags$h2(id = title_id, title),
      if (!is.null(description)) p(id = desc_id, description)
    )
  }

  footer <- if (!is.null(actions)) {
    tags$footer(class = "mx-auto w-full max-w-sm", actions)
  }

  dialog <- tags$dialog(
    id = id,
    class = paste0("drawer", if (!is.null(class)) paste0(" ", class)),
    `data-side` = if (side != "bottom") side,
    `aria-labelledby` = if (!is.null(title)) title_id,
    `aria-describedby` = if (!is.null(description)) desc_id,
    tags$article(
      header,
      # The drawer runs the full width of the viewport, so the content centres
      # itself on the same measure the header and footer already use.
      tags$section(class = "px-4", div(class = "mx-auto w-full max-w-sm", ...)),
      footer
    )
  )

  if (is.null(trigger)) {
    return(bc_tag(htmltools::attachDependencies(dialog, bc_script_dep("drawer"))))
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
      dialog
    ),
    bc_script_dep("drawer")
  ))
}
