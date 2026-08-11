import PushSubscriptionUI from "controllers/push_subscription_ui"
import { removePushRegistration, savePushRegistration } from "push_registration_client"

const NATIVE_RESPONSE_TIMEOUT = 5000

export default class extends PushSubscriptionUI {
  static values = {
    subscribed: Boolean,
    destroyUrls: Object,
    registrationUrl: { type: String, default: "/mypage/push_registrations" },
    statusMessages: Object
  }

  connect() {
    this.nativeTimeout = setTimeout(() => {
      this.disableSubscription()
      this.showStatus(this.statusMessagesValue.native_unavailable, "error")
    }, NATIVE_RESPONSE_TIMEOUT)
  }

  disconnect() {
    super.disconnect()
    clearTimeout(this.nativeTimeout)
    this.disconnected = true
  }

  async toggleSubscription() {
    if (this._subscribed) {
      await this.unsubscribe()
    } else {
      this.setBusy(true)
      this.pendingAction = "subscribe"
      this.dispatch("subscribe")
    }
  }

  async nativeConnected(event) {
    clearTimeout(this.nativeTimeout)
    const detail = event.detail || {}
    this.platform = detail.platform
    this.firebaseInstallationId = detail.firebaseInstallationId
    this.destroyUrl = this.destroyUrlsValue[this.platform]
    this.subscribedValue = Boolean(this.destroyUrl)
    this.updatePermissionBadge(detail.permission)

    const nativeRegistered = detail.registered === true || Boolean(detail.firebaseInstallationId)

    if (this.subscribedValue && nativeRegistered) {
      await this.persistNativeRegistration(detail)
      return
    }

    if (this.subscribedValue && detail.permission === "granted") {
      this.setBusy(true)
      this.pendingAction = "reconcile-subscribe"
      this.dispatch("subscribe")
      return
    }

    if (this.subscribedValue) {
      await this.removeStaleServerRegistration()
      return
    }

    this.showUnsubscribed()
    if (nativeRegistered) {
      this.setBusy(true)
      this.pendingAction = "cleanup-unsubscribe"
      this.dispatch("unsubscribe", { detail: { firebaseInstallationId: detail.firebaseInstallationId } })
    }
  }

  async nativeSubscribed(event) {
    const detail = event.detail || {}
    const explicit = this.pendingAction === "subscribe"
    this.pendingAction = null
    this.updatePermissionBadge(detail.permission)

    if (!detail.firebaseInstallationId || !detail.platform) {
      this.showUnsubscribed()
      this.showStatus(this.statusMessagesValue.native_registration_missing, "error")
      return
    }

    await this.persistNativeRegistration(detail, explicit)
  }

  async unsubscribe() {
    this.setBusy(true)

    try {
      await removePushRegistration(this.destroyUrl)
    } catch (error) {
      console.error("Native FCM 서버 등록 삭제 실패:", error)
      this.showSubscribed()
      this.showStatus(this.statusMessagesValue.server_unsubscribe_failed, "error")
      return
    }

    this.subscribedValue = false
    this.removeDestroyUrl()
    this.showUnsubscribed()
    this.setBusy(true)
    this.pendingAction = "unsubscribe"
    this.dispatch("unsubscribe", { detail: { firebaseInstallationId: this.firebaseInstallationId } })
  }

  nativeUnsubscribed(event) {
    const detail = event.detail || {}
    const explicit = this.pendingAction === "unsubscribe"
    this.pendingAction = null
    this.firebaseInstallationId = null
    this.updatePermissionBadge(detail.permission)
    this.showUnsubscribed()
    if (explicit) this.showStatus(this.statusMessagesValue.unsubscribed, "success")
  }

  nativeFailed(event) {
    const detail = event.detail || {}
    clearTimeout(this.nativeTimeout)
    const serverRegistrationRemoved = ["unsubscribe", "cleanup-unsubscribe"].includes(this.pendingAction)
    const subscribing = ["subscribe", "reconcile-subscribe"].includes(this.pendingAction)
    this.pendingAction = null
    this.updatePermissionBadge(detail.permission)
    console.error("Native 푸시 알림 처리 실패:", detail.error || "unknown_error")

    if (serverRegistrationRemoved) {
      this.showUnsubscribed()
      this.showStatus(this.statusMessagesValue.device_cleanup_failed, "warning")
    } else if (subscribing) {
      this.showUnsubscribed()
      this.showStatus(this.statusMessagesValue.native_subscription_failed, "error")
    } else {
      this.disableSubscription()
      this.showStatus(this.statusMessagesValue.native_processing_failed, "error")
    }
  }

  async persistNativeRegistration(detail, showSuccess = false) {
    try {
      const registration = await savePushRegistration(
        this.registrationUrlValue,
        detail.firebaseInstallationId,
        detail.platform
      )
      if (this.disconnected) return

      this.firebaseInstallationId = detail.firebaseInstallationId
      this.platform = detail.platform
      this.destroyUrl = registration.destroy_url
      this.destroyUrlsValue = { ...this.destroyUrlsValue, [detail.platform]: registration.destroy_url }
      this.subscribedValue = true
      this.showSubscribed()
      if (showSuccess) this.showStatus(this.statusMessagesValue.subscribed, "success")
    } catch (error) {
      console.error("Native FCM 서버 등록 실패:", error)
      this.showUnsubscribed()
      this.showStatus(this.statusMessagesValue.server_subscribe_failed, "error")
    }
  }

  async removeStaleServerRegistration() {
    if (!this.platform) {
      this.disableSubscription()
      this.showStatus(this.statusMessagesValue.native_platform_missing, "error")
      return
    }

    try {
      await removePushRegistration(this.destroyUrl)
      this.subscribedValue = false
      this.removeDestroyUrl()
      this.showUnsubscribed()
      this.showStatus(this.statusMessagesValue.native_registration_removed, "warning")
    } catch (error) {
      console.error("Native FCM 서버 등록 정리 실패:", error)
      this.showSubscribed()
      this.showStatus(this.statusMessagesValue.native_sync_failed, "error")
    }
  }

  removeDestroyUrl() {
    const destroyUrls = { ...this.destroyUrlsValue }
    delete destroyUrls[this.platform]
    this.destroyUrlsValue = destroyUrls
    this.destroyUrl = null
  }
}
