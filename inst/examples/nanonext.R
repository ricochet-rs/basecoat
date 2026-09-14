# nanonext web server using basecoat
# source(system.file("examples", "nanonext.R", package = "basecoat"))
library(nanonext)
library(basecoat)
library(htmltools)

assets <- system.file("basecoat", package = "basecoat")
style <- "lyra"

page <- bc_page(
  title = "Basecoat with nanonext",
  style = style,
  assets = "/basecoat/",
  tagList(
    tags$main(
      class = "prose mx-auto flex max-w-2xl flex-col gap-6 p-8",
      tags$h1("Basecoat with nanonext"),
      tags$p(
        "CSS and JS are served from the {basecoat} R package"
      ),
      bc_card(
        bc_card_header(
          tags$h2("Echo"),
          tags$p("Posts to /api/echo and renders the reply.")
        ),
        bc_card_body(
          class = "flex flex-col gap-4",
          bc_input(
            id = "name",
            label = "Your name",
            placeholder = "Ada Lovelace"
          ),
          bc_button("Send", id = "send"),
          tags$pre(id = "reply")
        )
      )
    ),
    tags$script(HTML(
      "
      document.getElementById('send').addEventListener('click', async () => {
        const res = await fetch('/api/echo', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ name: document.getElementById('name').value })
        });
        document.getElementById('reply').textContent =
          JSON.stringify(await res.json(), null, 2);
      });
    "
    ))
  )
)

server <- http_server(
  url = "http://127.0.0.1:8080",
  handlers = list(
    handler_inline("/", page, content_type = "text/html"),
    handler_directory("/basecoat", assets),
    handler(
      "/api/echo",
      function(req) {
        list(
          status = 200L,
          headers = c("Content-Type" = "application/json"),
          body = yyjsonr::write_json_str(
            list(
              received = yyjsonr::read_json_raw(req$body),
              at = format(Sys.time())
            ),
            opts = yyjsonr::opts_write_json(auto_unbox = TRUE)
          )
        )
      },
      method = "POST"
    )
  )
)

server$serve()
