// app/javascript/view_sections.js
function initViewSections() {
  const buttons = document.querySelectorAll(".toggle-sections");
  buttons.forEach((btn) => {
    if (btn.dataset.bound === "1") return;
    btn.dataset.bound = "1";

    btn.addEventListener("click", (e) => {
      e.preventDefault();
      const targetId = btn.dataset.target;
      if (!targetId) return;

      const panel = document.getElementById(targetId);
      if (!panel) return;

      panel.classList.toggle("hidden");
      btn.textContent = panel.classList.contains("hidden") ? "View Sections" : "Hide Sections";
    });
  });
}

document.addEventListener("turbo:load", initViewSections);
document.addEventListener("DOMContentLoaded", initViewSections);
