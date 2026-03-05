class BackfillLegalAgreementsForExistingUsers < ActiveRecord::Migration[8.1]
  def up
    terms_content = File.read(Rails.root.join("docs/legal/terms/2025-02-25.md"))
    privacy_content = File.read(Rails.root.join("docs/legal/privacy/2025-02-25.md"))

    terms = LegalDocument.find_or_create_by!(document_type: :terms, version: "2025-02-25") do |d|
      d.title = "이용약관"
      d.content = terms_content
      d.published_at = Time.zone.parse("2025-02-25")
    end

    privacy = LegalDocument.find_or_create_by!(document_type: :privacy_policy, version: "2025-02-25") do |d|
      d.title = "개인정보처리방침"
      d.content = privacy_content
      d.published_at = Time.zone.parse("2025-02-25")
    end

    User.find_each do |user|
      [ terms, privacy ].each do |doc|
        LegalAgreement.find_or_create_by!(user: user, legal_document: doc) do |agreement|
          agreement.accepted_at = user.created_at || Time.current
        end
      end
    end
  end

  def down
    LegalAgreement.delete_all
    LegalDocument.delete_all
  end
end
