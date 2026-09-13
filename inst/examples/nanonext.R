library(nanonext)
library(htmltools)

# Create a simple nanonext server that serves a page with basecoat components
# This example demonstrates how to integrate nanonext with basecoat UI components

# Create a basic HTTP server using nanonext
server <- http_server(
  url = "http://127.0.0.1:8080",
  handlers = list(
    # Serve the main page with basecoat components
    handler("/", function(req) {
      page <- tagList(
        tags$head(
          tags$title("Basecoat with nanonext"),
          # Include basecoat CSS from CDN
          tags$link(rel = "stylesheet", href = "https://cdn.jsdelivr.net/npm/basecoat-css@1.0.2/dist/basecoat.cdn.min.css"),
          # Include basecoat JS for interactive components
          tags$script(src = "https://cdn.jsdelivr.net/npm/basecoat-css@1.0.2/dist/js/all.min.js", defer = TRUE)
        ),
        tags$body(
          tags$div(
            style = "max-width:800px; margin: 0 auto; padding: 2rem;",
            tags$h1("Basecoat with nanonext"),
            tags$p("This page demonstrates a simple web server using nanonext that serves pages with Basecoat UI components."),
            
            # Example of a button component
            bc_button("Click me", id = "my-button"),
            
            # Example of a card component
            bc_card(
              bc_card_header(h2("Example Card")),
              bc_card_body(p("This is an example card using Basecoat components.")),
              bc_card_footer(p("Footer content"))
            ),
            
            # Example of a form with input and button
            bc_field(
              tags$label(`for` = "user-name", "Your Name"),
              bc_input(id = "user-name", placeholder = "Enter your name")
            ),
            bc_button("Submit Form", id = "submit-form", variant = "outline"),
            
            # JavaScript to handle interactions with nanonext
            tags$script(HTML("
              document.addEventListener('DOMContentLoaded', function() {
                const button = document.getElementById('my-button');
                const submitButton = document.getElementById('submit-form');
                
                if (button) {
                  button.addEventListener('click', function() {
                    alert('Button clicked! This demonstrates interaction with nanonext.');
                  });
                }
                
                if (submitButton) {
                  submitButton.addEventListener('click', async function() {
                    const nameInput = document.getElementById('user-name');
                    if (nameInput && nameInput.value) {
                      // Send data to a nanonext endpoint
                      try {
                        // This would normally send to a nanonext endpoint
                        console.log('Sending data to server:', nameInput.value);
                        alert('Form submitted! Data would be sent to nanonext server.');
                      } catch (error) {
                        console.error('Error sending data:', error);
                      }
                    }
                  });
                }
              });
            "))
          )
        )
      )
      
      list(
        status = 200L,
        headers = list("Content-Type" = "text/html"),
        body = as.character(page)
      )
    }),
    
    # API endpoint for nanonext communication
    handler("/api/echo", function(req) {
      # Simple echo endpoint that responds to POST requests
      if (req$method == "POST") {
        body <- req$body
        response_data <- list(
          message = "Echo from nanonext server",
          received = body,
          timestamp = Sys.time()
        )
        
        list(
          status = 200L,
          headers = list("Content-Type" = "application/json"),
          body = jsonlite::toJSON(response_data, auto_unbox = TRUE)
        )
      } else {
        list(
          status = 405L,
          headers = list("Allow" = "POST"),
          body = "Method not allowed"
        )
      }
    })
  )
)

# Start the server
server$start()

cat("Server started at http://127.0.0.1:8080\n")
cat("Try visiting the page or sending a POST request to /api/echo\n")

# Keep the server running (in a real application, you'd have proper shutdown handling)
# For this example, we'll just run for a while
Sys.sleep(30)

# Clean up
server$close()