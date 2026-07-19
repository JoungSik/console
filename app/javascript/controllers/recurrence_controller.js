import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "endsOnField"]

  connect() {
    this.toggle()
  }

  toggle() {
    const hasRecurrence = this.selectTarget.value !== ""
    this.endsOnFieldTarget.classList.toggle("hidden", !hasRecurrence)
  }
}
