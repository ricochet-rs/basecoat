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
#' bc_dialog_trigger("profile-dialog", class = "btn", "Edit profile")
#'
#' bc_dialog(
#'   id = "profile-dialog",
#'   title = "Edit profile",
#'   description = "Make changes to your profile here.",
#'   content = bc_input(id = "name", label = "Name", value = "Pedro Duarte"),
#'   actions = htmltools::tagList(
#'     bc_dialog_close("Cancel", variant = "outline"),
#'     bc_dialog_close("Save changes")
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
      bc_icon("x")
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
#' bc_dialog_trigger("terms-dialog", class = "btn", "Open Dialog")
#'
#' bc_dialog(
#'   id = "terms-dialog",
#'   title = "Terms",
#'   description = "The dialog the button above opens."
#' )
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
#' @rdname bc_dialog
#' @param label String or tag. The button's label.
#' @param variant String. The button variant, as in [bc_button()].
#' @export
#' @examples
#'
#' bc_dialog_close("Cancel", variant = "outline")
bc_dialog_close <- function(label = "Close", ..., variant = "primary") {
  bc_button(
    label,
    ...,
    variant = variant,
    onclick = "this.closest('dialog').close()"
  )
}
