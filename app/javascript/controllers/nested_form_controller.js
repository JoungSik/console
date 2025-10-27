import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["addButton", "template", "item", "destroyField"]
  static values = { wrapperSelector: String }

  add_association(event) {
    event.preventDefault()

    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    const wrapper = this.wrapperSelectorValue ?
      document.querySelector(this.wrapperSelectorValue) :
      this.element.querySelector('[data-nested-form-target="item"]').parentElement

    wrapper.insertAdjacentHTML('afterbegin', content)
  }

  remove_association(event) {
    event.preventDefault()
    
    const item = event.target.closest('[data-nested-form-target="item"]')
    const destroyField = item.querySelector('[data-nested-form-target="destroyField"]')
    
    if (destroyField) {
      destroyField.value = "1"
      item.style.display = 'none'
    } else {
      item.remove()
    }
  }
}