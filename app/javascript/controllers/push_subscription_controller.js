import { Controller } from "@hotwired/stimulus"

const PUSH_SUBSCRIPTION_ID_KEY = "pushSubscriptionId"

// Web Push 구독 관리 컨트롤러
export default class extends Controller {
  static targets = ["subscribeButton", "unsubscribeButton", "status", "toggle", "toggleKnob", "statusBadge"]
  static values = {
    vapidPublicKey: String,
    subscribeUrl: { type: String, default: "/mypage/push_subscriptions" }
  }

  connect() {
    this.subscriptionId = localStorage.getItem(PUSH_SUBSCRIPTION_ID_KEY)
    this.checkSupport()
    this.checkSubscription()
  }

  // 브라우저 지원 확인
  checkSupport() {
    if (!("serviceWorker" in navigator)) {
      this.showStatus("이 브라우저는 Service Worker를 지원하지 않습니다.", "error")
      this.disableButtons()
      return false
    }

    if (!("PushManager" in window)) {
      this.showStatus("이 브라우저는 Push 알림을 지원하지 않습니다.", "error")
      this.disableButtons()
      return false
    }

    return true
  }

  // 현재 구독 상태 확인
  async checkSubscription() {
    if (!this.checkSupport()) return

    try {
      const registration = await navigator.serviceWorker.ready
      const subscription = await registration.pushManager.getSubscription()

      if (subscription) {
        this.showSubscribed()
      } else {
        this.showUnsubscribed()
      }
    } catch (error) {
      console.error("구독 상태 확인 실패:", error)
      this.showStatus("구독 상태를 확인할 수 없습니다.", "error")
    }
  }

  // 알림 구독
  async subscribe() {
    if (!this.checkSupport()) return

    try {
      // 알림 권한 요청
      const permission = await Notification.requestPermission()
      if (permission !== "granted") {
        this.showStatus("알림 권한이 거부되었습니다. 브라우저 설정에서 허용해주세요.", "warning")
        return
      }

      // Service Worker가 준비될 때까지 대기 (레이아웃에서 이미 등록됨)
      const registration = await navigator.serviceWorker.ready

      // Push 구독 생성
      const subscription = await registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: this.urlBase64ToUint8Array(this.vapidPublicKeyValue)
      })

      // 서버에 구독 정보 전송
      const response = await this.sendSubscriptionToServer(subscription)
      this.subscriptionId = response.id
      localStorage.setItem(PUSH_SUBSCRIPTION_ID_KEY, this.subscriptionId)

      this.showSubscribed()
      this.showStatus("알림 구독이 완료되었습니다!", "success")
    } catch (error) {
      console.error("구독 실패:", error)
      this.showStatus("알림 구독에 실패했습니다: " + error.message, "error")
    }
  }

  // 알림 구독 취소
  async unsubscribe() {
    try {
      const registration = await navigator.serviceWorker.ready
      const subscription = await registration.pushManager.getSubscription()

      if (subscription) {
        // subscriptionId가 없으면 서버 삭제 불가 - 오류 표시
        if (!this.subscriptionId) {
          this.showStatus("구독 정보를 찾을 수 없습니다. 다시 구독 후 취소해주세요.", "error")
          return
        }

        // 서버에서 구독 삭제
        await fetch(`${this.subscribeUrlValue}/${this.subscriptionId}`, {
          method: "DELETE",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": this.getCsrfToken()
          }
        })

        // 브라우저에서 구독 취소
        await subscription.unsubscribe()
      }

      localStorage.removeItem(PUSH_SUBSCRIPTION_ID_KEY)
      this.subscriptionId = null
      this.showUnsubscribed()
      this.showStatus("알림 구독이 취소되었습니다.", "success")
    } catch (error) {
      console.error("구독 취소 실패:", error)
      this.showStatus("구독 취소에 실패했습니다: " + error.message, "error")
    }
  }

  // 서버에 구독 정보 전송
  async sendSubscriptionToServer(subscription) {
    const key = subscription.getKey("p256dh")
    const auth = subscription.getKey("auth")

    const response = await fetch(this.subscribeUrlValue, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.getCsrfToken()
      },
      body: JSON.stringify({
        push_subscription: {
          endpoint: subscription.endpoint,
          p256dh_key: this.arrayBufferToBase64(key),
          auth_key: this.arrayBufferToBase64(auth)
        }
      })
    })

    if (!response.ok) {
      throw new Error("서버 구독 등록 실패")
    }

    return response.json()
  }

  // CSRF 토큰 가져오기
  getCsrfToken() {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return meta ? meta.getAttribute("content") : ""
  }

  // Base64 URL을 Uint8Array로 변환
  urlBase64ToUint8Array(base64String) {
    const padding = "=".repeat((4 - (base64String.length % 4)) % 4)
    const base64 = (base64String + padding)
      .replace(/-/g, "+")
      .replace(/_/g, "/")

    const rawData = window.atob(base64)
    const outputArray = new Uint8Array(rawData.length)

    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i)
    }
    return outputArray
  }

  // ArrayBuffer를 Base64로 변환
  arrayBufferToBase64(buffer) {
    let binary = ""
    const bytes = new Uint8Array(buffer)
    for (let i = 0; i < bytes.byteLength; i++) {
      binary += String.fromCharCode(bytes[i])
    }
    return window.btoa(binary)
  }

  // 토글 클릭 핸들러
  async toggleSubscription() {
    if (this._subscribed) {
      await this.unsubscribe()
    } else {
      await this.subscribe()
    }
  }

  // UI 상태 업데이트
  showSubscribed() {
    this._subscribed = true

    // 레거시 버튼 방식 (마이페이지용)
    if (this.hasSubscribeButtonTarget) {
      this.subscribeButtonTarget.classList.add("hidden")
    }
    if (this.hasUnsubscribeButtonTarget) {
      this.unsubscribeButtonTarget.classList.remove("hidden")
    }

    // 토글 스위치 방식 (설정 페이지용)
    if (this.hasToggleTarget) {
      this.toggleTarget.classList.remove("bg-gray-200", "dark:bg-gray-600")
      this.toggleTarget.classList.add("bg-blue-600")
    }
    if (this.hasToggleKnobTarget) {
      this.toggleKnobTarget.classList.remove("translate-x-0")
      this.toggleKnobTarget.classList.add("translate-x-5")
    }
    this.updateStatusBadge(true)
  }

  showUnsubscribed() {
    this._subscribed = false

    // 레거시 버튼 방식 (마이페이지용)
    if (this.hasSubscribeButtonTarget) {
      this.subscribeButtonTarget.classList.remove("hidden")
    }
    if (this.hasUnsubscribeButtonTarget) {
      this.unsubscribeButtonTarget.classList.add("hidden")
    }

    // 토글 스위치 방식 (설정 페이지용)
    if (this.hasToggleTarget) {
      this.toggleTarget.classList.remove("bg-blue-600")
      this.toggleTarget.classList.add("bg-gray-200", "dark:bg-gray-600")
    }
    if (this.hasToggleKnobTarget) {
      this.toggleKnobTarget.classList.remove("translate-x-5")
      this.toggleKnobTarget.classList.add("translate-x-0")
    }
    this.updateStatusBadge(false)
  }

  showStatus(message, type = "info") {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
      this.statusTarget.className = `mt-3 text-sm ${this.getStatusClass(type)}`
      this.statusTarget.classList.remove("hidden")

      // 5초 후 자동 숨김
      setTimeout(() => {
        this.statusTarget.classList.add("hidden")
      }, 5000)
    }
  }

  getStatusClass(type) {
    const classes = {
      success: "text-green-600 dark:text-green-400",
      error: "text-red-600 dark:text-red-400",
      warning: "text-yellow-600 dark:text-yellow-400",
      info: "text-blue-600 dark:text-blue-400"
    }
    return classes[type] || classes.info
  }

  disableButtons() {
    if (this.hasSubscribeButtonTarget) {
      this.subscribeButtonTarget.disabled = true
      this.subscribeButtonTarget.classList.add("opacity-50", "cursor-not-allowed")
    }
    if (this.hasUnsubscribeButtonTarget) {
      this.unsubscribeButtonTarget.disabled = true
      this.unsubscribeButtonTarget.classList.add("opacity-50", "cursor-not-allowed")
    }
    if (this.hasToggleTarget) {
      this.toggleTarget.disabled = true
      this.toggleTarget.classList.add("opacity-50", "cursor-not-allowed")
    }
    this.updateStatusBadge(false)
  }

  // 구독 상태 뱃지 업데이트
  updateStatusBadge(subscribed) {
    if (!this.hasStatusBadgeTarget) return

    const baseClasses = "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
    if (subscribed) {
      this.statusBadgeTarget.textContent = this.statusBadgeTarget.dataset.subscribedText || "구독 중"
      this.statusBadgeTarget.className = `${baseClasses} bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200`
    } else {
      this.statusBadgeTarget.textContent = this.statusBadgeTarget.dataset.unsubscribedText || "미구독"
      this.statusBadgeTarget.className = `${baseClasses} bg-gray-100 text-gray-600 dark:bg-gray-700 dark:text-gray-400`
    }
  }
}
