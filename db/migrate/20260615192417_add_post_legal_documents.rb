class AddPostLegalDocuments < ActiveRecord::Migration[8.1]
  VERSION = "2026-06-16"

  def up
    create_legal_document!(
      document_type: :terms,
      title: "이용약관",
      path: Rails.root.join("docs/legal/terms/#{VERSION}.md")
    )
    create_legal_document!(
      document_type: :privacy_policy,
      title: "개인정보처리방침",
      path: Rails.root.join("docs/legal/privacy/#{VERSION}.md")
    )
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def create_legal_document!(document_type:, title:, path:)
    LegalDocument.find_or_create_by!(document_type: document_type, version: VERSION) do |document|
      document.title = title
      document.content = File.read(path)
      document.published_at = Time.zone.parse(VERSION)
    end
  end
end
