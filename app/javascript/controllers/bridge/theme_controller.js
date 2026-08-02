import { BridgeComponent } from "@hotwired/hotwire-native-bridge"

const THEMES = ["system", "light", "dark"]

export default class extends BridgeComponent {
  static component = "theme"

  initialize() {
    super.initialize()
    this.syncFromRenderedPage = this.syncFromRenderedPage.bind(this)
  }

  connect() {
    super.connect()
    document.removeEventListener("turbo:render", this.syncFromRenderedPage)
    document.addEventListener("turbo:render", this.syncFromRenderedPage)
    queueMicrotask(() => this.syncFromRenderedPage())
  }

  disconnect() {
    document.removeEventListener("turbo:render", this.syncFromRenderedPage)
    super.disconnect()
  }

  sync(event) {
    const owner = event?.detail?.owner || document.body.dataset.themeOwner
    const preference = event?.detail?.preference || document.body.dataset.themePreference
    if (!owner || !THEMES.includes(preference)) return

    this.send("sync", { owner, preference })
  }

  syncFromRenderedPage() {
    this.sync()
  }
}
