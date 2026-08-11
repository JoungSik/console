export async function savePushRegistration(registrationUrl, firebaseInstallationId, platform) {
  const response = await fetch(registrationUrl, {
    method: "POST",
    headers: requestHeaders(),
    body: JSON.stringify({
      push_registration: { firebase_installation_id: firebaseInstallationId, platform }
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

function requestHeaders() {
  return {
    "Content-Type": "application/json",
    "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content || ""
  }
}
