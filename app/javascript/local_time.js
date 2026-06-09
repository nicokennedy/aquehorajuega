document.addEventListener("turbo:load", () => {
  document.querySelectorAll("[data-local-date]").forEach(el => {
    const iso = el.dataset.localDate;
    const date = new Date(iso);
    const formatted = date.toLocaleDateString(undefined, {
      weekday: "short",
      day: "2-digit",
      month: "2-digit"
    });
    el.textContent = formatted;
  });

  document.querySelectorAll("[data-local-main-time]").forEach(el => {
    const iso = el.dataset.localMainTime;
    const date = new Date(iso);
    const formatted = date.toLocaleTimeString(undefined, {
      hour: "2-digit",
      minute: "2-digit",
      hour12: false
    });
    el.textContent = formatted;
  });
});
