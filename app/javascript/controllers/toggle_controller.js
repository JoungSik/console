import { Controller } from "@hotwired/stimulus"

// data-controller="toggle"를 사용하여 요소를 토글합니다.
// data-toggle-target-value="#element-id"로 토글할 요소를 지정합니다.
export default class extends Controller {
  static values = { target: String }

  toggle(event) {
    event.preventDefault()
    const target = document.querySelector(this.targetValue)
    if (target) {
      target.classList.toggle("hidden")
    }
  }
}
