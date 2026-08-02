import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

const THEMES = ["system", "light", "dark"]
const LIGHT_COLOR_MEDIA = "(prefers-color-scheme: light)"
const DARK_COLOR_MEDIA = "(prefers-color-scheme: dark)"

export default class extends Controller {
  static targets = ["lightColor", "darkColor"]

  static values = {
    owner: String,
    preference: String
  }

  connect() {
    this.syncFromRenderedPage = this.syncFromRenderedPage.bind(this)
    document.addEventListener("turbo:render", this.syncFromRenderedPage)
    this.applyTheme(this.preferenceValue)
  }

  disconnect() {
    document.removeEventListener("turbo:render", this.syncFromRenderedPage)
  }

  select(event) {
    const preference = event.target.value
    if (!THEMES.includes(preference)) return

    this.preferenceValue = preference
    this.applyTheme(preference)
    Turbo.cache.clear()
    event.target.form.requestSubmit()
  }

  syncFromRenderedPage() {
    const owner = document.body.dataset.themeOwner
    const preference = document.body.dataset.themePreference
    if (!owner || owner === this.ownerValue || !THEMES.includes(preference)) return

    this.ownerValue = owner
    this.preferenceValue = preference
    this.applyTheme(preference)
    Turbo.cache.clear()
  }

  applyTheme(preference) {
    const root = document.documentElement

    THEMES.forEach((theme) => {
      root.classList.toggle(`theme-${theme}`, theme === preference)
    })
    root.classList.toggle("dark", preference === "dark")

    if (!this.hasLightColorTarget || !this.hasDarkColorTarget) return

    this.lightColorTarget.media = preference === "light" ? "all" :
      preference === "dark" ? "not all" : LIGHT_COLOR_MEDIA
    this.darkColorTarget.media = preference === "dark" ? "all" :
      preference === "light" ? "not all" : DARK_COLOR_MEDIA
  }
}
