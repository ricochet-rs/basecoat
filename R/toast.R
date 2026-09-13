#' Toast
#'
#' A stack of transient notifications appended to a toaster.
#'
#' @param title String. The toast's title.
#' @param ... Content shown under the title before any description.
#' @param description String. A description under the title.
#' @param category String. One of `info`, `success`, `warning` or `error`. Sets
#'   styling and the default icon.
#' @param duration Number. Milliseconds before the toast closes, or `-1` to
#'   keep it open. Defaults to `3000`, or `5000` for `error` toasts.
#' @param action A list. Primary action with `label` and `href` or `onclick`.
#' @param cancel A list. Secondary action with `label` and optional `onclick`.
#' @param icon A tag. An icon before the text, replacing the category default.
#' @return A `<div class="toast">` ready to append to a toaster.
#' @details
#' Append the returned markup to a [bc_toaster()], or create toasts from
#' JavaScript with `toaster.toast(config)`.
#' @export
#' @examples
#' bc_toast(
#'   "Saved",
#'   description = "Your changes are in place.",
#'   category = "success",
#'   cancel = list(label = "Dismiss")
#' )
#'
#' bc_toaster(
#'   bc_toast("Upload failed", category = "error"),
#'   align = "start"
#' )
bc_toast <- function(title,
                     ...,
                     description = NULL,
                     category = "info",
                     duration = NULL,
                     action = NULL,
                     cancel = NULL,
                     icon = NULL) {
  check_string(title, allow_empty = FALSE)
  check_string(description, allow_null = TRUE, allow_empty = TRUE)
  category <- arg_match(category, c("info", "success", "warning", "error"))
  check_number_whole(duration, min = -1, allow_null = TRUE)

  if (is.null(duration)) {
    duration <- if (category == "error") 5000 else 3000
  }

  footer <- if (!is.null(action) || !is.null(cancel)) {
    tags$footer(
      if (!is.null(cancel)) toast_action(cancel),
      if (!is.null(action)) toast_action(action)
    )
  }

  bc_tag(div(
    class = "toast",
    role = "status",
    `aria-atomic` = "true",
    `aria-hidden` = "false",
    `data-category` = category,
    `data-duration` = duration,
    div(
      class = "toast-content",
      if (is.null(icon)) toast_icon(category) else icon,
      tags$section(
        tags$h2(title),
        ...,
        if (!is.null(description)) p(description)
      ),
      footer
    )
  ))
}

#' @rdname bc_toast
#' @param id String. The ID for the toaster.
#' @param align String. Placement of the stack. One of `start`, `center` or
#'   `end`.
#' @return A `<div id="...">` of class `toaster` ready to hold toasts.
#' @details
#' Add one toaster near the end of the page body and append [bc_toast()]
#' markup to it.
#' @export
bc_toaster <- function(..., id = "toaster", align = "end") {
  align <- arg_match(align, c("start", "center", "end"))
  check_string(id, allow_empty = FALSE)

  bc_tag(htmltools::attachDependencies(
    div(
      id = id,
      class = "toaster",
      `data-align` = align,
      ...
    ),
    bc_script_dep("toast")
  ))
}

#' @rdname bc_toast
#' @param label String. The trigger button's label.
#' @param get String. URL of the fragment endpoint that returns [bc_toast()]
#'   markup.
#' @param toaster String. CSS selector of the [bc_toaster()] to append into.
#' @param variant String. Button variant, defaulting to `outline`.
#' @param size String. Button size, defaulting to `default`.
#' @return A `<button>` tag that fetches a server-rendered toast fragment.
#' @details
#' The button fetches the fragment and appends it into the toaster with
#' `hx-swap = "beforeend"`, so the Toast script mounts it. Serve the endpoint
#' with htmxr's `htmx` serializer, for example a plumber2 route returning
#' `bc_toast()`.
#' @export
#' @examples
#' bc_toast_trigger(
#'   "Toast from backend (with HTMX)",
#'   get = "/fragments/toast/success"
#' )
bc_toast_trigger <- function(label,
                             ...,
                             get,
                             toaster = "#toaster",
                             variant = "outline",
                             size = "default") {
  check_string(label, allow_empty = FALSE)
  check_string(get, allow_empty = FALSE)
  check_string(toaster, allow_empty = FALSE)
  variant <- arg_match(variant, bc_button_variants)
  size <- arg_match(size, bc_button_sizes)

  bc_tag(tags$button(
    type = "button",
    class = "btn",
    `data-variant` = if (variant != "primary") variant,
    `data-size` = if (size != "default") size,
    `hx-get` = get,
    `hx-trigger` = "click",
    `hx-select` = "unset",
    `hx-target` = toaster,
    `hx-swap` = "beforeend",
    label,
    ...
  ))
}

toast_action <- function(action) {
  if (is.null(action$label)) {
    cli::cli_abort("Toast actions need a {.arg label}.", call = rlang::caller_env())
  }

  tag <- if (!is.null(action$href)) tags$a else tags$button

  tag(
    type = if (is.null(action$href)) "button",
    class = "btn",
    `data-toast-action` = NA,
    href = action$href,
    onclick = action$onclick,
    action$label
  )
}

toast_icon <- function(category) {
  paths <- c(
    info = '<circle cx="12" cy="12" r="10" /><path d="M12 16v-4" /><path d="M12 8h.01" />',
    success = '<circle cx="12" cy="12" r="10" /><path d="m9 12 2 2 4-4" />',
    warning = '<path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 20h16a2 2 0 0 0 1.73-2" /><path d="M12 9v4" /><path d="M12 17h.01" />',
    error = '<circle cx="12" cy="12" r="10" /><path d="m15 9-6 6" /><path d="m9 9 6 6" />'
  )

  HTML(paste0(
    '<svg aria-hidden="true" xmlns="http://www.w3.org/2000/svg" width="24" height="24" ',
    'viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" ',
    'stroke-linecap="round" stroke-linejoin="round">',
    paths[[category]],
    "</svg>"
  ))
}