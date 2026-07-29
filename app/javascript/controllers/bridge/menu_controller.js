import { BridgeComponent, BridgeElement } from "@hotwired/hotwire-native-bridge"

export default class extends BridgeComponent {
  static component = "menu"
  static targets = ["item"]

  itemTargetConnected() {
    queueMicrotask(() => this.connectMenu())
  }

  connectMenu() {
    const items = this.itemTargets.map((target, index) => {
      const item = new BridgeElement(target)

      return {
        index,
        title: item.title,
        destructive: item.bridgeAttribute("destructive") === "true"
      }
    })

    this.send("connect", { items }, (message) => {
      const selectedItem = this.itemTargets[message.data?.index]
      selectedItem?.click()
    })
  }
}
