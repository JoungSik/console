import { Controller } from "@hotwired/stimulus"

const BADGE_BASE_CLASSES = "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
const STATUS_TIMEOUT = 5000

export default class extends Controller {
  static targets = ["permissionBadge", "status", "subscriptionBadge", "toggle", "toggleKnob"]

  disconnect() {
    clearTimeout(this.statusTimeout)
  }

  setBusy(busy) {
    if (!this.hasToggleTarget) return

    this.toggleTarget.disabled = busy
  }

  showSubscribed() {
    this._subscribed = true
    this.setBusy(false)
    this.toggleTarget?.setAttribute("aria-checked", "true")
    this.toggleTarget?.classList.remove("bg-gray-200", "dark:bg-gray-600")
    this.toggleTarget?.classList.add("bg-blue-600")
    this.toggleKnobTarget?.classList.remove("translate-x-0")
    this.toggleKnobTarget?.classList.add("translate-x-5")
    this.updateSubscriptionBadge(true)
  }

  showUnsubscribed() {
    this._subscribed = false
    this.setBusy(false)
    this.toggleTarget?.setAttribute("aria-checked", "false")
    this.toggleTarget?.classList.remove("bg-blue-600")
    this.toggleTarget?.classList.add("bg-gray-200", "dark:bg-gray-600")
    this.toggleKnobTarget?.classList.remove("translate-x-5")
    this.toggleKnobTarget?.classList.add("translate-x-0")
    this.updateSubscriptionBadge(false)
  }

  disableSubscription() {
    this.showUnsubscribed()
    this.setBusy(true)
  }

  updatePermissionBadge(permission = "checking") {
    if (!this.hasPermissionBadgeTarget) return

    const styles = {
      granted: "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200",
      denied: "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200",
      prompt: "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200",
      checking: "bg-gray-100 text-gray-600 dark:bg-gray-700 dark:text-gray-400"
    }
    const text = this.permissionBadgeTarget.dataset[`${permission}Text`] ||
      this.permissionBadgeTarget.dataset.checkingText

    this.permissionBadgeTarget.textContent = text
    this.permissionBadgeTarget.className = `${BADGE_BASE_CLASSES} ${styles[permission] || styles.checking}`
  }

  showStatus(message, type = "info") {
    if (!this.hasStatusTarget) return

    const styles = {
      success: "text-green-600 dark:text-green-400",
      error: "text-red-600 dark:text-red-400",
      warning: "text-yellow-600 dark:text-yellow-400",
      info: "text-blue-600 dark:text-blue-400"
    }

    this.statusTarget.textContent = message
    this.statusTarget.className = `mt-3 text-sm ml-9 ${styles[type] || styles.info}`
    this.statusTarget.classList.remove("hidden")

    clearTimeout(this.statusTimeout)
    this.statusTimeout = setTimeout(() => this.statusTarget.classList.add("hidden"), STATUS_TIMEOUT)
  }

  updateSubscriptionBadge(subscribed) {
    if (!this.hasSubscriptionBadgeTarget) return

    if (subscribed) {
      this.subscriptionBadgeTarget.textContent = this.subscriptionBadgeTarget.dataset.subscribedText
      this.subscriptionBadgeTarget.className = `${BADGE_BASE_CLASSES} bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200`
    } else {
      this.subscriptionBadgeTarget.textContent = this.subscriptionBadgeTarget.dataset.unsubscribedText
      this.subscriptionBadgeTarget.className = `${BADGE_BASE_CLASSES} bg-gray-100 text-gray-600 dark:bg-gray-700 dark:text-gray-400`
    }
  }
}
