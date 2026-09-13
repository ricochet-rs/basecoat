// Shiny input bindings for the basecoat components Shiny cannot already read on
// its own: a radio group (shared `name`, no wrapper Shiny recognises), a slider
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
      }
    },
    getState(el) {
      return { value: this.getValue(el) };
    },
  });
  inputBindings.register(radioGroupBinding, "basecoat.radioGroup");

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
      getValue(el) {
        return el.value;
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

  inputBindings.register(widgetBinding("select"), "basecoat.select");
  inputBindings.register(widgetBinding("combobox"), "basecoat.combobox");
})();
