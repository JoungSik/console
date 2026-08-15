import PushSubscriptionUI from "controllers/push_subscription_ui"
import {
  removePushRegistration,
  savePushRegistration,
  webDeviceInformation
} from "push_registration_client"

export default class extends PushSubscriptionUI {
  static values = {
    configured: Boolean,
    firebaseConfig: Object,
    subscribed: Boolean,
    destroyUrl: String,
    registrationUrl: { type: String, default: "/mypage/push_registrations" },
    statusMessages: Object,
    vapidPublicKey: String
  }

  connect() {
    this.disconnected = false
    this.updatePermissionBadge(this.browserPermission())
    this.reconcileSubscription()
  }

  disconnect() {
    super.disconnect()
    this.disconnected = true
    this.stopRegistered?.()
    this.stopUnregistered?.()
    this.firebaseMessagingModule?.stopForegroundNotifications()
  }

  async reconcileSubscription() {
    if (!this.configuredValue) {
      this.disableSubscription()
      this.showStatus(this.statusMessagesValue.configuration_missing, "error")
      return
    }

    if (!("Notification" in window)) {
      this.updatePermissionBadge("denied")
      this.disableSubscription()
      this.showStatus(this.statusMessagesValue.web_not_supported, "error")
      return
    }

    if (!this.subscribedValue) {
      this.showUnsubscribed()
      return
    }

    if (Notification.permission !== "granted") {
      await this.removeStaleServerRegistration()
      return
    }

    try {
      await this.initializeFirebase()
      await this.registerWeb()
    } catch (error) {
      console.error("FCM 연결 실패:", error)
      this.showSubscribed()
      this.showStatus(this.statusMessagesValue.connection_failed, "error")
    }
  }

  async toggleSubscription() {
    if (this._subscribed) {
      await this.unsubscribe()
    } else {
      await this.subscribe()
    }
  }

  async subscribe() {
    this.setBusy(true)

    try {
      const permission = await Notification.requestPermission()
      this.updatePermissionBadge(this.normalizedPermission(permission))

      if (permission !== "granted") {
        this.showUnsubscribed()
        this.showStatus(this.statusMessagesValue.permission_denied, "warning")
        return
      }

      await this.initializeFirebase()
      this.showRegistrationSuccess = true
      await this.registerWeb()
    } catch (error) {
      this.showRegistrationSuccess = false
      console.error("FCM 등록 실패:", error)
      this.showUnsubscribed()
      this.showStatus(this.statusMessagesValue.subscription_failed, "error")
    }
  }

  async unsubscribe() {
    this.setBusy(true)

    try {
      await removePushRegistration(this.destroyUrlValue)
    } catch (error) {
      console.error("FCM 서버 등록 삭제 실패:", error)
      this.showSubscribed()
      this.showStatus(this.statusMessagesValue.server_unsubscribe_failed, "error")
      return
    }

    this.subscribedValue = false
    this.destroyUrlValue = ""
    this.showUnsubscribed()
    this.setBusy(true)

    try {
      await this.initializeFirebase()
      await this.firebaseMessagingModule.unregisterFirebaseMessaging(this.messaging)
      this.firebaseMessagingModule.stopForegroundNotifications()
      this.firebaseInstallationId = null
      this.showUnsubscribed()
      this.showStatus(this.statusMessagesValue.unsubscribed, "success")
    } catch (error) {
      console.error("FCM 등록 해제 실패:", error)
      this.showUnsubscribed()
      this.showStatus(this.statusMessagesValue.browser_cleanup_failed, "warning")
    }
  }

  async initializeFirebase() {
    if (this.firebaseInitialization) return this.firebaseInitialization

    this.firebaseInitialization = this.setupFirebase()
    return this.firebaseInitialization
  }

  async setupFirebase() {
    this.firebaseMessagingModule = await import("firebase_messaging")
    if (this.disconnected) return

    this.messaging = await this.firebaseMessagingModule.firebaseMessaging(this.firebaseConfigValue)
    if (this.disconnected) return

    this.serviceWorkerRegistration = await this.firebaseMessagingModule.firebaseServiceWorkerRegistration()
    if (this.disconnected) return

    if (!this.messaging || !this.serviceWorkerRegistration) throw new Error("Firebase Messaging is not supported")

    this.stopRegistered = this.firebaseMessagingModule.onFirebaseRegistered(
      this.messaging,
      (firebaseInstallationId) => this.webRegistered(firebaseInstallationId)
    )
    this.stopUnregistered = this.firebaseMessagingModule.onFirebaseUnregistered(
      this.messaging,
      () => this.webUnregistered()
    )
  }

  async registerWeb() {
    if (this.disconnected) return

    await this.firebaseMessagingModule.registerFirebaseMessaging(this.messaging, {
      vapidKey: this.vapidPublicKeyValue,
      serviceWorkerRegistration: this.serviceWorkerRegistration
    })
    if (!this.disconnected) this.firebaseMessagingModule.startForegroundNotifications(this.messaging)
  }

  async webRegistered(firebaseInstallationId) {
    const showSuccess = this.showRegistrationSuccess
    this.showRegistrationSuccess = false

    try {
      const deviceInformation = await webDeviceInformation()
      const registration = await savePushRegistration(
        this.registrationUrlValue,
        firebaseInstallationId,
        "web",
        deviceInformation
      )
      if (this.disconnected) return

      this.firebaseInstallationId = firebaseInstallationId
      this.destroyUrlValue = registration.destroy_url
      this.subscribedValue = true
      this.showSubscribed()
      if (showSuccess) this.showStatus(this.statusMessagesValue.subscribed, "success")
    } catch (error) {
      console.error("FCM 서버 등록 실패:", error)
      this.showUnsubscribed()
      this.showStatus(this.statusMessagesValue.server_subscribe_failed, "error")
    }
  }

  async webUnregistered() {
    if (!this.subscribedValue) return

    try {
      await removePushRegistration(this.destroyUrlValue)
    } catch (error) {
      console.error("FCM 서버 등록 삭제 실패:", error)
      this.showStatus(this.statusMessagesValue.server_cleanup_failed, "warning")
      return
    }

    if (this.disconnected) return

    this.firebaseInstallationId = null
    this.destroyUrlValue = ""
    this.subscribedValue = false
    this.showUnsubscribed()
  }

  async removeStaleServerRegistration() {
    try {
      await removePushRegistration(this.destroyUrlValue)
      this.subscribedValue = false
      this.destroyUrlValue = ""
      this.showUnsubscribed()
      this.showStatus(this.statusMessagesValue.permission_missing_registration_removed, "warning")
    } catch (error) {
      console.error("FCM 서버 등록 정리 실패:", error)
      this.showSubscribed()
      this.showStatus(this.statusMessagesValue.web_sync_failed, "error")
    }
  }

  browserPermission() {
    return "Notification" in window ? this.normalizedPermission(Notification.permission) : "denied"
  }

  normalizedPermission(permission) {
    return permission === "default" ? "prompt" : permission
  }
}
