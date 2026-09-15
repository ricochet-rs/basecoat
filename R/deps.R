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
#' @param style String or `NULL`. A style pack, one of `r toString(bc_styles)`,
#'   or `"base"` for tokens and structure with no visual style at all.
#' @param js Bool or character vector. `FALSE` by default; components attach
#'   their own scripts. `TRUE` for all of them, or name the ones to load.
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
#' Call once per page. Components attach their own scripts, so `js` is only
#' needed for hand-written markup.
#'
#' Load any other Tailwind build before this one, never after.
#'
#' @section Serving the files yourself:
#' Serve `system.file("basecoat", package = "basecoat")` under a path, then
#' name that path as `source`.
#'
#' ```r
#' plumber2::api_statics(api, at = "/basecoat/", path = system.file("basecoat", package = "basecoat"))
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
  if (length(source) > 1) {
    source <- source[[1]]
  }
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
        href = paste0(
          "https://cdn.jsdelivr.net/npm/basecoat-css@",
          version,
          "/dist"
        )
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
#' Must render after [bc_deps()]. The file needs only the tokens it changes,
#' in `:root` and `.dark`.
#'
#' A tweakcn export works unedited. Web fonts it names still need loading.
#' @seealso [bc_theme_builder()]
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
    name = paste0(
      "basecoat-theme-",
      sub("\\.css$", "", file, ignore.case = TRUE)
    ),
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
#' For htmx history restores, where DOM comes back already initialised.
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
#' Add beside [bc_deps()], not instead of it. Every other input is native, so
#' Shiny already reads it as `input$id`.
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
