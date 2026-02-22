import { Controller } from "@hotwired/stimulus"

// 반복 설정 선택 시 종료일 필드 표시/숨김 토글
export default class extends Controller {
  static targets = ["select", "endsOnField"]

  connect() {
    this.toggle()
  }

  toggle() {
    const hasRecurrence = this.selectTarget.value !== ""
    this.endsOnFieldTarget.classList.toggle("hidden", !hasRecurrence)
  }
}
