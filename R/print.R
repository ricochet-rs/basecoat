# Components carry a class of their own so that printing one at the console can
# show it rendered. The dependency is attached at print time rather than built
# into the tag, so composing components never accumulates copies of it and never
# fights a style the caller asked for.

bc_tag <- function(x) {
  if (inherits(x, "bc_tag")) {
    return(x)
  }

  class(x) <- c("bc_tag", class(x))
  x
}

#' Render a component at the console
#'
#' Prints a component to the viewer with the Basecoat stylesheet and scripts
#' attached, or writes its HTML when there is nowhere to show it.
#'
#' @param x A component.
#' @param browse Bool. Show the rendered component rather than its HTML.
#' @param ... Ignored.
#' @return `x`, invisibly.
#' @details
#' The dependency is [bc_deps()] with its defaults, so a preview is always the
#' Vega pack. Wrap the component yourself to see another one.
#' @export
#' @examples
#' print(bc_badge("stable"), browse = FALSE)
print.bc_tag <- function(x, browse = interactive(), ...) {
  if (!browse) {
    cat(format(x), "\n", sep = "")
    return(invisible(x))
  }

  htmltools::html_print(
    htmltools::browsable(htmltools::attachDependencies(x, bc_deps())),
    background = "var(--background)"
  )

  invisible(x)
}

#' @exportS3Method knitr::knit_print
#' @noRd
knit_print.bc_tag <- function(x, ...) {
  x <- htmltools::attachDependencies(x, bc_deps(), append = TRUE)
  class(x) <- setdiff(class(x), "bc_tag")
  knitr::knit_print(x, ...)
}
