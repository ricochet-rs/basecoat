# Skeleton is the whole of the CSS-only shape: a root class on a plain element,
# and every other attribute passed straight through. Every component in this
# package is that pattern, so the note belongs here.
#
# htmltools joins duplicate attributes with a space when it renders, so a
# caller's own `class` lands next to the root class with nothing to merge and
# no helper to write. Named arguments in `...` are attributes and unnamed ones
# are children, which is htmltools' own rule rather than one of ours.

#' Skeleton
#'
#' Create a placeholder block shown while content loads.
#'
#' @param ... Tag attributes and content. Set the size with classes, such as
#'   `h-4 w-full`.
#' @return An htmltools tag.
#' @export
#' @examples
#' bc_skeleton(class = "h-4 w-full")
#'
#' bc_skeleton(class = "size-10 shrink-0 rounded-full")
bc_skeleton <- function(...) {
  bc_tag(div(class = "skeleton", ...))
}
