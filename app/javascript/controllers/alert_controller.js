import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["alert"]
  static values = { duration: Number };

  connect() {
    this.alertTarget.classList.add("translate-y-[-100%]", "opacity-0", "transition-all", "duration-500");

    this.showTimeout = setTimeout(() => {
      this.alertTarget.classList.remove("translate-y-[-100%]", "opacity-0");
      this.alertTarget.classList.add("translate-y-0", "opacity-100");
    }, 100);

    this.autoHideTimeout = setTimeout(() => {
      this.hide();
    }, this.durationValue || 5000);
  }

  disconnect() {
    this.clearTimeouts();
  }

  close() {
    this.hide();
  }

  hide() {
    this.clearTimeouts();

    this.alertTarget.classList.remove("translate-y-0", "opacity-100");
    this.alertTarget.classList.add("translate-y-[-100%]", "opacity-0");

    this.removeTimeout = setTimeout(() => {
      if (this.alertTarget.parentNode) {
        this.alertTarget.parentNode.removeChild(this.alertTarget);
      }
    }, 500);
  }

  clearTimeouts() {
    clearTimeout(this.showTimeout);
    clearTimeout(this.autoHideTimeout);
    clearTimeout(this.removeTimeout);
  }
}
