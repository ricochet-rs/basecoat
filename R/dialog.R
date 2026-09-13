#' Dialog
#'
#' A modal dialog component using native HTML dialog element.
#'
#' @param id String. The dialog's unique ID.
#' @param title String or tag. The dialog title.
#' @param description String or tag. The dialog description.
#' @param content Function or tag. The main dialog content.
#' @param actions Function or tag. Action buttons for the dialog.
#' @param ... Additional attributes passed to the `<dialog>`.
#' @param open Bool. Whether the dialog is initially open.
#' @param close_on_click Bool. Whether to close the dialog when clicking outside.
#' @return A dialog element with proper structure and behavior.
#' @export
#' @examples
#' bc_dialog(
#'   id = "profile-dialog",
#'   title = "Edit profile",
#'   description = "Make changes to your profile here.",
#'   content = htmltools::tagList(
#'     htmltools::tags$div(class = "grid gap-3",
#'       htmltools::tags$label(class = "label", `for` = "name", "Name"),
#'       htmltools::tags$input(class = "input", type = "text", id = "name", value = "Pedro Duarte")
#'     )
#'   ),
#'   actions = htmltools::tagList(
#'     htmltools::tags$button(
#'       class = "btn", data_variant = "outline",
#'       onclick = "this.closest('dialog').close()", "Cancel"
#'     ),
#'     htmltools::tags$button(
#'       class = "btn",
#'       onclick = "this.closest('dialog').close()", "Save changes"
#'     )
#'   )
#' )
bc_dialog <- function(id,
                      title = NULL,
                      description = NULL,
                      content = NULL,
                      actions = NULL,
                      ...,
                      open = FALSE,
                      close_on_click = TRUE) {
  check_string(id, allow_empty = FALSE)
  check_bool(open)
  check_bool(close_on_click)

  # Generate IDs for title and description if not provided
  title_id <- if (!is.null(title)) paste0(id, "-title")
  desc_id <- if (!is.null(description)) paste0(id, "-description")

  # Build dialog structure
  dialog_content <- div(
    class = "sm:max-w-sm",
    tags$header(
      tags$h2(id = title_id, title),
      if (!is.null(description)) p(id = desc_id, description)
    ),
    if (!is.null(content)) tags$section(content),
    if (!is.null(actions)) tags$footer(actions),
    # Close button
    tags$button(
      type = "button",
      class = "btn",
      data_variant = "ghost",
      data_size = "icon-sm",
      `aria-label` = "Close dialog",
      onclick = paste0("this.closest('dialog').close()"),
      HTML(
        '<svg class="lucide lucide-x" xmlns="http://www.w3.org/2000/svg" width="24" ',
        'height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" ',
        'stroke-width="2" stroke-linecap="round" stroke-linejoin="round">',
        '<path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>'
      )
    )
  )

  # Build the dialog element
  dialog <- tags$dialog(
    id = id,
    class = "dialog",
    `aria-labelledby` = if (!is.null(title)) title_id,
    `aria-describedby` = if (!is.null(description)) desc_id,
    onclick = if (close_on_click) paste0("if (event.target === this) this.close()"),
    dialog_content
  )

  # Add the open attribute if needed
  if (open) {
    dialog <- htmltools::tagAppendAttributes(dialog, `open` = NA)
  }

  bc_tag(dialog)
}

#' Dialog Trigger Button
#'
#' A button that opens a dialog.
#'
#' @param dialog_id String. The ID of the dialog to open.
#' @param ... Additional attributes passed to the `<button>`.
#' @param aria_label String. Accessible name, needed when the trigger has no
#'   visible text such as an icon-only button.
#' @return A button that opens the specified dialog.
#' @export
#' @examples
#' bc_dialog_trigger("profile-dialog", "Open Dialog")
bc_dialog_trigger <- function(dialog_id, ..., aria_label = NULL) {
  check_string(dialog_id, allow_empty = FALSE)
  check_string(aria_label, allow_null = TRUE, allow_empty = FALSE)

  bc_tag(tags$button(
    type = "button",
    `aria-label` = aria_label,
    onclick = paste0("document.getElementById('", dialog_id, "').showModal()"),
    ...
  ))
}