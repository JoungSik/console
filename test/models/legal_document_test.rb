require "test_helper"

class LegalDocumentTest < ActiveSupport::TestCase
  test "latest_terms는 최신 게시 이용약관을 반환한다" do
    latest = LegalDocument.latest_terms
    assert_equal legal_documents(:terms_v2), latest
  end

  test "latest_privacy_policy는 최신 게시 개인정보처리방침을 반환한다" do
    latest = LegalDocument.latest_privacy_policy
    assert_equal legal_documents(:privacy_policy_v1), latest
  end

  test "미래 published_at 문서는 latest에서 제외된다" do
    latest = LegalDocument.latest_terms
    assert_not_equal legal_documents(:future_terms), latest
  end

  test "동일 타입+버전 중복은 불가능하다" do
    duplicate = LegalDocument.new(
      document_type: :terms,
      version: "2025-02-25",
      title: "중복 이용약관",
      content: "내용",
      published_at: Time.current
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:version], I18n.t("errors.messages.taken")
  end
end
