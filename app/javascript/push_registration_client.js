export async function savePushRegistration(registrationUrl, firebaseInstallationId, platform, clientInformation = {}) {
  const response = await fetch(registrationUrl, {
    method: "POST",
    headers: requestHeaders(),
    body: JSON.stringify({
      push_registration: {
        firebase_installation_id: firebaseInstallationId,
        platform,
        device_model: clientInformation.deviceModel,
        os_version: clientInformation.osVersion,
        app_version: clientInformation.appVersion
      }
    })
  })

  if (!response.ok) throw new Error(`Push registration failed: ${response.status}`)

  return response.json()
}

export async function removePushRegistration(destroyUrl) {
  if (!destroyUrl) throw new Error("Push registration destroy URL is missing")

  const response = await fetch(destroyUrl, {
    method: "DELETE",
    headers: requestHeaders()
  })

  if (!response.ok && response.status !== 404) {
    throw new Error(`Push unregistration failed: ${response.status}`)
  }
}

export async function webDeviceInformation() {
  const userAgentData = navigator.userAgentData

  if (userAgentData?.getHighEntropyValues) {
    const highEntropyValues = await userAgentData
      .getHighEntropyValues(["fullVersionList"])
      .catch(() => ({}))
    const browser = preferredBrowser(highEntropyValues.fullVersionList || userAgentData.brands)

    return {
      deviceModel: normalizedBrowserName(browser?.brand),
      osVersion: browser?.version
    }
  }

  return legacyWebBrowserInformation(navigator.userAgent)
}

function requestHeaders() {
  return {
    "Content-Type": "application/json",
    "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content || ""
  }
}

function legacyWebBrowserInformation(userAgent) {
  const browserPatterns = [
    ["Edge", /Edg(?:A|iOS)?\/([\d.]+)/],
    ["Opera", /(?:OPR|Opera)\/([\d.]+)/],
    ["Chrome", /(?:Chrome|CriOS)\/([\d.]+)/],
    ["Firefox", /(?:Firefox|FxiOS)\/([\d.]+)/],
    ["Safari", /Version\/([\d.]+).*Safari/]
  ]

  for (const [browserName, pattern] of browserPatterns) {
    const match = userAgent.match(pattern)
    if (match) return { deviceModel: browserName, osVersion: match[1] }
  }

  return { deviceModel: "Web Browser", osVersion: null }
}

function preferredBrowser(browsers = []) {
  return browsers.find(({ brand }) => !/Not.*Brand|Chromium/i.test(brand)) ||
    browsers.find(({ brand }) => !/Not.*Brand/i.test(brand))
}

function normalizedBrowserName(browserName) {
  if (!browserName) return "Web Browser"
  if (/Microsoft Edge/i.test(browserName)) return "Edge"
  if (/Google Chrome/i.test(browserName)) return "Chrome"

  return browserName
}
