// Opening any popover broadcasts `basecoat:popover`, and every other popover
// closes on it, so a select or combobox inside a popover shuts its own parent.
//
// A popover attaches that listener while initialising and then dispatches
// `basecoat:initialized`, so listening for it is what puts this handler after
// the closing one. Registering at load time would put it first, where the
// close happens afterwards and wins.
(() => {
  const reopen = (popover) => {
    const trigger = popover.querySelector(":scope > button");
    const content = popover.querySelector(":scope > [data-popover]");

    if (!trigger || !content) return;

    trigger.setAttribute("aria-expanded", "true");
    content.setAttribute("aria-hidden", "false");
  };

  const keepOpenFor = (popover) => {
    const onOpen = (event) => {
      // The element is gone once its markup has been swapped out, and its own
      // listeners went with it.
      if (!popover.isConnected) {
        document.removeEventListener("basecoat:popover", onOpen);
        return;
      }

      const source = event.detail && event.detail.source;

      if (source && source !== popover && popover.contains(source)) {
        reopen(popover);
      }
    };

    document.addEventListener("basecoat:popover", onOpen);
  };

  // `basecoat:initialized` does not bubble, so this listens in the capture
  // phase, which reaches an event dispatched on any descendant.
  document.addEventListener(
    "basecoat:initialized",
    (event) => {
      const element = event.target;

      if (element.classList && element.classList.contains("popover")) {
        keepOpenFor(element);
      }
    },
    true
  );
})();
