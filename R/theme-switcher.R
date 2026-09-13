# The theme switcher is an icon button wired to the runtime's theme API. The
# two lucide SVGs hide behind `dark:` styled spans: the sun shows only in dark
# mode and the moon only in light mode. The swap relies on Tailwind utilities
# that Basecoat does not ship, so the button attaches them as a head dependency
# and stands no Tailwind build in the way of a page that uses it.

bc_theme_switcher_icons <- list(
  sun = paste0(
    '<svg class="lucide lucide-sun" xmlns="http://www.w3.org/2000/svg" width="24" ',
    'height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" ',
    'stroke-width="2" stroke-linecap="round" stroke-linejoin="round">',
    '<circle cx="12" cy="12" r="4" />',
    '<path d="M12 2v2" /><path d="M12 20v2" />',
    '<path d="m4.93 4.93 1.41 1.41" /><path d="m17.66 17.66 1.41 1.41" />',
    '<path d="M2 12h2" /><path d="M20 12h2" />',
    '<path d="m6.34 17.66-1.41 1.41" /><path d="m19.07 4.93-1.41 1.41" />',
    '</svg>'
  ),
  moon = paste0(
    '<svg class="lucide lucide-moon" xmlns="http://www.w3.org/2000/svg" width="24" ',
    'height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" ',
    'stroke-width="2" stroke-linecap="round" stroke-linejoin="round">',
    '<path d="M20.985 12.486a9 9 0 1 1-9.473-9.472c.405-.022.617.46.402.803',
    'a6 6 0 0 0 8.268 8.268c.344-.215.825-.004.803.401" />',
    '</svg>'
  )
)

#' Theme Switcher
#'
#' A button that flips the `dark` class on `<html>`, toggling the page theme.
#'
#' @param ... Tag attributes and children for the `<button>`.
#' @return A `<button>` tag with the theme utilities attached.
#' @details
#' Ships the Tailwind utilities the sun and moon swap on (`hidden`, `block`,
#' `dark:block`, `dark:hidden`, `size-8`) as a head dependency, so a page needs
#' no Tailwind build. The Basecoat runtime behind [bc_deps()] drives the toggle,
#' and a bundled script applies the stored mode on load.
#' @export
#' @examples
#' bc_theme_switcher()
bc_theme_switcher <- function(...) {
  button <- tags$button(
    type = "button",
    `aria-label` = "Toggle dark mode",
    `data-tooltip` = "Toggle dark mode",
    `data-side` = "bottom",
    onclick = "window.basecoat.theme.toggle()",
    class = "btn size-8",
    `data-variant` = "outline",
    `data-size` = "icon",
    ...,
    span(class = "hidden dark:block", HTML(bc_theme_switcher_icons$sun)),
    span(class = "block dark:hidden", HTML(bc_theme_switcher_icons$moon))
  )

  bc_tag(htmltools::attachDependencies(
    button,
    c(bc_script_dep(), list(bc_theme_switcher_shim()))
  ))
}

# The utilities and initial-mode script behind the button, as a dependency so
# several switchers on one page render them once.
bc_theme_switcher_shim <- function() {
  htmltools::htmlDependency(
    name = "basecoat-theme-switcher",
    version = bc_version,
    src = c(file = "basecoat"),
    package = "basecoat",
    # Nothing but the head is served, so no file is copied out of the package.
    all_files = FALSE,
    head = HTML(c(
      "<style>",
      ".size-8 { width: 2rem; height: 2rem; }",
      ".block { display: block; }",
      ".hidden { display: none; }",
      ".dark .dark\\:block { display: block; }",
      ".dark .dark\\:hidden { display: none; }",
      "</style>",
      "<script>",
      "(function () {",
      "  try {",
      '    var stored = localStorage.getItem("themeMode");',
      '    if (stored ? stored === "dark" : matchMedia("(prefers-color-scheme: dark)").matches) {',
      '      document.documentElement.classList.add("dark");',
      "    }",
      "  } catch (_) {}",
      "})();",
      "</script>"
    ))
  )
}