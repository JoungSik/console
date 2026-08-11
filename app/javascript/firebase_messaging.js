import { getApps, initializeApp } from "firebase/app"
import {
  getMessaging,
  isSupported,
  onMessage,
  onRegistered,
  onUnregistered,
  register,
  unregister
} from "firebase/messaging"

let messagingPromise
let stopForegroundMessages

export async function firebaseMessaging(firebaseConfig) {
  if (!firebaseConfig || !(await isSupported())) return null

  if (!messagingPromise) {
    messagingPromise = Promise.resolve().then(() => {
      const firebaseApp = getApps()[0] || initializeApp(firebaseConfig)
      return getMessaging(firebaseApp)
    })
  }

  return messagingPromise
}

export async function firebaseServiceWorkerRegistration() {
  if (!("serviceWorker" in navigator)) return null

  await navigator.serviceWorker.register("/service-worker.js", { scope: "/" })
  return navigator.serviceWorker.ready
}

export function onFirebaseRegistered(messaging, callback) {
  return onRegistered(messaging, callback)
}

export function onFirebaseUnregistered(messaging, callback) {
  return onUnregistered(messaging, callback)
}

export function registerFirebaseMessaging(messaging, options) {
  return register(messaging, options)
}

export function unregisterFirebaseMessaging(messaging) {
  return unregister(messaging)
}

export function startForegroundNotifications(messaging) {
  if (!("Notification" in window) || stopForegroundMessages || Notification.permission !== "granted") return
  if (!messaging) return

  stopForegroundMessages = onMessage(messaging, async (payload) => {
    const registration = await firebaseServiceWorkerRegistration()
    if (!registration) return

    await registration.showNotification(payload.notification?.title || "Console", {
      body: payload.notification?.body || "",
      icon: payload.notification?.icon || "/icon.png",
      badge: "/icon.png",
      data: { url: payload.data?.url || "/" }
    })
  })
}

export function stopForegroundNotifications() {
  stopForegroundMessages?.()
  stopForegroundMessages = null
}
