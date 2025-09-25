import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "content"]

  switchTab(event) {
    const clickedTab = event.currentTarget
    const tabName = clickedTab.dataset.tabName

    // Reset all tabs
    this.tabTargets.forEach(tab => {
      tab.classList.remove("border-indigo-500", "text-indigo-600")
      tab.classList.add("border-transparent", "text-gray-500")
    })

    // Activate clicked tab
    clickedTab.classList.remove("border-transparent", "text-gray-500")
    clickedTab.classList.add("border-indigo-500", "text-indigo-600")

    // Hide all content
    this.contentTargets.forEach(content => {
      content.classList.add("hidden")
    })

    // Show selected content
    const activeContent = this.contentTargets.find(content =>
      content.dataset.tabName === tabName
    )
    if (activeContent) {
      activeContent.classList.remove("hidden")
    }
  }
}