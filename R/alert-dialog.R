# An alert dialog interrupts the user with a native `<dialog class="alert-dialog">`
# and expects an explicit action. The trigger calls `showModal()`; actions close
# the dialog from `onclick`.

bc_alert_dialog_sizes <- c("default", "sm")

#' Alert Dialog
#'
#' Create a modal dialog that asks the user to confirm or cancel.
#'
#' @param ... Extra tag attributes for the dialog.
#' @param id String. The dialog's ID. Defaults to a random ID.
#' @param title String. The title.
#' @param description String or tag. Text under the title.
#' @param icon Tag. An icon shown above the title.
#' @param cancel String or list. The cancel button, as a label or a list with
#'   `label` and `variant`. Defaults to `"Cancel"`.
#' @param confirm String or list. The confirm button, in the same form as
#'   `cancel`. Defaults to `"Continue"`.
#' @param size String. `"default"` or `"sm"` for a narrower dialog.
#' @param open Bool. Whether the dialog starts open. Defaults to `FALSE`.
#' @param trigger String. Label for a button that opens the dialog, or `NULL`
#'   for no button.
#' @return An htmltools tag. With a `trigger`, a tag list of the button and
#'   the dialog.
#' @details
#' Both actions close the dialog. `NULL` omits one.
#' @export
#' @examples
#' bc_alert_dialog(
#'   title = "Are you absolutely sure?",
#'   description = "This cannot be undone.",
#'   trigger = "Show Dialog"
#' )
#'
#' bc_alert_dialog(
#'   title = "Delete this chat?",
#'   description = "This cannot be undone.",
#'   confirm = list(label = "Delete", variant = "destructive"),
#'   trigger = "Delete Chat"
#' )
bc_alert_dialog <- function(
  ...,
  id = NULL,
  title = NULL,
  description = NULL,
  icon = NULL,
  cancel = "Cancel",
  confirm = "Continue",
  size = "default",
  open = FALSE,
  trigger = NULL
) {
  size <- arg_match(size, bc_alert_dialog_sizes)
  check_string(id, allow_null = TRUE, allow_empty = FALSE)
  check_string(title, allow_null = TRUE, allow_empty = FALSE)
  check_bool(open)
  check_string(trigger, allow_null = TRUE, allow_empty = FALSE)

  if (is.null(id)) {
    id <- paste0(
      "alert-dialog-",
      paste0(sample(1:9, 8, replace = TRUE), collapse = "")
    )
  }
  if (!is.null(cancel)) {
    cancel <- alert_dialog_action(cancel, "outline")
  }
  if (!is.null(confirm)) {
    confirm <- alert_dialog_action(confirm, "primary")
  }

  title_id <- if (!is.null(title)) paste0(id, "-title")
  desc_id <- if (!is.null(description)) paste0(id, "-description")

  dialog <- tags$dialog(
    id = id,
    class = "alert-dialog",
    `data-size` = if (size != "default") size,
    `aria-labelledby` = title_id,
    `aria-describedby` = desc_id,
    `open` = if (open) NA,
    ...,
    div(
      tags$header(
        if (!is.null(icon)) tags$figure(icon),
        if (!is.null(title)) tags$h2(id = title_id, title),
        if (!is.null(description)) p(id = desc_id, description)
      ),
      tags$footer(
        if (!is.null(cancel)) alert_dialog_button(cancel),
        if (!is.null(confirm)) alert_dialog_button(confirm)
      )
    )
  )

  if (is.null(trigger)) {
    return(bc_tag(dialog))
  }

  bc_tag(tagList(
    tags$button(
      type = "button",
      class = "btn",
      `data-variant` = "outline",
      onclick = paste0("document.getElementById('", id, "').showModal()"),
      trigger
    ),
    dialog
  ))
}

alert_dialog_action <- function(x, variant, call = caller_env()) {
  if (is.character(x)) {
    return(list(label = x, variant = variant))
  }
  if (is.list(x) && !is.null(x$label)) {
    variant <- x$variant %||% variant
    return(list(label = x$label, variant = variant))
  }
  cli::cli_abort(
    "{.arg cancel} and {.arg confirm} must be a label or a list with {.arg label}.",
    call = call
  )
}

alert_dialog_button <- function(action) {
  variant <- arg_match0(action$variant, bc_button_variants)

  bc_button(
    action$label,
    variant = variant,
    onclick = "this.closest('dialog').close()"
  )
}
