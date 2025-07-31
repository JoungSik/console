import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="alert"
export default class extends Controller {
  static targets = ["alert"]
  static values = { duration: Number };

  connect() {
    this.alertTarget.classList.add("translate-y-[-100%]", "opacity-0", "transition-all", "duration-500");

    setTimeout(() => {
      this.alertTarget.classList.remove("translate-y-[-100%]", "opacity-0");
      this.alertTarget.classList.add("translate-y-0", "opacity-100");
    }, 100);

    this.autoHideTimeout = setTimeout(() => {
      this.hide();
    }, this.durationValue || 5000);
  }

  close() {
    this.hide();
  }

  hide() {
    if (this.autoHideTimeout) {
      clearTimeout(this.autoHideTimeout);
    }

    this.alertTarget.classList.remove("translate-y-0", "opacity-100");
    this.alertTarget.classList.add("translate-y-[-100%]", "opacity-0");

    setTimeout(() => {
      if (this.alertTarget.parentNode) {
        this.alertTarget.parentNode.removeChild(this.alertTarget);
      }
    }, 500);
  }
}
