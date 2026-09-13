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
#' A block that stands in for content that has not arrived.
#'
#' @param ... Tag attributes and children, passed to [htmltools::div()]. Sizing
#'   is a caller's job: a skeleton has no dimensions of its own.
#' @return A `<div>` tag.
#' @export
#' @examples
#' bc_skeleton(class = "h-4 w-full")
#'
#' bc_skeleton(class = "size-10 shrink-0 rounded-full")
bc_skeleton <- function(...) {
  bc_tag(div(class = "skeleton", ...))
}
