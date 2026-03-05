require "test_helper"

class LegalAgreementTest < ActiveSupport::TestCase
  test "동일 사용자+문서 중복 동의는 불가능하다" do
    user = users(:test_user)
    doc = legal_documents(:terms_v1)

    LegalAgreement.create!(user: user, legal_document: doc, accepted_at: Time.current)

    duplicate = LegalAgreement.new(user: user, legal_document: doc, accepted_at: Time.current)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:legal_document_id], I18n.t("errors.messages.taken")
  end
end
