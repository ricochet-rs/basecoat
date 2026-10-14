// Shiny input bindings for the basecoat components Shiny cannot already read on
// its own: a radio group (shared `name`, no wrapper Shiny recognises), an
// accordion (open state lives on each `<details>`), the theme switcher, a slider
// (a native range input, not Shiny's ion.rangeslider), and the custom select
// and combobox widgets (state lives on a hidden input inside a styled div).
//
// Every other basecoat input, checkbox, switch, text input, textarea and
// native select, is a plain native element with an id, so Shiny's own
// bindings already read and update it. Loaded outside Shiny, this file does
// nothing: everything is behind the `window.Shiny` guard below.
(() => {
  if (!window.Shiny) return;

  const { InputBinding, inputBindings } = Shiny;

  // A radio group has no single form control, so the value is whichever radio
  // in the group is checked. There is no basecoat script to defer to: the
  // group is styled with CSS alone, so setting `checked` is the whole of it.
  const radioGroupBinding = new InputBinding();
  Object.assign(radioGroupBinding, {
    find(scope) {
      return $(scope).find('[data-slot="radio-group"][id]');
    },
    getValue(el) {
      const checked = el.querySelector('input[type="radio"]:checked');
      return checked ? checked.value : null;
    },
    setValue(el, value) {
      el.querySelectorAll('input[type="radio"]').forEach((radio) => {
        radio.checked = radio.value === value;
      });
    },
    subscribe(el, callback) {
      $(el).on("change.basecoatRadioGroupBinding", 'input[type="radio"]', () => {
        callback(true);
      });
    },
    unsubscribe(el) {
      $(el).off(".basecoatRadioGroupBinding");
    },
    receiveMessage(el, data) {
      if (Object.prototype.hasOwnProperty.call(data, "value")) {
        this.setValue(el, data.value);
        $(el).find('input[type="radio"]').first().trigger("change");
      }
    },
    getState(el) {
      return { value: this.getValue(el) };
    },
  });
  inputBindings.register(radioGroupBinding, "basecoat.radioGroup");

  // An accordion's value is the open items, named by `data-value`. Opening an
  // item fires `toggle`, which does not bubble, so the listener has to capture.
  // accordion.js closes the other items in single mode on that same event.
  const accordionBinding = new InputBinding();
  Object.assign(accordionBinding, {
    find(scope) {
      return $(scope).find("section.accordion[data-input][id]");
    },
    getValue(el) {
      const open = Array.from(
        el.querySelectorAll(":scope > details[open]"),
        (item) => item.dataset.value
      );
      return open.length ? open : null;
    },
    setValue(el, value) {
      const open = [].concat(value ?? []);
      el.querySelectorAll(":scope > details").forEach((item) => {
        item.open = open.includes(item.dataset.value);
      });
    },
    subscribe(el, callback) {
      el._basecoatAccordionToggle = () => callback(false);
      el.addEventListener("toggle", el._basecoatAccordionToggle, true);
    },
    unsubscribe(el) {
      el.removeEventListener("toggle", el._basecoatAccordionToggle, true);
    },
    receiveMessage(el, data) {
      if (Object.prototype.hasOwnProperty.call(data, "open")) {
        this.setValue(el, data.open);
      }
    },
    getState(el) {
      return { open: this.getValue(el) };
    },
  });
  inputBindings.register(accordionBinding, "basecoat.accordion");

  // range.js only keeps the filled-track CSS variable in sync with `.value`,
  // so setting the value from the server still has to fire `input` by hand for
  // the track to redraw.
  const sliderBinding = new InputBinding();
  Object.assign(sliderBinding, {
    find(scope) {
      return $(scope).find('input.input[type="range"][id]');
    },
    getValue(el) {
      return parseFloat(el.value);
    },
    setValue(el, value) {
      el.value = value;
      el.dispatchEvent(new Event("input", { bubbles: true }));
    },
    subscribe(el, callback) {
      $(el).on("input.basecoatSliderBinding", () => callback(true));
    },
    unsubscribe(el) {
      $(el).off(".basecoatSliderBinding");
    },
    receiveMessage(el, data) {
      if (Object.prototype.hasOwnProperty.call(data, "value")) {
        this.setValue(el, data.value);
      }
    },
    getState(el) {
      return { value: this.getValue(el) };
    },
    getRatePolicy() {
      return { policy: "debounce", delay: 250 };
    },
  });
  inputBindings.register(sliderBinding, "basecoat.slider");

  // Select and combobox roots each define a `value` accessor once basecoat's
  // own script initialises them (a string in single mode, an array in
  // multiple mode), and dispatch `change` when it's set through the UI. Both
  // widgets share that shape, so one binding factory covers both.
  const widgetBinding = (className) => {
    const binding = new InputBinding();
    Object.assign(binding, {
      find(scope) {
        return $(scope).find(`div.${className}[id]`);
      },
      // An empty multiple selection is `NULL`, as it is for selectInput().
      getValue(el) {
        const value = el.value;
        return Array.isArray(value) && !value.length ? null : value;
      },
      setValue(el, value) {
        el.value = value;
      },
      subscribe(el, callback) {
        $(el).on(`change.basecoat${className}Binding`, () => callback(false));
      },
      unsubscribe(el) {
        $(el).off(`.basecoat${className}Binding`);
      },
      receiveMessage(el, data) {
        if (Object.prototype.hasOwnProperty.call(data, "value")) {
          this.setValue(el, data.value);
        }
      },
      getState(el) {
        return { value: this.getValue(el) };
      },
    });
    return binding;
  };

  // updateSelectInput() sends `options` as native `<option>` markup, so they
  // are rebuilt as listbox options and select.js re-reads them on refresh.
  // Like a native select, a single select with no placeholder falls back to
  // its first option.
  const selectBinding = widgetBinding("select");
  selectBinding.receiveMessage = function (el, data) {
    const has = (key) => Object.prototype.hasOwnProperty.call(data, key);

    // The label comes as `{ html, deps }` from processDeps(), and an
    // accessible name is text, so only the text of that HTML is kept.
    const trigger = el.querySelector(":scope > button");
    if (has("label") && trigger) {
      const label = document.createElement("template");
      label.innerHTML = data.label?.html ?? data.label ?? "";
      const text = label.content.textContent.trim();
      if (text) {
        trigger.setAttribute("aria-label", text);
      } else {
        trigger.removeAttribute("aria-label");
      }
    }

    if (!has("options")) {
      if (has("value")) this.setValue(el, data.value);
      return;
    }

    const listbox = el.querySelector('[role="listbox"]');
    const multiple = listbox.getAttribute("aria-multiselectable") === "true";
    const template = document.createElement("template");
    template.innerHTML = `<select>${data.options}</select>`;
    const natives = Array.from(template.content.querySelectorAll("option"));

    listbox.replaceChildren(
      ...natives.map((native) => {
        const option = document.createElement("div");
        option.setAttribute("role", "option");
        option.dataset.value = native.value;
        option.textContent = native.textContent;
        return option;
      })
    );

    let chosen = has("value")
      ? [].concat(data.value ?? [])
      : natives.filter((n) => n.hasAttribute("selected")).map((n) => n.value);
    if (!multiple && !chosen.length && !el.dataset.placeholder && natives.length) {
      chosen = [natives[0].value];
    }

    el.querySelector(':scope > input[type="hidden"]').value = multiple
      ? JSON.stringify(chosen)
      : chosen[0] ?? "";
    el.refresh?.();
    $(el).trigger("change");
  };

  inputBindings.register(selectBinding, "basecoat.select");
  inputBindings.register(widgetBinding("combobox"), "basecoat.combobox");

  // The mode is page-wide, so every switcher reports the same value and any
  // one of them can set it. The runtime announces each change on `document`.
  const themeSwitcherBinding = new InputBinding();
  Object.assign(themeSwitcherBinding, {
    find(scope) {
      return $(scope).find('[data-slot="theme-switcher"][id]');
    },
    getValue() {
      return window.basecoat.theme.get();
    },
    setValue(el, value) {
      window.basecoat.theme.set(value);
    },
    subscribe(el, callback) {
      el._basecoatThemeChange = () => callback(false);
      document.addEventListener("basecoat:themechange", el._basecoatThemeChange);
    },
    unsubscribe(el) {
      document.removeEventListener("basecoat:themechange", el._basecoatThemeChange);
    },
    receiveMessage(el, data) {
      if (Object.prototype.hasOwnProperty.call(data, "value")) {
        this.setValue(el, data.value);
      }
    },
    getState(el) {
      return { value: this.getValue(el) };
    },
  });
  inputBindings.register(themeSwitcherBinding, "basecoat.themeSwitcher");

  // Shiny's text binding reads a command menu's search box as is, but
  // updateTextInput() only fires `change`, and command.js filters on `input`.
  $(document).on("change", ".command header input", (event) => {
    event.target.dispatchEvent(new Event("input", { bubbles: true }));
  });
})();
