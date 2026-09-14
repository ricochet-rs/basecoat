#' Craft a theme from a few colours
#'
#' Derives a full token set from a primary colour and a background, using
#' prismatic to mix the surfaces, borders and muted text between them.
#'
#' @param primary String. The accent colour, as any name [grDevices::col2rgb()]
#'   understands.
#' @param background String. The light-mode page colour.
#' @param dark_background String. The dark-mode page colour.
#' @param destructive String. The error colour.
#' @param file String or `NULL`. Where to write the CSS. `NULL` returns it.
#' @return The CSS, invisibly when `file` is given.
#' @seealso [bc_theme()], [bc_theme_builder()]
#' @export
#' @examples
#' if (rlang::is_installed("prismatic")) {
#'   cat(substr(bc_create_theme("#7c3aed"), 1, 120))
#' }
bc_create_theme <- function(primary,
                          background = "#ffffff",
                          dark_background = "#0a0a0a",
                          destructive = "#e5484d",
                          file = NULL) {
  check_installed("prismatic", reason = "to derive a palette.")
  check_string(primary, allow_empty = FALSE)
  check_string(background, allow_empty = FALSE)
  check_string(dark_background, allow_empty = FALSE)
  check_string(destructive, allow_empty = FALSE)
  check_string(file, allow_null = TRUE, allow_empty = FALSE)

  css <- paste0(
    theme_block(":root", theme_tokens(primary, background, destructive, 0.03)),
    "\n\n",
    theme_block(".dark", theme_tokens(primary, dark_background, destructive, 0.06))
  )

  if (is.null(file)) {
    return(css)
  }

  writeLines(css, file)
  invisible(css)
}

# Everything is mixed between the page colour and its opposite, so one
# background argument decides whether the set reads light or dark.
theme_tokens <- function(primary, page, destructive, tint) {
  mix <- function(x, y, ratio) as_hex(prismatic::clr_mix(x, y, ratio))

  # Surfaces carry a trace of the accent rather than being neutral grey, which
  # is the difference between a designed palette and one colour on white.
  background <- mix(page, primary, tint)
  ink <- contrast_ink(background)
  surface <- function(ratio) mix(background, primary, ratio)
  edge <- function(ratio) mix(mix(background, ink, ratio), primary, tint * 2)

  c(
    background = background,
    foreground = ink,
    card = surface(0.03),
    `card-foreground` = ink,
    popover = surface(0.03),
    `popover-foreground` = ink,
    primary = as_hex(primary),
    `primary-foreground` = contrast_ink(primary),
    secondary = surface(0.08),
    `secondary-foreground` = ink,
    muted = surface(0.08),
    `muted-foreground` = mix(mix(background, ink, 0.55), primary, tint * 3),
    accent = surface(0.14),
    `accent-foreground` = ink,
    destructive = as_hex(destructive),
    `destructive-foreground` = contrast_ink(destructive),
    border = edge(0.14),
    input = edge(0.14),
    ring = as_hex(primary),
    `chart-1` = as_hex(primary),
    `chart-2` = as_hex(prismatic::clr_rotate(primary, 40)),
    `chart-3` = as_hex(prismatic::clr_rotate(primary, 80)),
    `chart-4` = as_hex(prismatic::clr_rotate(primary, -40)),
    `chart-5` = as_hex(prismatic::clr_rotate(primary, -80)),
    sidebar = surface(0.05),
    `sidebar-foreground` = ink,
    `sidebar-primary` = as_hex(primary),
    `sidebar-primary-foreground` = contrast_ink(primary),
    `sidebar-accent` = surface(0.14),
    `sidebar-accent-foreground` = ink,
    `sidebar-border` = edge(0.14),
    `sidebar-ring` = as_hex(primary)
  )
}

# Black or white, whichever the colour can carry.
contrast_ink <- function(colour) {
  if (prismatic::clr_extract_luminance(colour)[[1]] > 60) "#0a0a0a" else "#fafafa"
}

# prismatic returns 8 digits. The alpha is always FF here and a colour input
# will not take it, so the tokens carry the 6-digit form.
as_hex <- function(colour) {
  substr(as.character(prismatic::color(colour)), 1, 7)
}

theme_block <- function(selector, tokens) {
  paste0(
    selector, " {\n",
    paste0("  --", names(tokens), ": ", unname(tokens), ";", collapse = "\n"),
    "\n}"
  )
}
