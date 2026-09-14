bc_token_groups <- list(
  "Primary" = c("background", "foreground", "primary", "primary-foreground"),
  "Secondary and accent" = c(
    "secondary", "secondary-foreground", "accent", "accent-foreground"
  ),
  "Surfaces" = c(
    "card", "card-foreground", "popover", "popover-foreground",
    "muted", "muted-foreground"
  ),
  "Form" = c("border", "input", "ring"),
  "Status" = c("destructive", "destructive-foreground"),
  "Charts" = paste0("chart-", 1:5),
  "Sidebar" = c(
    "sidebar", "sidebar-foreground", "sidebar-primary",
    "sidebar-primary-foreground", "sidebar-accent", "sidebar-accent-foreground",
    "sidebar-border", "sidebar-ring"
  )
)

#' Theme builder
#'
#' A page for building a theme: an input per token, a light and dark pair, a
#' style pack to start from, and the CSS to download.
#'
#' @param style String or `NULL`. The pack selected when the page opens.
#' @param back String. Where the sidebar's link out points.
#' @param file String. Where to write the page.
#' @param browse Bool. Open it when it is written.
#' @return The path, invisibly.
#' @seealso [bc_theme()]
#' @export
#' @examples
#' bc_theme_builder(browse = FALSE, file = tempfile(fileext = ".html"))
bc_theme_builder <- function(style = NULL,
                             back = "https://github.com/ricochet-rs/basecoat",
                             file = tempfile("basecoat-theme-", fileext = ".html"),
                             browse = interactive()) {
  style <- style %||% "ricochet"
  style <- arg_match(style, bc_builder_starts)
  check_string(back, allow_null = TRUE, allow_empty = FALSE)
  check_string(file, allow_empty = FALSE)
  check_bool(browse)

  assets <- paste0(tools::file_path_sans_ext(basename(file)), "_styles")
  dir <- file.path(dirname(file), assets)
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)

  from <- system.file("basecoat", package = "basecoat")
  for (s in bc_styles) {
    file.copy(
      file.path(from, paste0("basecoat-", s, ".min.css")),
      dir,
      overwrite = TRUE
    )
  }
  file.copy(
    system.file("themes", "ricochet.css", package = "basecoat"),
    dir,
    overwrite = TRUE
  )

  page <- tagList(
    theme_builder_links(assets, style),
    tags$style(id = "theme-overrides"),
    bc_page_sidebar(
      theme_builder_preview(),
      sidebar = do.call(bc_sidebar, c(
        list(id = "tokens", footer = theme_builder_footer(back)),
        lapply(names(bc_token_groups), function(name) {
          do.call(bc_sidebar_group, c(
            list(name),
            lapply(bc_token_groups[[name]], theme_builder_field)
          ))
        })
      )),
      title = "Theme builder",
      header = theme_builder_actions(style)
    ),
    tags$script(theme_builder_script())
  )

  htmltools::save_html(
    htmltools::attachDependencies(page, theme_builder_head()),
    file,
    background = "var(--background)"
  )

  if (browse) {
    utils::browseURL(file)
  }

  invisible(file)
}

# ricochet is lyra plus a token overlay rather than a pack of its own, so the
# two travel together.
bc_builder_starts <- c("ricochet", bc_styles)

theme_builder_links <- function(assets, style) {
  pack <- if (style == "ricochet") "lyra" else style

  links <- vapply(bc_styles, function(s) {
    sprintf(
      '<link rel="stylesheet" data-pack="%s" media="%s" href="%s/basecoat-%s.min.css">',
      s, if (s == pack) "all" else "not all", assets, s
    )
  }, character(1))

  HTML(paste(c(links, sprintf(
    '<link rel="stylesheet" data-overlay="ricochet" media="%s" href="%s/ricochet.css">',
    if (style == "ricochet") "all" else "not all", assets
  )), collapse = "\n"))
}

theme_builder_head <- function() {
  htmltools::htmlDependency(
    name = "basecoat-viewport",
    version = bc_version,
    src = c(href = "."),
    all_files = FALSE,
    head = '<meta name="viewport" content="width=device-width, initial-scale=1">'
  )
}

theme_builder_field <- function(token) {
  div(
    class = "flex items-center gap-2 py-0.5",
    tags$input(
      type = "color",
      class = "input shrink-0",
      id = paste0("tok-", token),
      `data-token` = token,
      `aria-label` = token
    ),
    tags$label(class = "text-xs truncate", `for` = paste0("tok-", token), token)
  )
}

theme_builder_packs <- function(style) {
  do.call(bc_dropdown_menu, c(
    list(bc_dropdown_group("Start from")),
    lapply(bc_builder_starts, function(s) {
      tags$button(
        type = "button",
        role = "menuitemradio",
        `aria-checked` = tolower(s == style),
        `data-pack-option` = s,
        span(`data-indicator` = NA, bc_icon("check")),
        span(s)
      )
    }),
    list(
      trigger = bc_button(
        variant = "outline",
        size = "sm",
        "Pack: ",
        span(id = "pack-label", class = "font-medium", style),
        bc_icon("caret-down", size = 14)
      ),
      align = "start"
    )
  ))
}

theme_builder_footer <- function(back) {
  tagList(
    if (!is.null(back)) {
      tags$a(
        class = "btn w-full justify-start gap-2",
        `data-variant` = "ghost",
        `data-size` = "sm",
        href = back,
        bc_icon("arrow-left", size = 15),
        "Back to basecoat"
      )
    },
    theme_builder_account()
  )
}

theme_builder_account <- function() {
  bc_dropdown_menu(
    bc_dropdown_group(
      "Signed in",
      bc_dropdown_item("Account"),
      bc_dropdown_item("Billing")
    ),
    bc_dropdown_separator(),
    bc_dropdown_item("Log out", variant = "destructive"),
    trigger = bc_button(
      class = "h-auto w-full justify-start gap-2 py-2",
      variant = "ghost",
      bc_avatar(fallback = "AL", size = "sm"),
      div(
        class = "flex min-w-0 flex-col items-start",
        span(class = "truncate text-xs font-medium", "Ada Lovelace"),
        span(class = "text-muted-foreground truncate text-xs", "ada@example.com")
      )
    ),
    side = "top",
    align = "start"
  )
}

theme_builder_actions <- function(style) {
  div(
    class = "flex flex-wrap items-center gap-2",
    theme_builder_packs(style),
    bc_button_group(
      bc_button("Light", variant = "outline", size = "sm",
                `data-mode` = "light", `aria-pressed` = "true"),
      bc_button("Dark", variant = "outline", size = "sm",
                `data-mode` = "dark", `aria-pressed` = "false"),
      aria_label = "Colour scheme"
    ),
    bc_button_group(
      tags$input(
        type = "color",
        class = "input",
        id = "derive-primary",
        value = "#7c3aed",
        `data-size` = "sm",
        `aria-label` = "Primary colour"
      ),
      bc_button("Derive", id = "derive", variant = "outline", size = "sm"),
      bc_button(
        bc_icon("shuffle", size = 15),
        id = "shuffle",
        variant = "outline",
        size = "sm",
        aria_label = "Random palette"
      ),
      aria_label = "Derive from a primary colour"
    ),
    bc_dialog_trigger(
      "tb-import",
      class = "btn",
      `data-variant` = "outline",
      `data-size` = "sm",
      "Import"
    ),
    bc_button(
      bc_icon("download-simple", size = 16),
      "CSS",
      id = "download",
      variant = "outline",
      size = "sm"
    ),
    bc_dialog(
      id = "tb-import",
      title = "Import a theme",
      description = "Paste a tweakcn export, or any CSS with :root and .dark blocks.",
      content = bc_textarea(
        id = "import-css",
        aria_label = "Theme CSS",
        rows = "8",
        class = "font-mono text-xs",
        placeholder = ":root {\n  --background: oklch(1 0 0);\n}"
      ),
      actions = tagList(
        bc_dialog_close("Cancel", variant = "outline"),
        bc_button("Apply", id = "import-apply")
      )
    )
  )
}

theme_builder_stat <- function(title, value, note, pct) {
  bc_card(
    bc_card_header(
      tags$h2(class = "text-xs font-medium", title),
      bc_card_action(bc_badge(note, variant = "secondary"))
    ),
    bc_card_body(
      tags$p(class = "text-2xl font-semibold", value),
      bc_progress(pct, label = title)
    )
  )
}

theme_builder_preview <- function() {
  div(
    class = "flex flex-col gap-4 p-4",
    div(
      class = "grid gap-4 sm:grid-cols-2 lg:grid-cols-4",
      theme_builder_stat("Revenue", "$12,480", "+12%", 74),
      theme_builder_stat("Sessions", "8,214", "+4%", 52),
      theme_builder_stat("Errors", "37", "-8%", 12),
      theme_builder_stat("Uptime", "99.9%", "stable", 99)
    ),
    bc_alert(
      title = "Heads up",
      description = "Every component here reads the tokens in the sidebar.",
      action = bc_button("Dismiss", variant = "outline", size = "sm")
    ),
    div(
      class = "grid gap-4 lg:grid-cols-2",
      bc_card(
        bc_card_header(tags$h2("Buttons and badges")),
        bc_card_body(
          class = "flex flex-col gap-3",
          div(
            class = "flex flex-wrap gap-2",
            bc_button("Primary"),
            bc_button("Secondary", variant = "secondary"),
            bc_button("Outline", variant = "outline"),
            bc_button("Ghost", variant = "ghost"),
            bc_button("Destructive", variant = "destructive")
          ),
          div(
            class = "flex flex-wrap items-center gap-2",
            bc_badge("default"),
            bc_badge("secondary", variant = "secondary"),
            bc_badge("destructive", variant = "destructive"),
            bc_kbd("\u2318K"),
            bc_spinner(size = "5")
          ),
          div(
            class = "flex flex-wrap items-center gap-2",
            bc_avatar_group(
              bc_avatar(fallback = "AL"),
              bc_avatar(fallback = "GB"),
              count = "+3"
            ),
            bc_tooltip("Hover me", text = "A tooltip"),
            bc_dropdown_menu(
              bc_dropdown_item("Profile"),
              bc_dropdown_item("Settings"),
              trigger_label = "Menu"
            ),
            bc_popover(title = "Popover", description = "Anchored content.")
          )
        )
      ),
      bc_card(
        bc_card_header(tags$h2("Form")),
        bc_card_body(
          class = "flex flex-col gap-3",
          bc_input(id = "tb-email", label = "Email", placeholder = "ada@example.com"),
          bc_textarea(id = "tb-bio", label = "Bio", placeholder = "A short bio", rows = "2"),
          bc_select("Apple", "Banana", "Cherry", id = "tb-fruit", placeholder = "Fruit"),
          bc_combobox(
            "tb-framework",
            bc_combobox_option("Next.js"),
            bc_combobox_option("Remix"),
            placeholder = "Framework"
          ),
          bc_checkbox("tb-terms", "Accept terms", checked = TRUE),
          bc_switch("tb-notify", "Notifications", checked = TRUE),
          bc_radio_group(
            name = "tb-plan",
            bc_radio("monthly", "Monthly", checked = TRUE),
            bc_radio("yearly", "Yearly")
          ),
          bc_slider(0, 100, 60, id = "tb-level", aria_label = "Level")
        )
      )
    ),
    div(
      class = "grid gap-4 lg:grid-cols-2",
      bc_card(
        bc_card_header(tags$h2("Navigation")),
        bc_card_body(
          class = "flex flex-col gap-3",
          bc_breadcrumb(
            bc_breadcrumb_item("Home", href = "#"),
            bc_breadcrumb_item("Theme", current = TRUE)
          ),
          bc_tabs(
            bc_tab("Tokens drive every surface.", label = "Overview"),
            bc_tab("Switch light and dark above.", label = "Modes")
          ),
          bc_pagination(
            bc_pagination_previous(),
            bc_pagination_item("1", href = "#", current = TRUE),
            bc_pagination_item("2", href = "#"),
            bc_pagination_next()
          )
        )
      ),
      bc_card(
        bc_card_header(tags$h2("Disclosure and overlays")),
        bc_card_body(
          class = "flex flex-col gap-3",
          bc_accordion(
            bc_accordion_item("What is a token?", "A CSS custom property.", open = TRUE),
            bc_accordion_item("Where do they live?", "In :root and .dark.")
          ),
          div(
            class = "flex flex-wrap gap-2",
            bc_dialog_trigger("tb-dialog", class = "btn", "Dialog"),
            bc_alert_dialog(
              title = "Are you sure?",
              description = "This cannot be undone.",
              trigger = "Alert dialog"
            ),
            bc_drawer("A bottom sheet.", title = "Drawer", trigger = "Drawer")
          ),
          bc_dialog(
            id = "tb-dialog",
            title = "Edit profile",
            description = "Tokens apply inside overlays too.",
            content = bc_input(id = "tb-name", label = "Name", value = "Ada"),
            actions = bc_dialog_close("Close")
          ),
          bc_item_group(
            bc_item(
              title = "Muted surface",
              description = "Secondary text and borders.",
              actions = bc_badge("beta", variant = "secondary"),
              variant = "outline",
              role = "listitem"
            ),
            bc_item(
              title = "Skeleton",
              description = "Loading placeholders.",
              actions = bc_skeleton(class = "h-4 w-16"),
              variant = "outline",
              role = "listitem"
            )
          )
        )
      )
    ),
    bc_card(
      bc_card_header(tags$h2("theme.css")),
      bc_card_body(tags$pre(id = "theme-css", class = "text-xs"))
    )
  )
}

theme_builder_script <- function() {
  tokens <- paste0(
    "[", toString(paste0('"', unlist(bc_token_groups, use.names = FALSE), '"')), "]"
  )

  HTML(sprintf('
const TOKENS = %s;
const theme = { light: {}, dark: {} };
let mode = "light";

const sheet = document.getElementById("theme-overrides");
const root = document.documentElement;

function toHex(value) {
  const ctx = document.createElement("canvas").getContext("2d");
  ctx.fillStyle = "#000";
  ctx.fillStyle = value.trim();
  return ctx.fillStyle;
}

function readPack() {
  sheet.textContent = "";
  for (const which of ["light", "dark"]) {
    root.classList.toggle("dark", which === "dark");
    const styles = getComputedStyle(root);
    for (const token of TOKENS) {
      theme[which][token] = toHex(styles.getPropertyValue("--" + token));
    }
  }
  root.classList.toggle("dark", mode === "dark");
}

function css() {
  const block = (sel, vars) =>
    sel + " {\\n" +
    TOKENS.map((t) => "  --" + t + ": " + vars[t] + ";").join("\\n") +
    "\\n}";
  return block(":root", theme.light) + "\\n\\n" + block(".dark", theme.dark);
}

function render() {
  sheet.textContent = css();
  document.getElementById("theme-css").textContent = css();
  for (const input of document.querySelectorAll("[data-token]")) {
    input.value = theme[mode][input.dataset.token];
  }
}

document.addEventListener("input", (e) => {
  const token = e.target.dataset && e.target.dataset.token;
  if (!token) return;
  theme[mode][token] = e.target.value;
  render();
});

for (const button of document.querySelectorAll("[data-mode]")) {
  button.addEventListener("click", () => {
    mode = button.dataset.mode;
    root.classList.toggle("dark", mode === "dark");
    for (const other of document.querySelectorAll("[data-mode]")) {
      other.setAttribute("aria-pressed", String(other === button));
    }
    render();
  });
}

for (const option of document.querySelectorAll("[data-pack-option]")) {
  option.addEventListener("click", () => {
    const choice = option.dataset.packOption;
    const pack = choice === "ricochet" ? "lyra" : choice;
    for (const link of document.querySelectorAll("[data-pack]")) {
      link.media = link.dataset.pack === pack ? "all" : "not all";
    }
    for (const link of document.querySelectorAll("[data-overlay]")) {
      link.media = choice === "ricochet" ? "all" : "not all";
    }
    for (const other of document.querySelectorAll("[data-pack-option]")) {
      other.setAttribute("aria-checked", String(other === option));
    }
    document.getElementById("pack-label").textContent = choice;
    requestAnimationFrame(() => {
      readPack();
      render();
    });
  });
}

function rgb(hex) {
  return [1, 3, 5].map((i) => parseInt(hex.slice(i, i + 2), 16));
}

function hex(parts) {
  return "#" + parts.map((n) =>
    Math.max(0, Math.min(255, Math.round(n))).toString(16).padStart(2, "0")
  ).join("");
}

function mix(a, b, ratio) {
  const [x, y] = [rgb(a), rgb(b)];
  return hex(x.map((n, i) => n * (1 - ratio) + y[i] * ratio));
}

function luminance(color) {
  const [r, g, b] = rgb(color).map((n) => {
    const v = n / 255;
    return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4);
  });
  return (0.2126 * r + 0.7152 * g + 0.0722 * b) * 100;
}

function ink(color) {
  return luminance(color) > 40 ? "#0a0a0a" : "#fafafa";
}

function fromHsl(h, s, l) {
  const q = l < 0.5 ? l * (1 + s) : l + s - l * s;
  const p = 2 * l - q;
  const channel = (t) => {
    t = (t + 1) %% 1;
    if (t < 1 / 6) return p + (q - p) * 6 * t;
    if (t < 1 / 2) return q;
    if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
    return p;
  };
  return hex([channel(h + 1 / 3), channel(h), channel(h - 1 / 3)].map((n) => n * 255));
}

function toHsl(color) {
  const [r, g, b] = rgb(color).map((n) => n / 255);
  const max = Math.max(r, g, b), min = Math.min(r, g, b);
  const l = (max + min) / 2;
  let h = 0, s = 0;
  if (max !== min) {
    const d = max - min;
    s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
    if (max === r) h = ((g - b) / d + (g < b ? 6 : 0)) / 6;
    else if (max === g) h = ((b - r) / d + 2) / 6;
    else h = ((r - g) / d + 4) / 6;
  }
  return [h, s, l];
}

function rotate(color, deg) {
  const [h, s, l] = toHsl(color);
  return fromHsl((h + deg / 360 + 1) %% 1, s, l);
}

function derive(primary, page, destructive, tint) {
  const background = mix(page, primary, tint);
  const text = ink(background);
  const surface = (ratio) => mix(background, primary, ratio);
  const edge = (ratio) => mix(mix(background, text, ratio), primary, tint * 2);
  return {
    background: background,
    foreground: text,
    card: surface(0.03),
    "card-foreground": text,
    popover: surface(0.03),
    "popover-foreground": text,
    primary: primary,
    "primary-foreground": ink(primary),
    secondary: surface(0.08),
    "secondary-foreground": text,
    muted: surface(0.08),
    "muted-foreground": mix(mix(background, text, 0.55), primary, tint * 3),
    accent: surface(0.14),
    "accent-foreground": text,
    destructive: destructive,
    "destructive-foreground": ink(destructive),
    border: edge(0.14),
    input: edge(0.14),
    ring: primary,
    "chart-1": primary,
    "chart-2": rotate(primary, 40),
    "chart-3": rotate(primary, 80),
    "chart-4": rotate(primary, -40),
    "chart-5": rotate(primary, -80),
    sidebar: surface(0.05),
    "sidebar-foreground": text,
    "sidebar-primary": primary,
    "sidebar-primary-foreground": ink(primary),
    "sidebar-accent": surface(0.14),
    "sidebar-accent-foreground": text,
    "sidebar-border": edge(0.14),
    "sidebar-ring": primary
  };
}

function applyPrimary(primary) {
  document.getElementById("derive-primary").value = primary;
  Object.assign(theme.light, derive(primary, "#ffffff", "#e5484d", 0.03));
  Object.assign(theme.dark, derive(primary, "#0a0a0a", "#e5484d", 0.06));
  render();
}

document.getElementById("derive").addEventListener("click", () => {
  applyPrimary(document.getElementById("derive-primary").value);
});

// Kept off the extremes so the accent stays legible against both pages.
document.getElementById("shuffle").addEventListener("click", () => {
  applyPrimary(fromHsl(
    Math.random(),
    0.45 + Math.random() * 0.35,
    0.38 + Math.random() * 0.16
  ));
});

function parseTheme(text) {
  const found = { light: {}, dark: {} };
  const block = (selector) => {
    const escaped = selector.replace(/[.*+?^${}()|[\\]\\\\]/g, "\\\\$&");
    const match = text.match(new RegExp(escaped + "\\\\s*\\\\{([^}]*)\\\\}"));
    return match ? match[1] : "";
  };
  for (const [which, selector] of [["light", ":root"], ["dark", ".dark"]]) {
    for (const decl of block(selector).split(";")) {
      const at = decl.indexOf(":");
      if (at === -1) continue;
      const name = decl.slice(0, at).trim().replace(/^--/, "");
      const value = decl.slice(at + 1).trim();
      if (TOKENS.includes(name) && value) found[which][name] = toHex(value);
    }
  }
  return found;
}

document.getElementById("import-apply").addEventListener("click", () => {
  const found = parseTheme(document.getElementById("import-css").value);
  for (const which of ["light", "dark"]) Object.assign(theme[which], found[which]);
  render();
  document.getElementById("tb-import").close();
});

document.getElementById("download").addEventListener("click", () => {
  const url = URL.createObjectURL(new Blob([css()], { type: "text/css" }));
  const a = document.createElement("a");
  a.href = url;
  a.download = "theme.css";
  a.click();
  URL.revokeObjectURL(url);
});

readPack();
render();
', tokens))
}
