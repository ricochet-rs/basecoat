# A badge is `class="badge"` plus a `data-variant` for anything but the default.
# Inline SVG children are spaced by the badge's own gap.

bc_badge_variants <- c(
  "default",
  "secondary",
  "destructive",
  "outline",
  "ghost"
)

#' Badge
#'
#' A small inline status label.
#'
#' @param ... Tag attributes and children, passed to [htmltools::span()]. The
#'   text is a child.
#' @param variant String. One of `r toString(bc_badge_variants)`. `default`
#'   writes no attribute.
#' @return A `<span>` tag.
#' @export
#' @examples
#' bc_badge("stable")
#'
#' bc_badge("wipe", variant = "destructive")
bc_badge <- function(..., variant = "default") {
  variant <- arg_match(variant, bc_badge_variants)

  bc_tag(span(
    class = "badge",
    `data-variant` = if (variant != "default") variant,
    ...
  ))
}
