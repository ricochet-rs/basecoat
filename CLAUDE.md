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

## Prose

Never rewrite or delete prose the author wrote by hand, such as `README.qmd`.
Suggest wording in chat and let the author apply it.

Write roxygen, articles, NEWS, and DESCRIPTION in the author's voice.
Read `README.qmd` and https://josiah.rs/posts/ for it before writing.

- Write conversational, complete sentences.
- Explain why a step is needed: "Because `basecoat` is not a shiny-only package, it must be opted into."
- Set up the reader's situation before the step: "Say you have a plumber API and you need to serve it over https."
- First person, passive voice, uncontracted forms, and "Additionally" are fine.
- Use plain labels for headings, such as "Further theme customization".
- Describe what the R user does, never the HTML a function writes.

Never write:

- Software as a physical object: carries, holds, sits on top of, reaches every, wired, lives in, hides behind.
- Slogans, "X, not Y" contrasts, or sentences that only restate what came before.
- "pick", "takes" for an argument, or a call with an empty argument such as `bc_deps(style = )`.
- Narration of a UI: "Pick your colors for light and dark mode, then select CSS to download theme.css."

Rewrites the author made:

| Draft | Author |
| --- | --- |
| Change the theme, not each component | Further theme customization |
| If your theme names web fonts, load those fonts in your page. | If your theme uses additional web fonts, those need to be imported manually. |
| Edit `theme.css` instead of styling individual components. A changed token updates every component that uses it. | If further customization of a theme is necessary, it should be done in the `theme.css` file for styling tokens. |
| A collapsible `bc_sidebar()` beside a `<main>` region, with a header carrying the sidebar toggle and a title. | Create a page with a collapsible sidebar. |

Use the Oxford comma and put each sentence on its own line.
Run `just syntax` after writing prose.
The `Ricochet` Vale style in `.vale/` enforces these rules.
