#!/usr/bin/env Rscript

# Builds the basecoat website. No pkgdown, no Bootstrap: the page shell is
# basecoat's own markup, so basecoat's stylesheet is the only one on the page
# and nothing unlayered outranks it.
#
#   Rscript dev/site/build.R [outdir]
#
# Reference pages come from rd2qmd (https://github.com/eitsupi/rd2qmd), which
# must be on PATH. knitr executes the example and article chunks, so the
# components on the built pages are live.

suppressPackageStartupMessages(library(basecoat))
library(htmltools)

OUT <- commandArgs(trailingOnly = TRUE)[1]
if (is.na(OUT)) {
  OUT <- "_site"
}
WORK <- file.path(tempdir(), "basecoat-site")

`%||%` <- function(x, y) if (is.null(x)) y else x

read_config <- function(path = "_pkgdown.yml") {
  if (requireNamespace("yaml12", quietly = TRUE)) {
    yaml12::read_yaml(path)
  } else {
    yaml::read_yaml(path)
  }
}

DESC <- as.list(read.dcf("DESCRIPTION")[1, ])
REPO <- "https://github.com/ricochet-rs/basecoat"

# ---- icons ------------------------------------------------------------------

# Phosphor ships the raw SVGs, so an icon is the file inlined rather than a
# webfont the page would have to fetch.
icon <- function(name, size = "1.15rem", weight = "regular") {
  path <- file.path(
    "node_modules/@phosphor-icons/core/assets",
    weight,
    paste0(name, ".svg")
  )
  svg <- paste(readLines(path, warn = FALSE), collapse = "")
  svg <- sub(
    "<svg ",
    sprintf('<svg width="%s" height="%s" aria-hidden="true" ', size, size),
    svg
  )
  HTML(svg)
}

# ---- markdown ---------------------------------------------------------------

# rd2qmd writes argument tables as a Quarto `.list-table` div, which commonmark
# does not know. Rewrite it as a basecoat table before the markdown is parsed.
list_tables_to_html <- function(md) {
  lines <- strsplit(md, "\n", fixed = TRUE)[[1]]
  open <- grep("^::: *\\{\\.list-table", lines)
  if (!length(open)) {
    return(md)
  }

  for (i in rev(open)) {
    close <- i + which(trimws(lines[(i + 1):length(lines)]) == ":::")[1]
    block <- lines[(i + 1):(close - 1)]
    lines <- c(
      lines[seq_len(i - 1)],
      list_table_html(block),
      lines[-seq_len(close)]
    )
  }
  paste(lines, collapse = "\n")
}

list_table_html <- function(block) {
  starts <- grep("^- - ", block)
  if (!length(starts)) {
    return("")
  }

  rows <- lapply(seq_along(starts), function(k) {
    from <- starts[k]
    to <- if (k < length(starts)) starts[k + 1] - 1 else length(block)
    chunk <- block[from:to]
    chunk[1] <- sub("^- ", "  ", chunk[1])
    cell_at <- grep("^  - ", chunk)
    vapply(
      seq_along(cell_at),
      function(j) {
        lo <- cell_at[j]
        hi <- if (j < length(cell_at)) cell_at[j + 1] - 1 else length(chunk)
        inline_md(trimws(paste(
          trimws(sub("^  - ", "", chunk[lo:hi])),
          collapse = " "
        )))
      },
      character(1)
    )
  })

  n <- max(lengths(rows))
  cell <- function(x, tag) paste0("<", tag, ">", x, "</", tag, ">")
  head_row <- paste0(
    "<tr>",
    paste(cell(rows[[1]], "th"), collapse = ""),
    "</tr>"
  )
  body_rows <- vapply(
    rows[-1],
    function(r) {
      paste0(
        "<tr>",
        paste(cell(c(r, rep("", n - length(r))), "td"), collapse = ""),
        "</tr>"
      )
    },
    character(1)
  )

  c(
    "",
    paste0(
      '<div class="prose-table"><table class="table" data-size="sm"><thead>',
      head_row,
      "</thead><tbody>",
      paste(body_rows, collapse = ""),
      "</tbody></table></div>"
    ),
    ""
  )
}

inline_md <- function(x) {
  trimws(sub(
    "</p>\\s*$",
    "",
    sub("^\\s*<p>", "", commonmark::markdown_html(x, extensions = TRUE))
  ))
}

render_md <- function(md) {
  # knitr fences component output in html_preserve markers. Hand them to
  # commonmark as opaque tokens: left in place the markup is parsed as
  # markdown, which wraps block elements in a <p> the browser then closes
  # early, and the rest of the page ends up nested inside the component.
  ex <- extractPreserveChunks(md)
  html <- commonmark::markdown_html(
    list_tables_to_html(ex$value),
    extensions = TRUE
  )

  # Anchored while the components are still tokens, so a heading belonging to
  # a card or a toast is never mistaken for a section of the page.
  anchored <- anchor_headings(html)
  html <- as.character(anchored$html)

  for (key in names(ex$chunks)) {
    html <- gsub(paste0("<p>", key, "</p>"), key, html, fixed = TRUE)
  }
  html <- restorePreserveChunks(html, ex$chunks)

  # rd2qmd writes cross-references as `topic.qmd`, which is a page here.
  html <- gsub('href="([^":/]+)\\.qmd"', 'href="\\1.html"', html)

  # downlit only touches `pre.sourceCode.r`, and commonmark puts the language
  # on the inner <code>.
  html <- gsub(
    '<pre><code class="language-r">',
    '<pre class="sourceCode r"><code>',
    html,
    fixed = TRUE
  )

  list(html = HTML(html), toc = anchored$toc)
}

# ---- headings and table of contents -----------------------------------------

slugify <- function(x) {
  x <- tolower(gsub("<[^>]*>", "", x))
  x <- gsub("[^a-z0-9]+", "-", x)
  gsub("^-|-$", "", x)
}

# Give every h2/h3 an id and collect them for the rail. commonmark writes bare
# headings, so the ids have to be added here before anything can link to them.
anchor_headings <- function(html) {
  toc <- list()
  seen <- character()

  out <- gsub("<h([23])>(.*?)</h\\1>", "\\1\x01\\2\x01", html, perl = TRUE)
  parts <- strsplit(out, "\x01", fixed = TRUE)[[1]]

  rebuilt <- html
  m <- gregexpr("<h([23])>(.*?)</h\\1>", html, perl = TRUE)
  hits <- regmatches(html, m)[[1]]

  for (h in hits) {
    level <- sub("^<h([23])>.*$", "\\1", h)
    text <- sub("^<h[23]>(.*)</h[23]>$", "\\1", h)
    id <- slugify(text)
    if (id == "") {
      id <- "section"
    }
    while (id %in% seen) {
      id <- paste0(id, "-")
    }
    seen <- c(seen, id)
    toc[[length(toc) + 1]] <- list(
      level = as.integer(level),
      id = id,
      text = text
    )
    rebuilt <- sub(
      h,
      sprintf('<h%s id="%s">%s</h%s>', level, id, text, level),
      rebuilt,
      fixed = TRUE
    )
  }

  list(html = HTML(rebuilt), toc = toc)
}

toc_rail <- function(toc) {
  if (length(toc) < 2) {
    return(NULL)
  }
  tags$nav(
    class = "rail-block",
    `aria-label` = "On this page",
    tags$p(class = "rail-title", "On this page"),
    tags$ul(
      class = "rail-toc",
      lapply(toc, function(t) {
        tags$li(
          class = if (t$level == 3) "rail-toc-sub",
          tags$a(href = paste0("#", t$id), HTML(t$text))
        )
      })
    )
  )
}

# ---- knitting ---------------------------------------------------------------

# Knit a .qmd to markdown and hand back the html dependencies the chunks asked
# for. Front matter is stripped: the shell owns the page, not pandoc.
knit_to_md <- function(path) {
  knitr::knit_meta(clean = TRUE)
  opts <- knitr::opts_chunk$get()
  on.exit(knitr::opts_chunk$set(opts), add = TRUE)
  knitr::opts_chunk$set(collapse = TRUE, comment = "#>", error = FALSE)

  md <- knitr::knit(
    text = strip_frontmatter(readLines(path, warn = FALSE)),
    quiet = TRUE,
    envir = new.env(parent = globalenv())
  )
  list(md = md, deps = knitr::knit_meta(clean = TRUE))
}

strip_frontmatter <- function(lines) {
  if (!length(lines) || !grepl("^---\\s*$", lines[1])) {
    return(lines)
  }
  close <- which(grepl("^---\\s*$", lines))[2]
  if (is.na(close)) lines else lines[-seq_len(close)]
}

frontmatter <- function(path) {
  lines <- readLines(path, warn = FALSE)
  if (!length(lines) || !grepl("^---\\s*$", lines[1])) {
    return(list())
  }
  close <- which(grepl("^---\\s*$", lines))[2]
  if (is.na(close)) {
    return(list())
  }
  yaml::yaml.load(paste(lines[2:(close - 1)], collapse = "\n"))
}

# The first paragraph under `## Description`, which is the sentence the
# reference index shows beneath each topic's functions.
description_of <- function(md) {
  lines <- strsplit(md, "\n", fixed = TRUE)[[1]]
  at <- grep("^## Description\\s*$", lines)
  if (!length(at)) {
    return("")
  }
  rest <- lines[(at[1] + 1):length(lines)]
  rest <- rest[cumsum(nzchar(rest)) > 0]
  stop_at <- which(grepl("^## ", rest))
  if (length(stop_at)) {
    rest <- rest[seq_len(stop_at[1] - 1)]
  }
  blank <- which(!nzchar(rest))
  if (length(blank)) {
    rest <- rest[seq_len(blank[1] - 1)]
  }
  inline_md(paste(rest, collapse = " "))
}

# ---- style packs ------------------------------------------------------------

# ricochet is lyra plus the token file, so it is a pack and an overlay rather
# than a tenth stylesheet. Everything else is a pack on its own.
SITE_STYLES <- c("ricochet", bc_styles)
DEFAULT_STYLE <- "ricochet"

copy_styles <- function(out) {
  dir <- file.path(out, "deps", "styles")
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)

  from <- system.file("basecoat", package = "basecoat")
  for (s in bc_styles) {
    file.copy(
      file.path(from, paste0("basecoat-", s, ".min.css")),
      dir,
      overwrite = TRUE
    )
  }
  file.copy(
    "dev/site/theme.css",
    file.path(dir, "ricochet.css"),
    overwrite = TRUE
  )
}

# Every pack is on the page, switched with `media` rather than `disabled`. The
# disabled content attribute is honoured inconsistently at parse time, and a
# sheet parsed as disabled may never be fetched at all; `media="not all"`
# always loads and never applies, so a switch is instant.
style_links <- function(depth) {
  root <- strrep("../", depth)
  media <- function(on) if (on) "all" else "not all"

  packs <- vapply(
    bc_styles,
    function(s) {
      sprintf(
        '<link rel="stylesheet" data-style="%s" media="%s" href="%sdeps/styles/basecoat-%s.min.css">',
        s,
        media(s == "lyra"),
        root,
        s
      )
    },
    character(1)
  )

  c(
    packs,
    sprintf(
      '<link rel="stylesheet" data-style="ricochet" media="all" href="%sdeps/styles/ricochet.css">',
      root
    )
  )
}

# Applied before first paint, so a stored choice never flashes the default.
style_script <- HTML(sprintf(
  '
(function () {
  var STYLES = %s;
  var PACK = { ricochet: "lyra" };
  function apply(name) {
    if (STYLES.indexOf(name) === -1) name = "%s";
    var pack = PACK[name] || name;
    document.querySelectorAll("link[data-style]").forEach(function (el) {
      var s = el.dataset.style;
      var on = s === "ricochet" ? name === "ricochet" : s === pack;
      el.media = on ? "all" : "not all";
    });
    document.querySelectorAll("[data-style-option]").forEach(function (el) {
      el.setAttribute("aria-checked", String(el.dataset.styleOption === name));
    });
    try { localStorage.setItem("basecoatStyle", name); } catch (e) {}
  }
  window.basecoatSite = { setStyle: apply };
  var stored;
  try { stored = localStorage.getItem("basecoatStyle"); } catch (e) {}
  apply(stored || "%s");
})();
',
  yyjsonr::write_json_str(SITE_STYLES),
  DEFAULT_STYLE,
  DEFAULT_STYLE
))

style_menu <- function() {
  do.call(
    bc_dropdown_menu,
    c(
      lapply(SITE_STYLES, function(s) {
        tags$button(
          type = "button",
          role = "menuitemradio",
          `aria-checked` = tolower(s == DEFAULT_STYLE),
          `data-style-option` = s,
          onclick = sprintf("window.basecoatSite.setStyle('%s')", s),
          span(`data-indicator` = NA, icon("check", size = "1rem")),
          span(s)
        )
      }),
      list(
        trigger = tags$button(
          class = "btn",
          `data-variant` = "ghost",
          `data-size` = "sm",
          type = "button",
          "Style",
          icon("caret-down", size = ".8rem")
        ),
        align = "end"
      )
    )
  )
}

# ---- page shell -------------------------------------------------------------

site_css <- readLines("dev/site/site.css", warn = FALSE)

navbar <- function(depth, active = NA, articles = list()) {
  root <- strrep("../", depth)
  link <- function(href, label, key) {
    tags$a(
      class = "btn",
      `data-variant` = if (identical(active, key)) "secondary" else "ghost",
      `data-size` = "sm",
      href = paste0(root, href),
      label
    )
  }

  tags$header(
    class = "site-header",
    tags$div(
      class = "site-container",
      tags$div(
        class = "site-brand",
        tags$a(href = paste0(root, "index.html"), "basecoat"),
        bc_badge(DESC$Version, variant = "secondary")
      ),
      tags$nav(
        class = "site-nav",
        link("reference/index.html", "Reference", "reference"),
        do.call(
          bc_dropdown_menu,
          c(
            list(tags$a(
              role = "menuitem",
              href = paste0(root, "articles/index.html"),
              "All articles"
            )),
            list(bc_dropdown_separator()),
            lapply(articles, function(a) {
              tags$a(
                role = "menuitem",
                href = paste0(root, "articles/", a$slug, ".html"),
                a$title
              )
            }),
            list(
              trigger = tags$button(
                class = "btn",
                `data-variant` = if (identical(active, "articles")) {
                  "secondary"
                } else {
                  "ghost"
                },
                `data-size` = "sm",
                type = "button",
                "Articles",
                icon("caret-down", size = ".8rem")
              ),
              align = "end"
            )
          )
        ),
        link("theme/index.html", "Theme", "theme"),
        style_menu(),
        tags$a(
          class = "btn",
          `data-variant` = "ghost",
          `data-size` = "icon",
          href = REPO,
          `aria-label` = "GitHub",
          rel = "noreferrer",
          icon("github-logo")
        ),
        bc_theme_switcher()
      )
    )
  )
}

# The right rail on the home page: what this package actually has, so no CRAN
# link, no citation and no copyright holder.
links_rail <- function() {
  authors <- eval(parse(text = DESC$`Authors@R`))
  creators <- Filter(
    function(p) any(c("aut", "cre") %in% p$role),
    as.list(authors)
  )

  tagList(
    tags$nav(
      class = "rail-block",
      tags$p(class = "rail-title", "Links"),
      tags$ul(
        class = "rail-list",
        tags$li(tags$a(
          href = REPO,
          icon("code", size = "1rem"),
          "Browse source code"
        )),
        tags$li(tags$a(
          href = paste0(REPO, "/issues"),
          icon("bug", size = "1rem"),
          "Report a bug"
        )),
        tags$li(tags$a(
          href = "https://basecoatui.com",
          icon("book-open", size = "1rem"),
          "Basecoat UI"
        ))
      )
    ),
    tags$nav(
      class = "rail-block",
      tags$p(class = "rail-title", "License"),
      tags$ul(
        class = "rail-list",
        tags$li(tags$a(href = paste0(REPO, "/blob/main/LICENSE"), DESC$License))
      )
    ),
    tags$nav(
      class = "rail-block",
      tags$p(class = "rail-title", "Developers"),
      tags$ul(
        class = "rail-list",
        lapply(creators, function(p) {
          tags$li(
            tags$span(
              class = "rail-name",
              format(p, include = c("given", "family"))
            ),
            tags$span(
              class = "rail-role",
              if ("cre" %in% p$role) "Author, maintainer" else "Author"
            )
          )
        })
      )
    )
  )
}

write_page <- function(
  path,
  title,
  body,
  depth,
  rail = NULL,
  active = NA,
  articles = list()
) {
  page <- tagList(
    navbar(depth, active, articles),
    tags$div(
      class = "site-shell site-container",
      tags$main(class = "site-main prose", body),
      if (!is.null(rail)) tags$aside(class = "site-rail", rail)
    )
  )

  # A theme is returned after the style pack so its tokens win. The @theme
  # inline block in the file is Tailwind build syntax a browser ignores: the
  # :root and .dark blocks are the whole of it, and they are plain CSS.
  # The stylesheets are handled by style_links() rather than bc_deps(), since
  # the switcher needs all nine on the page at once and a dependency named
  # "basecoat" would be de-duplicated down to one.
  #
  # knit_print.bc_tag attaches bc_deps() to every component, so a page with
  # rendered examples carries that dependency and would pin the default pack
  # on top of whatever the switcher chose. Only the scripts are wanted here.
  deps <- Filter(
    function(d) !identical(d$name, "basecoat"),
    resolveDependencies(findDependencies(page))
  )
  deps <- lapply(deps, copyDependencyToDir, file.path(OUT, "deps"), FALSE)
  deps <- lapply(deps, makeDependencyRelative, OUT, FALSE)

  root <- strrep("../", depth)
  dep_html <- paste(renderDependencies(deps, "file"), collapse = "\n")
  dep_html <- gsub(
    'href="deps/',
    paste0('href="', root, "deps/"),
    dep_html,
    fixed = TRUE
  )
  dep_html <- gsub(
    'src="deps/',
    paste0('src="', root, "deps/"),
    dep_html,
    fixed = TRUE
  )

  # Assembled by hand rather than with tags$head(): htmltools hoists head
  # content into a slot of its own that as.character() then drops.
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  writeLines(
    c(
      "<!doctype html>",
      '<html lang="en">',
      "<head>",
      '<meta charset="utf-8">',
      '<meta name="viewport" content="width=device-width, initial-scale=1">',
      as.character(tags$title(title)),
      style_links(depth),
      dep_html,
      as.character(tags$style(HTML(paste(site_css, collapse = "\n")))),
      as.character(tags$script(style_script)),
      "</head>",
      "<body>",
      as.character(page),
      "</body>",
      "</html>"
    ),
    path
  )

  # Syntax highlighting and autolinking, in place.
  downlit::downlit_html_path(path, path)
}

# ---- reference --------------------------------------------------------------

build_reference <- function(articles) {
  ref <- file.path(WORK, "reference")
  unlink(ref, recursive = TRUE)
  dir.create(ref, recursive = TRUE, showWarnings = FALSE)

  if (
    system2(
      "rd2qmd",
      c("convert", "man/", "-o", shQuote(ref), "-r", "--frontmatter", "-q")
    ) !=
      0
  ) {
    stop("rd2qmd failed")
  }

  lapply(list.files(ref, pattern = "\\.qmd$", full.names = TRUE), function(f) {
    fm <- frontmatter(f)
    knit <- knit_to_md(f)
    slug <- sub("\\.qmd$", "", basename(f))
    title <- fm$title %||% slug

    parsed <- render_md(knit$md)
    body <- attachDependencies(parsed$html, knit$deps)

    write_page(
      file.path(OUT, "reference", paste0(slug, ".html")),
      title = paste0(title, " — basecoat"),
      body = tagList(tags$h1(title), body),
      depth = 1,
      rail = toc_rail(parsed$toc),
      active = "reference",
      articles = articles
    )

    list(
      slug = slug,
      title = title,
      aliases = as.character(fm$aliases %||% slug),
      description = description_of(knit$md)
    )
  })
}

# ---- articles ---------------------------------------------------------------

article_stubs <- function() {
  lapply(
    list.files("vignettes/articles", pattern = "\\.qmd$", full.names = TRUE),
    function(f) {
      list(
        path = f,
        slug = sub("\\.qmd$", "", basename(f)),
        title = frontmatter(f)$title %||% sub("\\.qmd$", "", basename(f))
      )
    }
  )
}

build_articles <- function(articles) {
  lapply(articles, function(a) {
    knit <- knit_to_md(a$path)
    parsed <- render_md(knit$md)
    body <- attachDependencies(parsed$html, knit$deps)

    write_page(
      file.path(OUT, "articles", paste0(a$slug, ".html")),
      title = paste0(a$title, " — basecoat"),
      body = tagList(tags$h1(a$title), body),
      depth = 1,
      rail = toc_rail(parsed$toc),
      active = "articles",
      articles = articles
    )
    a
  })
}

# ---- indexes ----------------------------------------------------------------

# A pkgdown-shaped list: the topic's functions as code links on one line, the
# Rd description sentence indented under them.
# Data and S3 methods are named as they are; only functions take parentheses.
topic_label <- function(name) {
  obj <- mget(name, envir = asNamespace("basecoat"), ifnotfound = list(NULL))[[
    1
  ]]
  if (is.function(obj) && !grepl("\\.", name)) paste0(name, "()") else name
}

reference_index <- function(cfg, topics, articles) {
  by_slug <- setNames(topics, vapply(topics, function(t) t$slug, character(1)))

  find_topic <- function(name) {
    by_slug[[name]] %||% Find(function(t) name %in% t$aliases, topics)
  }

  sections <- lapply(cfg$reference, function(sec) {
    seen <- character()
    rows <- lapply(sec$contents, function(name) {
      t <- find_topic(name)
      if (is.null(t) || t$slug %in% seen) {
        return(NULL)
      }
      seen <<- c(seen, t$slug)

      tags$li(
        class = "ref-row",
        tags$p(
          class = "ref-names",
          lapply(t$aliases, function(n) {
            tags$a(href = paste0(t$slug, ".html"), tags$code(topic_label(n)))
          })
        ),
        tags$p(class = "ref-desc", HTML(t$description))
      )
    })

    tagList(
      tags$h2(id = slugify(sec$title), sec$title),
      if (!is.null(sec$desc)) tags$p(class = "ref-section-desc", sec$desc),
      tags$ul(class = "ref-list", Filter(Negate(is.null), rows))
    )
  })

  list(
    body = tagList(tags$h1("Reference"), sections),
    toc = lapply(cfg$reference, function(sec) {
      list(level = 2L, id = slugify(sec$title), text = sec$title)
    })
  )
}

articles_index <- function(articles) {
  tagList(
    tags$h1("Articles"),
    tags$ul(
      class = "ref-list",
      lapply(articles, function(a) {
        tags$li(
          class = "ref-row",
          tags$p(
            class = "ref-names",
            tags$a(href = paste0(a$slug, ".html"), a$title)
          )
        )
      })
    )
  )
}

home_body <- function() {
  render_md(paste(readLines("README.md", warn = FALSE), collapse = "\n"))$html
}

# ---- run --------------------------------------------------------------------

main <- function() {
  unlink(OUT, recursive = TRUE)
  dir.create(OUT, recursive = TRUE, showWarnings = FALSE)

  copy_styles(OUT)

  cfg <- read_config()
  articles <- article_stubs()

  topics <- build_reference(articles)
  build_articles(articles)

  write_page(
    file.path(OUT, "index.html"),
    "basecoat",
    home_body(),
    depth = 0,
    rail = links_rail(),
    articles = articles
  )
  ref_index <- reference_index(cfg, topics, articles)
  write_page(
    file.path(OUT, "reference", "index.html"),
    "Reference — basecoat",
    ref_index$body,
    depth = 1,
    rail = toc_rail(ref_index$toc),
    active = "reference",
    articles = articles
  )
  write_page(
    file.path(OUT, "articles", "index.html"),
    "Articles — basecoat",
    articles_index(articles),
    depth = 1,
    active = "articles",
    articles = articles
  )

  # The builder owns a whole viewport, sidebar and all, so it is written as a
  # page of its own rather than poured into the docs shell.
  dir.create(file.path(OUT, "theme"), recursive = TRUE, showWarnings = FALSE)
  bc_theme_builder(
    back = "../index.html",
    file = file.path(OUT, "theme", "index.html"),
    browse = FALSE
  )

  message(sprintf(
    "Built %s: %d topics, %d articles.",
    OUT,
    length(topics),
    length(articles)
  ))
}

main()
