# An empty state is a `section.empty` with a header of optional figure, heading
# and text, and a footer of actions. The CSS styles the common children by
# element name.

#' Empty
#'
#' Create a centred empty state with an optional icon, title, description and
#' actions.
#'
#' @param title String. The title.
#' @param description String. Helper text under the title.
#' @param icon Tag. An icon shown above the title.
#' @param actions Tag or tag list. Buttons or other actions shown below the
#'   text.
#' @param ... Tag attributes, such as `class`.
#' @return An htmltools tag.
#' @export
#' @examples
#' bc_empty(
#'   title = "No Projects Yet",
#'   description = "Create your first project to get started.",
#'   actions = bc_button("Create Project")
#' )
#'
#' bc_empty(
#'   title = "404 Not Found",
#'   description = "The page you are looking for does not exist.",
#'   actions = bc_input_group(
#'     htmltools::tags$input(type = "search", placeholder = "Try searching..."),
#'     htmltools::tags$span(`data-align` = "start", `aria-hidden` = "true")
#'   ),
#'   class = "border border-dashed"
#' )
bc_empty <- function(
  title = NULL,
  description = NULL,
  icon = NULL,
  actions = NULL,
  ...
) {
  check_string(title, allow_null = TRUE, allow_empty = FALSE)
  check_string(description, allow_null = TRUE, allow_empty = FALSE)

  header <- tags$header(
    if (!is.null(icon)) tags$figure(icon),
    if (!is.null(title)) tags$h3(title),
    if (!is.null(description)) p(description)
  )

  footer <- if (!is.null(actions)) tags$footer(actions)

  bc_tag(tags$section(class = "empty", ..., header, footer))
}
