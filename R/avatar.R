# An avatar is `<span class="avatar">` with the image first and a fallback
# `<span>` after it, so a missing or slow image falls back to initials. A badge
# is a further `<span class="avatar-badge">`, and a group is a parent
# `<div class="avatar-group">` that overlaps its children.

bc_avatar_sizes <- c("default", "sm", "lg")

#' Avatar
#'
#' A small round image with an initials fallback.
#'
#' @param ... Tag attributes and children, passed to [htmltools::span()].
#' @param src String. The image URL, or `NULL` for initials only.
#' @param alt String. Alt text for the image.
#' @param fallback String. Initials or short text shown when the image is
#'   absent.
#' @param size String. One of `r toString(bc_avatar_sizes)`. `default` writes no
#'   attribute.
#' @param badge A [bc_avatar_badge()], or `NULL`.
#' @return A `<span>` tag.
#' @export
#' @examples
#' bc_avatar(src = "https://github.com/shadcn.png", alt = "@shadcn", fallback = "CN")
#'
#' bc_avatar(fallback = "JP", size = "lg")
bc_avatar <- function(...,
                      src = NULL,
                      alt = NULL,
                      fallback = NULL,
                      size = "default",
                      badge = NULL) {
  size <- arg_match(size, bc_avatar_sizes)
  check_string(src, allow_null = TRUE, allow_empty = FALSE)
  check_string(alt, allow_null = TRUE)
  check_string(fallback, allow_null = TRUE, allow_empty = FALSE)

  bc_tag(span(
    class = "avatar",
    `data-size` = if (size != "default") size,
    ...,
    if (!is.null(src)) tags$img(src = src, alt = alt),
    if (!is.null(fallback)) span(fallback),
    badge
  ))
}

#' @rdname bc_avatar
#' @param count Text or an icon shown after the last avatar, or `NULL`.
#' @export
#' @examples
#'
#' bc_avatar_group(
#'   bc_avatar(fallback = "CN"),
#'   bc_avatar(fallback = "LR"),
#'   count = "+3"
#' )
bc_avatar_group <- function(..., count = NULL) {
  bc_tag(div(
    class = "avatar-group",
    ...,
    if (!is.null(count)) span(`data-count` = NA, count)
  ))
}

#' @rdname bc_avatar
#' @export
#' @examples
#'
#' bc_avatar(
#'   fallback = "CN",
#'   badge = bc_avatar_badge(class = "bg-green-600")
#' )
bc_avatar_badge <- function(...) {
  bc_tag(span(class = "avatar-badge", ...))
}
