class LegalAgreement < ApplicationRecord
  belongs_to :user
  belongs_to :legal_document

  validates :accepted_at, presence: true
  validates :legal_document_id, uniqueness: { scope: :user_id }
end
