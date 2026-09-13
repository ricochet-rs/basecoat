# AGENTS.md

`basecoat` is a shadcn ui system implemented only in tailwind.

**Do not read the source of `basecoat-css` (the CDN files, the npm package, the
dist CSS or JS).** It is not needed to work on this package and wastes the
user's time. The docs are mirrored as markdown in `dev/basecoat-docs/` (one
file per component, plus `installation.md` and `customization.md`); read those.
Refresh a page with `curl -sL https://basecoatui.com/components/<name>.md`.

## Bundled assets

`inst/basecoat/` holds what `bc_deps()` serves. It is built, committed, and never
edited by hand. `just vendor` rebuilds it with `bun`.

The stylesheets are this package's own Tailwind build, one per style, from the
inputs in `srcss/`. Basecoat's published CSS carries only the utilities its own
source uses, so components it documents in plain Tailwind, such as pagination and
the spinner animation, do not render from it. Tailwind scans `R/` and
`inst/examples/*.R`, so **a utility class only works once it appears in a file
listed by `@source` in `srcss/*.css`**. Add a class to a component or an example,
then run `just vendor`. The scripts are copied from `basecoat-css` unchanged.

To move to a new `basecoat-css` release: bump the version in `package.json`, bump
`bc_version` in `R/deps.R`, run `just vendor`, then re-document.

## Components return `bc_tag()`

Every component function wraps its returned tag in `bc_tag()`, which adds the
class that `print.bc_tag()` dispatches on so printing one at the console renders
it. A function that returns another component, such as `bc_checkbox()` returning
`bc_field()`, is already wrapped and needs nothing. `bc_tab()` and
`bc_select_option()` return plain lists rather than tags, so they stay unwrapped.

The dependency is attached when printing, never inside the tag, so composing
components never accumulates copies of it.

## Coding Standards

- Never use `do.call()`
- Never use nested for loops

### The em dash rule

**`–` (space–en/em dash–space) is banned in all code, strings, and documentation.**

### Parameter documentation

**Never duplicate parameter docs.** Always use `@inheritParams` pointing to a function that already documents those parameters:

### Documentation style

**Be ruthlessly concise.** Max two sentences per block (title/description, `@param`, `@return`). No `;`. No em dash (see above). State what a thing does, not what it doesn't do or every edge case — put that in `@details` instead.

`@param` lines follow this structure, where `{...}` is a placeholder for the actual type/value (not literal braces):

```
@param name Value type. Concise definition.
```

Example: `@param name String. Name of the new class.`

### Parameter validation

**Always use rlang standalone checks** for every parameter in a function. These are imported via `R/import-standalone-types-check.R`:

```r
check_string(x, allow_empty = FALSE)
check_bool(x)
check_number_whole(x, min = 1, max = 100)
check_number_decimal(x)
check_character(x, allow_null = TRUE)
check_data_frame(x)
check_function(x)
```

### Error messages

Use `cli::cli_abort()` with `call = error_call` (or `call = rlang::caller_env()`). Use cli inline markup: `{.arg x}`, `{.cls ClassName}`, `{.fn function_name}`, `{.val value}`, `{.code expr}`.

### Base R vs rlang

Prefer the rlang equivalent of a base R function when one exists. In particular, use `rlang::expr()` instead of `quote()`.

## Examples

Runnable examples live in `inst/examples/`, so they ship with the package and
are sourced from it:

```r
source(system.file("examples", "kitchen-sink.R", package = "basecoat"))
```

Each one is standalone: it calls `library(basecoat)`, builds its own page, and
runs itself on the last line. Never `devtools::load_all()` in one.

When adding a new component or function, add it to the appropriate `demo_group`
in `inst/examples/kitchen-sink.R`. A pattern that takes a whole page, such as an
app shell, gets its own file beside it.
