# CLAUDE.md

## Generated files

Never edit `man/*.Rd` or `NAMESPACE` by hand. Edit the roxygen in `R/` and run
`just document`.

## Icons

Phosphor only, never Lucide. Paths live in `R/icons.R`, copied from
`node_modules/@phosphor-icons/core/assets/`.

## NEWS.md

Keep every bullet to one line. Only add an entry for a genuinely new exported
function or feature, never for a change to an existing one (a bug fix, a new
optional argument, an internal refactor). The package is unreleased
(`0.0.0.9000`, never published), so there is no installed base to narrate
changes against.
