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

    users_data = User.pluck(:id, :created_at)
    return if users_data.empty?

    now = Time.current
    agreements = users_data.flat_map do |user_id, created_at|
      accepted_at = created_at || now
      [
        { user_id: user_id, legal_document_id: terms.id, accepted_at: accepted_at, created_at: now, updated_at: now },
        { user_id: user_id, legal_document_id: privacy.id, accepted_at: accepted_at, created_at: now, updated_at: now }
      ]
    end

    LegalAgreement.upsert_all(agreements, unique_by: [ :user_id, :legal_document_id ])
  end

  def down
    LegalAgreement.delete_all
    LegalDocument.delete_all
  end
end
