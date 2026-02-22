import { Controller } from "@hotwired/stimulus"

// 공통 비용 체크박스와 참석자 태그 체크박스를 연동합니다.
// - 공통 비용 체크 → 모든 참석자 태그 체크
// - 참석자 태그 단일 해제 → 공통 비용 자동 해제
export default class extends Controller {
  static targets = ["shared", "member"]

  sharedChanged() {
    if (this.sharedTarget.checked) {
      this.memberTargets.forEach(cb => cb.checked = true)
    }
  }

  memberChanged() {
    const allChecked = this.memberTargets.every(cb => cb.checked)
    this.sharedTarget.checked = allChecked
  }
}
