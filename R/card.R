# A card is structural: only the root and the action carry a class, and the CSS
# finds the header, the content and the footer by element name. So the four
# inner functions are named element builders and nothing more, which is what
# makes an image or a divider between them a caller's business rather than an
# argument here.

#' Card
#'
#' A titled container, built from a header, a body and a footer.
#'
#' @param ... Tag attributes and children. Pass `data-size = "sm"` to
#'   [bc_card()] for a denser card.
#' @return A tag.
#' @details
#' The parts are ordered by where they are written, not by an argument: an
#' `<img>` before [bc_card_header()] is a card with a cover image.
#'
#' [bc_card_header()] takes a heading, an optional `<p>` description and an
#' optional [bc_card_action()], in that order.
#' @export
#' @examples
#' bc_card(
#'   bc_card_header(
#'     htmltools::h2("Production deploy"),
#'     htmltools::p("v1.4.2, 3m 12s"),
#'     bc_card_action(bc_badge("passed"))
#'   ),
#'   bc_card_body(htmltools::p("All 128 checks green.")),
#'   bc_card_footer(htmltools::p("Deployed just now."))
#' )
bc_card <- function(...) {
  bc_tag(div(class = "card", ...))
}

#' @rdname bc_card
#' @export
bc_card_header <- function(...) {
  bc_tag(tags$header(...))
}

#' @rdname bc_card
#' @export
bc_card_body <- function(...) {
  bc_tag(tags$section(...))
}

#' @rdname bc_card
#' @export
bc_card_footer <- function(...) {
  bc_tag(tags$footer(...))
}

#' @rdname bc_card
#' @export
bc_card_action <- function(...) {
  bc_tag(div(class = "card-action", ...))
}
