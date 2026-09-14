# Basecoat served from a nanonext HTTP server, with the stylesheet and scripts
# served out of the installed package rather than pulled from a CDN.
#
#   source(system.file("examples", "nanonext.R", package = "basecoat"))
#
# `bc_deps()` points at files inside the package, so a server that hands them
# out needs a route of its own for `/basecoat/...`. That is the whole of the
# integration: everything else is the same markup any other backend writes.
# The CDN is deliberately not used here, since its stylesheets carry only the
# utilities Basecoat's own source needs and several components lay out wrong
# from them.
#
# The echo route below shows the other half, a component posting to the server
# and rendering what comes back.

library(nanonext)
library(basecoat)
library(htmltools)

assets <- system.file("basecoat", package = "basecoat")
style <- "vega"

page <- tagList(
  tags$head(
    tags$meta(charset = "utf-8"),
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"),
    tags$title("Basecoat with nanonext"),
    htmltools::renderDependencies(
      list(bc_deps(style = style, js = TRUE, source = "/basecoat/")),
      "href"
    )
  ),
  tags$body(
    tags$main(
      class = "prose mx-auto flex max-w-2xl flex-col gap-6 p-8",
      tags$h1("Basecoat with nanonext"),
      tags$p("Every asset on this page is served from the installed R package."),
      bc_card(
        bc_card_header(
          tags$h2("Echo"),
          tags$p("Posts to /api/echo and renders the reply.")
        ),
        bc_card_body(
          class = "flex flex-col gap-4",
          bc_input(id = "name", label = "Your name", placeholder = "Ada Lovelace"),
          bc_button("Send", id = "send"),
          tags$pre(id = "reply")
        )
      )
    ),
    tags$script(HTML("
      document.getElementById('send').addEventListener('click', async () => {
        const res = await fetch('/api/echo', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ name: document.getElementById('name').value })
        });
        document.getElementById('reply').textContent =
          JSON.stringify(await res.json(), null, 2);
      });
    "))
  )
)

# Anything under /basecoat/ comes straight out of the package directory.
serve_asset <- function(req) {
  file <- file.path(assets, sub("^/basecoat/", "", req$uri))
  if (!file.exists(file)) {
    return(list(status = 404L, body = "Not found"))
  }

  type <- if (grepl("\\.css$", file)) "text/css" else "application/javascript"
  list(
    status = 200L,
    headers = list("Content-Type" = type),
    body = readBin(file, "raw", file.size(file))
  )
}

server <- http_server(
  url = "http://127.0.0.1:8080",
  handlers = list(
    handler("/", function(req) {
      list(
        status = 200L,
        headers = list("Content-Type" = "text/html"),
        body = paste0("<!doctype html>", as.character(page))
      )
    }),
    handler("/basecoat/...", serve_asset),
    handler("/api/echo", function(req) {
      if (!identical(req$method, "POST")) {
        return(list(status = 405L, headers = list(Allow = "POST"), body = "Method not allowed"))
      }
      list(
        status = 200L,
        headers = list("Content-Type" = "application/json"),
        body = jsonlite::toJSON(
          list(received = req$body, at = format(Sys.time())),
          auto_unbox = TRUE
        )
      )
    })
  )
)

server$start()
cat("Serving http://127.0.0.1:8080 — call server$close() to stop.\n")
