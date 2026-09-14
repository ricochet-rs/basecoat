# The asset binding. Basecoat ships one stylesheet per style pack and one
# script per interactive component, so choosing a style and a set of components
# is the whole of the configuration.

# The version of basecoat-css these bindings are written against, and the
# version vendored in inst/basecoat. The markup a component function emits is
# only promised to match this release. Bumping it means bumping package.json
# and running `just vendor`.
bc_version <- "1.0.2"

#' The style packs
#'
#' The style packs Basecoat ships, as named on its installation page. All of
#' them are bundled with this package.
#'
#' @format A character vector of `r length(bc_styles)` names.
#' @details
#' `bc_deps(style = )` also takes `"base"`, which is not a pack but the
#' styleless layer underneath them.
#' @export
#' @examples
#' bc_styles
#'
#' lapply(bc_styles, function(style) bc_deps(style, js = FALSE))
bc_styles <- c(
  "vega",
  "nova",
  "maia",
  "lyra",
  "mira",
  "luma",
  "sera",
  "rhea"
)

# What `style` accepts. `base` is the styleless layer: tokens and component
# structure, with the visual decisions left to whoever brings a theme.
bc_style_choices <- c("base", bc_styles)

# The components that need JavaScript. Every other component is CSS only, so
# asking for none of these is a page with no script at all.
bc_scripts <- c(
  "accordion",
  "combobox",
  "command",
  "drawer",
  "dropdown-menu",
  "popover",
  "range",
  "select",
  "sidebar",
  "tabs",
  "toast"
)

#' Basecoat assets
#'
#' The Basecoat stylesheet and scripts as an [htmltools::htmlDependency()],
#' placed in the page `<head>`. Served from the files bundled with this package
#' by default, or from jsDelivr.
#'
#' @section Why not the CDN:
#' Basecoat is authored for Tailwind, and its published stylesheets carry only
#' the utilities Basecoat's own source uses. Several components are documented in
#' plain Tailwind, so from those files a pagination row does not lay out and a
#' spinner does not turn. The bundled stylesheets are built here against the
#' markup these functions write, which is why `source = "local"` is the default.
#'
#' @param style String or `NULL`. A style pack, one of `r toString(bc_styles)`,
#'   or `"base"` for tokens and structure with no visual style at all.
#' @param js `FALSE` by default, since a component function attaches its own
#'   script the moment it appears in the page. `TRUE` for every script, or a
#'   character vector of component names to load beside the runtime, for
#'   markup written by hand rather than with one of this package's functions.
#' @param theme String or `NULL`. Path to a CSS file of your own, loaded after
#'   the style pack so its tokens win. See [bc_theme()].
#' @param source String. `"local"` to serve the bundled files, `"cdn"` to serve
#'   Basecoat's own from jsDelivr, which lays out several components wrong, or a
#'   URL prefix such as `"/basecoat/"` that the bundled directory is served
#'   from.
#' @param viewport Bool. Add the mobile viewport meta tag to the page head.
#' @param version String. The `basecoat-css` release to serve. Only
#'   `r bc_version` is bundled, so any other release needs `source = "cdn"`.
#' @return An [htmltools::htmlDependency()], or a list of two when `theme` is
#'   given.
#' @details
#' Attach it with [htmltools::attachDependencies()], or return it in a
#' [htmltools::tagList()] beside your markup. Call it once per page: a second
#' call with another style is de-duplicated by name and only one wins.
#'
#' Every component function that needs a script, such as [bc_select()] or
#' [bc_sidebar()], attaches its own alongside the shared runtime when it is
#' called, so `bc_deps()` only has to carry the stylesheet. `js` stays around
#' for markup copied from Basecoat's docs and written by hand, which carries no
#' such dependency.
#'
#' `theme` is the whole of custom theming, and it is returned after the
#' stylesheet rather than beside it so its token values win.
#'
#' A style pack still owns component visuals, so a theme changes tokens rather
#' than layout. Every corner radius follows `--radius`, including the toast
#' surface and the badge, which Tailwind would otherwise fix at a literal size.
#'
#' `style = "base"` drops the visual style entirely, leaving tokens and component
#' structure. That is a starting point for writing a style pack, not a way to
#' theme one, since it carries no surfaces, padding or type scale.
#'
#' Basecoat is authored for Tailwind. Load any other Tailwind build before this
#' dependency, never after, or that build resets borders and inputs to their
#' own defaults.
#'
#' @section Serving the files yourself:
#' A server that writes its own HTML, such as plumber2 or ambiorix, never runs
#' htmltools' dependency machinery, so the files have to be put on the wire by
#' hand. Serve the directory `system.file("basecoat", package = "basecoat")`
#' under a path of your own, and name that path as `source`. The dependency
#' then carries the bundled filenames under that prefix, and nothing in the
#' page hardcodes them.
#'
#' ```r
#' plumber2::api_statics(
#'   api,
#'   at = "/basecoat/",
#'   path = system.file("basecoat", package = "basecoat")
#' )
#'
#' htmltools::renderDependencies(list(bc_deps(source = "/basecoat/")), "href")
#' ```
#' @export
#' @examples
#' bc_deps()
#'
#' bc_deps(style = "maia", js = c("select", "toast"))
#'
#' bc_deps(source = "cdn")
#'
#' bc_deps(style = "lyra", source = "/basecoat/")
#'
#' css <- tempfile(fileext = ".css")
#' writeLines(":root { --primary: oklch(0.54 0.16 320); }", css)
#'
#' htmltools::attachDependencies(bc_button("Save"), bc_deps(theme = css))
bc_deps <- function(
  style = NULL,
  js = FALSE,
  theme = NULL,
  source = c("local", "cdn"),
  viewport = TRUE,
  version = bc_version
) {
  style <- style %||% "vega"
  style <- arg_match(style, bc_style_choices)
  if (length(source) > 1) source <- source[[1]]
  check_string(source, allow_empty = FALSE)
  check_bool(viewport)
  check_string(version, allow_empty = FALSE)

  mount <- !source %in% c("local", "cdn")

  if (mount && !grepl("^(/|https?://)", source)) {
    cli::cli_abort(c(
      "{.arg source} must be {.val local}, {.val cdn}, or a URL prefix.",
      i = "A prefix starts with {.val /} or {.val http}, as in {.val /basecoat/}."
    ))
  }

  if (!mount && source == "local" && !identical(version, bc_version)) {
    cli::cli_abort(c(
      "Only {.val {bc_version}} of {.pkg basecoat-css} is bundled.",
      i = "Use {.code source = \"cdn\"} to serve {.val {version}}."
    ))
  }

  # The bundled stylesheets are this package's own Tailwind build, so they carry
  # the utilities the component functions write and the CDN files do not.
  src <- if (mount) {
    c(href = sub("/+$", "", source))
  } else {
    switch(
      source,
      local = c(file = "basecoat"),
      cdn = c(
        href = paste0("https://cdn.jsdelivr.net/npm/basecoat-css@", version, "/dist")
      )
    )
  }

  stylesheet <- if (!mount && source == "cdn") {
    paste0("basecoat-", style, ".cdn.min.css")
  } else {
    paste0("basecoat-", style, ".min.css")
  }

  scripts <- lapply(bc_script_files(js), function(file) {
    list(src = paste0("js/", file), defer = NA)
  })

  dep <- htmltools::htmlDependency(
    name = "basecoat",
    version = version,
    src = src,
    package = if (!mount && source == "local") "basecoat",
    stylesheet = stylesheet,
    script = if (length(scripts)) scripts,
    head = if (viewport) {
      '<meta name="viewport" content="width=device-width, initial-scale=1">'
    },
    all_files = FALSE
  )

  if (is.null(theme)) {
    return(dep)
  }

  # The theme comes second, which is what lets its tokens win.
  list(dep, bc_theme(theme))
}

#' A custom theme stylesheet
#'
#' A CSS file of your own as an [htmltools::htmlDependency()]. Reach for
#' `bc_deps(theme = )` instead, which orders it against the style pack for you.
#'
#' @param path String. Path to a `.css` file defining Basecoat's tokens.
#' @return An [htmltools::htmlDependency()].
#' @details
#' This is the piece on its own, for a page whose [bc_deps()] call lives
#' somewhere else. It has to render after that dependency for its tokens to win.
#'
#' The style pack still owns component visuals, so the file only restates the
#' tokens it changes. Basecoat reads shadcn/ui token names, such as
#' `--background`, `--foreground`, `--primary`, `--border` and `--ring`, from
#' `:root` and from `.dark`. A Tailwind `@theme` block is ignored by the browser
#' and is not needed, since the bundled stylesheet already maps those tokens.
#'
#' The dependency is named after the file, so two different files both load.
#'
#' @section Themes from tweakcn:
#' A tweakcn export works unedited. Its `:root` and `.dark` blocks are the whole
#' of the theme, and they are plain CSS, so a browser reads them and their
#' unlayered declarations beat the style pack's.
#'
#' The rest of the file is Tailwind build syntax that a browser ignores:
#' `@import "tailwindcss"`, `@custom-variant`, `@theme inline` and any
#' `@layer base` block of `@apply` rules. Nothing is lost by that. The bundled
#' stylesheet already maps `--color-primary` to `--primary` and its siblings, and
#' already paints the page background, so the `@theme inline` and `@layer base`
#' blocks would only restate what is there. Deleting them, and the `@import`
#' line that resolves to nothing, saves the browser a failed request.
#'
#' Two things do need doing by hand. A theme that names a web font, such as
#' `--font-sans: DM Sans`, has to load it, since the file only names it. And
#' `letter-spacing` from `--tracking-normal` is applied by an `@apply` rule, so
#' restate it as `body { letter-spacing: var(--tracking-normal) }` to keep it.
#' @export
#' @examples
#' css <- tempfile(fileext = ".css")
#' writeLines(":root { --primary: oklch(0.54 0.16 320); }", css)
#'
#' bc_theme(css)
bc_theme <- function(path) {
  check_string(path, allow_empty = FALSE)

  if (!file.exists(path)) {
    cli::cli_abort("No file at {.path {path}}.")
  }

  path <- normalizePath(path, "/", mustWork = TRUE)
  file <- basename(path)

  # Called outside the namespace, because htmlDependency() warns about absolute
  # paths from one. The warning is aimed at paths baked in at build time, and
  # this one is the caller's own, given at run time.
  local(htmltools::htmlDependency(
    name = paste0("basecoat-theme-", sub("\\.css$", "", file, ignore.case = TRUE)),
    version = "1.0.0",
    src = c(file = dirname(path)),
    stylesheet = file,
    # The file's own directory is the caller's, so copy nothing that sits beside
    # it into the rendered page.
    all_files = FALSE
  ))
}

# Which script files answer a `js` argument. The runtime has to come first when
# individual components are asked for, and is already inside the all-in-one.
bc_script_files <- function(js, call = caller_env()) {
  if (isFALSE(js)) {
    return(character())
  }

  if (isTRUE(js)) {
    return(c("all.min.js", bc_own_scripts))
  }

  js <- arg_match(js, bc_scripts, multiple = TRUE, error_call = call)

  c("basecoat.min.js", paste0(js, ".min.js"), bc_own_scripts)
}

# This package's own, from `srcjs/`, and always last: they correct vendored
# behaviour by listening after it rather than by forking it.
bc_own_scripts <- "nested-popover.js"

# What a component with a script attaches to its own tag, so calling the R
# function is what asks for the script rather than a separate `bc_deps(js = )`
# the caller has to remember. Every dependency is named by what it carries, so
# htmltools de-duplicates the runtime and the nested-popover fix across
# however many components on a page need them, no matter which one loads
# first.
bc_script_dep <- function(name = NULL, popover = FALSE) {
  script_dep <- function(name, file = paste0(name, ".min.js")) {
    htmltools::htmlDependency(
      name = paste0("basecoat-", name),
      version = bc_version,
      src = c(file = "basecoat"),
      package = "basecoat",
      script = list(src = paste0("js/", file), defer = NA),
      all_files = FALSE
    )
  }

  deps <- list(script_dep("runtime", "basecoat.min.js"))

  if (!is.null(name)) {
    deps <- c(deps, list(script_dep(name)))
  }

  if (popover) {
    deps <- c(deps, list(script_dep("nested-popover", "nested-popover.js")))
  }

  deps
}

#' Re-initialise Basecoat after a swap
#'
#' Basecoat initialises its components on load and when new DOM is inserted, so
#' this is only wanted where markup is restored from a cache rather than parsed.
#'
#' @param force Bool. Destroy and rebuild components that are already
#'   initialised, which also clears open menus and focus.
#' @return A `<script>` tag.
#' @details
#' An htmx history restore is the case this exists for: the browser puts back
#' DOM that was already initialised, and only `force` rebuilds it.
#' @export
#' @examples
#' bc_init(force = TRUE)
bc_init <- function(force = FALSE) {
  check_bool(force)

  tags$script(HTML(paste0(
    "window.basecoat.initAll(",
    if (force) "{ force: true }",
    ")"
  )))
}

#' Shiny input bindings
#'
#' JavaScript bindings that let a Shiny app read and update the basecoat
#' inputs Shiny cannot already: [bc_radio_group()], [bc_slider()],
#' [bc_select()] and [bc_combobox()].
#'
#' @return An [htmltools::htmlDependency()].
#' @details
#' Every other basecoat input, [bc_checkbox()], [bc_switch()], [bc_input()],
#' [bc_textarea()] and [bc_native_select()], is a plain native element with an
#' `id`, so Shiny's own input bindings already read and update it as
#' `input$id`. Nothing from this package is needed for those.
#'
#' Attach this beside [bc_deps()] in a Shiny UI, in addition to it rather than
#' instead of it. Outside a Shiny app the script it loads does nothing, since
#' it checks for `Shiny` before registering anything.
#' @export
#' @examples
#' bc_shiny_deps()
bc_shiny_deps <- function() {
  htmltools::htmlDependency(
    name = "basecoat-shiny",
    version = bc_version,
    src = c(file = "basecoat"),
    package = "basecoat",
    script = list(src = "js/shiny.js", defer = NA),
    all_files = FALSE
  )
}
