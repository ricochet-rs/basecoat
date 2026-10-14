# basecoat 0.1.0

* Initial CRAN release.
* `bc_page_sidebar()` and `bc_page_navbar()` create full pages, and `bc_page()` writes a page as a string for servers.
* Components cover buttons, forms, menus, dialogs, toasts, tabs, and sidebars.
* `bc_deps()` adds the bundled stylesheet and scripts, with a choice of style pack or your own theme.
* `bc_shiny_deps()` adds Shiny inputs for `bc_radio_group()`, `bc_slider()`, `bc_select()`, `bc_combobox()`, and `bc_accordion()`.
* `bc_update_radio_group()`, `bc_update_slider()`, `bc_update_select()`, `bc_update_combobox()`, `bc_update_accordion()`, and `bc_update_theme_switcher()` change those inputs from a Shiny server.
* `bc_theme_builder()` builds a theme in your browser and imports themes from tweakcn.
* Components render at the console and in knitr and Quarto without a `bc_deps()` call.
