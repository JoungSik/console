import { BridgeComponent } from "@hotwired/hotwire-native-bridge"

export default class extends BridgeComponent {
  static component = "push-notification"

  connect() {
    super.connect()
    this.handleVisibilityChange = this.handleVisibilityChange.bind(this)
    document.addEventListener("visibilitychange", this.handleVisibilityChange)
    this.refresh()
  }

  disconnect() {
    document.removeEventListener("visibilitychange", this.handleVisibilityChange)
    super.disconnect()
  }

  handleVisibilityChange() {
    if (document.visibilityState === "visible") this.refresh()
  }

  refresh() {
    this.send("connect", {}, (message) => {
      this.dispatch("connected", { detail: message.data || {} })
    })
  }

  subscribe() {
    this.send("subscribe", {}, (message) => {
      this.dispatchResult("subscribed", message)
    })
  }

  unsubscribe(event) {
    this.send("unsubscribe", { firebaseInstallationId: event.detail?.firebaseInstallationId }, (message) => {
      this.dispatchResult("unsubscribed", message)
    })
  }

  dispatchResult(successEvent, message) {
    const detail = message.data || {}
    this.dispatch(detail.error ? "failed" : successEvent, { detail })
  }
}
