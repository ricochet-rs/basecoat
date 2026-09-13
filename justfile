default:
  just --list

# Regenerate man/ and NAMESPACE from the roxygen comments.
document:
  Rscript -e 'devtools::document()'

# Install the package into the active library.
install:
  R -q -e 'devtools::install()'

# Build and run R CMD check.
check:
  Rscript -e 'devtools::check()'

# Run the testthat suite.
test:
  Rscript -e 'devtools::test()'

readme:
  quarto render README.qmd --to gfm

# Rebuild inst/basecoat from srcss/, srcjs/ and the basecoat-css scripts.
vendor:
  bun install
  rm -rf inst/basecoat
  mkdir -p inst/basecoat/js
  for style in base vega nova maia lyra mira luma sera rhea; do \
    bunx @tailwindcss/cli --minify \
      --input srcss/$style.css \
      --output inst/basecoat/basecoat-$style.min.css; \
  done
  cp node_modules/basecoat-css/dist/js/*.min.js inst/basecoat/js/
  # Chart has no component function, so nothing can ask for its script.
  rm inst/basecoat/js/chart.min.js
  # This package's own scripts, loaded after the vendored ones so they can
  # correct behaviour rather than fork it.
  cp srcjs/*.js inst/basecoat/js/
  cp node_modules/basecoat-css/LICENSE.md inst/basecoat/LICENSE.md
  du -sh inst/basecoat

# Build the website into _site/ (needs the rd2qmd CLI on PATH).
site:
  R -q -e 'source("dev/site/build.R")'
