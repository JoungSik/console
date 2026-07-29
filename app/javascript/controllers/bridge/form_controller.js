import { BridgeComponent, BridgeElement } from "@hotwired/hotwire-native-bridge"

export default class extends BridgeComponent {
  static component = "form"
  static targets = ["submit"]

  submitTargetConnected(target) {
    const submitButton = new BridgeElement(target)

    this.send("connect", { submitTitle: submitButton.title }, () => {
      target.click()
    })
  }
}
